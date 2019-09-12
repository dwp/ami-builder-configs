#!/bin/bash

S3_BUCKET=$1
S3_FOLDER=$2
SQS_URL=$3
SNS_ARN=$4
SQS_INCOMING_URL=$5

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

i=0
while true; do
    message=`aws sqs receive-message --queue-url $SQS_INCOMING_URL`

    if [[ ! -z "$message" ]]; then
        Body=`echo $message | jq -r '.Messages[].Body'`
        ReceiptHandle=`echo $message | jq -r '.Messages[].ReceiptHandle'`
        echo "Message received from SQS with body of $Body"
        
        Run=`echo $Body | jq '.run-export' | tr [:lower:]`
        Shutdown_htme=`echo $Body | jq '.htme-shutdown-on-completion' | tr [:lower:]`
        Shutdown_ss=`echo $Body | jq '.snapshot-sender-shutdown-on-completion' | tr [:lower:]`
        
        if [[ "$Run" == "true" ]]; then
            TODAY=$(date +"%Y-%m-%d")
            S3_FULL_FOLDER="$S3_FOLDER/$TODAY"

            echo "Starting export process"
            /opt/htme/htme.sh "$S3_BUCKET" "$S3_FULL_FOLDER" 2>&1 > /var/log/htme/htme.log &
            PID=$!
            RUNNING=1
            while [[ $RUNNING -eq 1 ]]; do
                RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
                /bin/aws sqs change-message-visibility --queue-url "$SQS_INCOMING_URL" --receipt-handle "$ReceiptHandle"  --visibility-timeout 10
                sleep 5
            done
            exitcode=$?
            errcount=`grep -cP "(ERROR|FAILED)" /var/log/htme/htme.log`

            echo "Sending process done, deleting message from SQS"
            /bin/aws sqs delete-message --queue-url $SQS_INCOMING_URL --receipt-handle "$ReceiptHandle"

            if [[ $errcount -lt 1 ]] && [[ $exitcode == 0 ]]; then
                STATUS="Export successful"
            else
                STATUS="Export failed"
            fi

            TIMESTAMP=`date "+%Y-%m-%dT%H:%M:%S.%3N"`
            SENDER_TYPE="HTME"
            SENDER_NAME=`hostname -f`

            json=`jq -n --arg Timestamp "$TIMESTAMP" --arg SenderType "$SENDER_TYPE" --arg SenderName "$SENDER_NAME" --arg Bucket "$S3_BUCKET" --arg Folder "$S3_FULL_FOLDER" --arg Status "$STATUS" --arg Shutdown "$Shutdown_ss" '{Timestamp: $Timestamp, SenderType: $SenderType, SenderName: $SenderName, Bucket: $Bucket, Folder: $Folder, Status: $Status, snapshot-sender-shutdown-on-completion: $Shutdown}'`
            /bin/aws sqs send-message --queue-url "$SQS_URL" --message-body "$json"

            if [[ "$Shutdown_htme" == "true" ]]; then
                json=`jq -n --arg asg_prefix "htme_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
                /bin/aws sns publish --topic-arn "$SNS_ARN" --message "$json"
            fi
        fi
    fi

    sleep 2
done
