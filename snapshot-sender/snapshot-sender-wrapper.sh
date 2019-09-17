#!/bin/bash

SQS_URL=$1
SNS_ARN=$2

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

i=0
while true; do
  MESSAGE=`aws sqs receive-message --queue-url $SQS_URL`
  STATUS=`echo $MESSAGE | jq -r '.Messages[].Body' | jq '.Status'`
  RECEIPT_HANDLE=`echo $MESSAGE | jq -r '.Messages[].ReceiptHandle'`
  if [[ z"$STATUS" == "" ]]; then
    sleep 2
#    ((i++))
  elif [[ $STATUS == *"Export failed"* ]]; then
    echo "Deleting message with status failed"
    /bin/aws sqs delete-message --queue-url $SQS_URL --receipt-handle "$RECEIPT_HANDLE"
    if [[ "$SHUTDOWN_FLAG" == "true" ]]; then
        # Self-destruct
        JSON=`jq -n --arg asg_prefix "snapshot-sender_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
        /bin/aws sns publish --topic-arn "$SNS_ARN" --message "$JSON"
    fi
  elif [[ $STATUS == *"Export successful"* ]]; then
#     i=300
     S3_FULL_FOLDER=`echo $MESSAGE | jq -r '.Messages[].Body' | jq '.Folder'`
     SHUTDOWN_FLAG=`echo $MESSAGE | jq -r '.Messages[].Body' | jq '.ShutdownFlag'`  
     echo "Starting snapshot sender for $S3_FULL_FOLDER"
     /opt/snapshot-sender/snapshot-sender.sh $S3_FULL_FOLDER 2>&1 > /var/log/snapshot-sender/snapshot-sender.log &
     PID=$!
     RUNNING=1
     while [[ $RUNNING -eq 1 ]]; do
       RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
       /bin/aws sqs change-message-visibility --queue-url "$SQS_URL" --receipt-handle "$RECEIPT_HANDLE"  --visibility-timeout 7
       sleep 5
     #TODO: check sender logs
     done
     echo "Sending process done, deleting message from SQS"
     /bin/aws sqs delete-message --queue-url $SQS_URL --receipt-handle "$RECEIPT_HANDLE"
     if [[ "$SHUTDOWN_FLAG" == "true" ]]; then
        # Self-destruct
        JSON=`jq -n --arg asg_prefix "snapshot-sender_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
        /bin/aws sns publish --topic-arn "$SNS_ARN" --message "$JSON"
      fi
  else
    # Unknown status - wait and recheck messages
    sleep 2
#    ((i++))
  fi
done

#logstamp=`date "+%Y-%m-%dT%H-%M-%S-%3N"`
#/bin/aws s3 cp /var/log/snapshot-sender/snapshot-sender.log s3://$S3_BUCKET/$logstamp-snapshot-sender.log
#/bin/aws s3 cp /var/log/snapshot-sender/nohup.log s3://$S3_BUCKET/$logstamp-nohup.log

#/bin/aws lambda invoke --function-name asg_resizer --invocation-type Event --payload "{
#  \"asg_prefix\": \"snapshot-sender_\", \
#  \"asg_size\": \"0\" \
#}"
