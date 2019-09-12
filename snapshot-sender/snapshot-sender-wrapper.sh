#!/bin/bash

SQS_URL=$1
SNS_ARN=$2

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

i=0
while true; do
  message=`aws sqs receive-message --queue-url $SQS_URL`
  Status=`echo $message | jq -r '.Messages[].Body' | jq '.Status'`
  if [[ z"$Status" == "" ]]; then
    sleep 2
#    ((i++))
  elif [[ $Status == *"Export failed"* ]]; then
    echo "Deleting message with status failed"
    ReceiptHandle=`echo $message | jq -r '.Messages[].ReceiptHandle'`
    /bin/aws sqs delete-message --queue-url $SQS_URL --receipt-handle "$ReceiptHandle"
    sleep 2
  elif [[ $Status == *"Export successful"* ]]; then
#     i=300
     ReceiptHandle=`echo $message | jq -r '.Messages[].ReceiptHandle'`
     S3_FULL_FOLDER=`echo $message | jq -r '.Messages[].Body' | jq '.Folder'`
     ShutdownFlag=`echo $message | jq -r '.Messages[].Body' | jq '.ShutdownFlag'`  
     echo "Starting snapshot sender for $S3_FULL_FOLDER"
     /opt/snapshot-sender/snapshot-sender.sh $S3_FULL_FOLDER 2>&1 > /var/log/snapshot-sender/snapshot-sender.log &
     PID=$!
     RUNNING=1
     while [[ $RUNNING -eq 1 ]]; do
       RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
       /bin/aws sqs change-message-visibility --queue-url "$SQS_URL" --receipt-handle "$ReceiptHandle"  --visibility-timeout 30
       sleep 25
     #TODO: check sender logs
     done
     echo "Sending process done, deleting message from SQS"
     /bin/aws sqs delete-message --queue-url $SQS_URL --receipt-handle "$ReceiptHandle"
     if [[ "$ShutdownFlag" == "true" ]]; then
        # Self-destruct
        json=`jq -n --arg asg_prefix "snapshot-sender_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
        /bin/aws sns publish --topic-arn "$SNS_ARN" --message "$json"
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
