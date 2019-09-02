#!/bin/bash

SQS_URL=$1

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

i=0
while [ $i -lt 300 ]; do
  message=`aws sqs receive-message --queue-url $SQS_URL`
  Status=`echo $message | jq -r '.Messages[].Body' | jq '.Status'`
  echo "Message received:"
  echo "$message"
  if [[ z"$Status" == "" ]]; then
    sleep 2
    ((i++))
  elif [[ $Status == *"Export failed"* ]]; then
    echo "Deleting message with status failed"
    ReceiptHandle=`echo $message | jq -r '.Messages[].ReceiptHandle'`
    /bin/aws sqs delete-message --queue-url $SQS_URL --receipt-handle "$ReceiptHandle"
    sleep 2
  elif [[ $Status == *"Export successful"* ]]; then
     i=300
     ReceiptHandle=`echo $message | jq -r '.Messages[].ReceiptHandle'`
     S3_FULL_FOLDER=`echo $message | jq -r '.Messages[].Body' | jq '.Folder'`
     echo "Starting snapshot sender for $S3_FULL_FOLDER"
     /opt/snapshot-sender/snapshot-sender.sh $S3_FULL_FOLDER 2>&1 > /var/log/snapshot-sender/snapshot-sender.log &
     PID=$!
     RUNNING=1
     while [[ $RUNNING -eq 1 ]]; do
       RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
       /bin/aws sqs change-message-visibility --queue-url "$SQS_URL" --receipt-handle "$ReceiptHandle"  --visibility-timeout 30
       sleep 25
     echo "Sending process done"
     #TODO: check sender logs
     done
  else
    # Unknown status - wait and recheck messages
    sleep 2
    ((i++))
  fi
done

#/bin/aws lambda invoke --function-name asg_resizer --invocation-type Event --payload "{
#\"asg_prefix\": \"snapshot-sender_\", \
#\"asg_size\": \"0\" \
#}"
