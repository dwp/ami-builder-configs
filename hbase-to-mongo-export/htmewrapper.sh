#!/bin/bash

S3_BUCKET=$1
S3_FOLDER=$2
SQS_URL=$3
SNS_ARN=$4
SQS_INCOMING_URL=$5

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

i=0
while true; do
    MESSAGE=`aws sqs receive-message --queue-url $SQS_INCOMING_URL`

    if [[ ! -z "$MESSAGE" ]]; then
        BODY=`echo $MESSAGE | jq -r '.Messages[].Body'`
        RECEIPT_HANDLE=`echo $MESSAGE | jq -r '.Messages[].ReceiptHandle'`
        echo "Message received from SQS with body of $BODY"
        
        RUN=`echo $BODY | jq -r '."run-export"'`
        SHUTDOWN_HTME=`echo $BODY | jq -r '."htme-shutdown-on-completion"'`
        SHUTDOWN_SS=`echo $BODY | jq -r '."ss-shutdown-on-completion"'`
        echo "Message interpreted as run = '$RUN', shutdown-htme = '$SHUTDOWN_HTME' and shutdown-ss = '$SHUTDOWN_SS'"

        if [[ "$RUN" == "true" ]]; then
            TODAY=$(date +"%Y-%m-%d")
            S3_SUFFIX=`echo $BODY | jq -r '."s3-suffix"'`
            if [[ -z "$S3_SUFFIX" ]] || [[ "$S3_SUFFIX" == "null" ]]; then
              S3_FULL_FOLDER="$S3_FOLDER/$TODAY"
            else
              S3_FULL_FOLDER="$S3_FOLDER/$S3_SUFFIX/$TODAY"
            fi

            TOPICS=`echo $BODY | jq -r '."active-topics-override"'`
            if [[ -z "$TOPICS" ]] || [[ "$TOPICS" == "null" ]]; then
              TOPICS_FILE="/opt/htme/topics-active.csv"
              echo "List of topics is from default file $TOPICS_FILE"
            else
              DATESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
              TOPICS_FILE="/opt/htme/$DATESTAMP.csv"
              echo $TOPICS | sed -E 's/,/\n/g' > $TOPICS_FILE
              echo "List of topics from sqs message is $TOPICS"
            fi

            echo "Starting export process from $TOPICS_FILE into S3 at s3://$S3_BUCKET/$S3_FULL_FOLDER"
            /opt/htme/htme.sh "$S3_BUCKET" "$S3_FULL_FOLDER" "$TOPICS_FILE" 2>&1 > /var/log/htme/htme.log &
            PID=$!
            RUNNING=1
            while [[ $RUNNING -eq 1 ]]; do
                RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
                /bin/aws sqs change-message-visibility --queue-url "$SQS_INCOMING_URL" --receipt-handle "$RECEIPT_HANDLE"  --visibility-timeout 7
                sleep 5
            done
            EXITCODE=$?
            ERRCOUNT=`grep -cP "(ERROR|FAILED)" /var/log/htme/htme.log`

            echo "Sending process done, deleting message from SQS"
            /bin/aws sqs delete-message --queue-url $SQS_INCOMING_URL --receipt-handle "$RECEIPT_HANDLE"

            if [[ $ERRCOUNT -lt 1 ]] && [[ $EXITCODE == 0 ]]; then
                STATUS="Export successful"
            else
                STATUS="Export failed"
            fi

            TIMESTAMP=`date "+%Y-%m-%dT%H:%M:%S.%3N"`
            SENDER_TYPE="HTME"
            SENDER_NAME=`hostname -f`

            SQS_OUTGOING_MESSAGE=`jq -n --arg Timestamp "$TIMESTAMP" --arg SenderType "$SENDER_TYPE" --arg SenderName "$SENDER_NAME" --arg Bucket "$S3_BUCKET" --arg Folder "$S3_FULL_FOLDER" --arg Status "$STATUS" --arg Shutdown "$SHUTDOWN_SS" '{Timestamp: $Timestamp, SenderType: $SenderType, SenderName: $SenderName, Bucket: $Bucket, Folder: $Folder, Status: $Status, ShutdownFlag: $Shutdown}'`
            /bin/aws sqs send-message --queue-url "$SQS_URL" --message-body "$SQS_OUTGOING_MESSAGE"

            if [[ "$SHUTDOWN_HTME" == "true" ]]; then
                SNS_OUTGOING_MESSAGE=`jq -n --arg asg_prefix "htme_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
                /bin/aws sns publish --topic-arn "$SNS_ARN" --message "$SNS_OUTGOING_MESSAGE"
            fi
        fi
    fi

    sleep 2
done
