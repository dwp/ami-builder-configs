#!/bin/bash

S3_BUCKET=$1
S3_FOLDER=$2
SQS_URL=$3
SNS_ARN=$4

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

TODAY=$(date +"%Y-%m-%d")
S3_FULL_FOLDER="$S3_FOLDER/$TODAY"

/opt/htme/htme.sh "$S3_BUCKET" "$S3_FULL_FOLDER" 2>&1 > /var/log/htme/htme.log
exitcode=$?
errcount=`grep -cP "(ERROR|FAILED)" /var/log/htme/htme.log`
if [[ $errcount -lt 1 ]] && [[ $exitcode == 0 ]]; then
  STATUS="Export successful"
else
  STATUS="Export failed"
fi

TIMESTAMP=`date "+%Y-%m-%dT%H:%M:%S.%3N"`
SENDER_TYPE="HTME"
SENDER_NAME=`hostname -f`

json=`jq -n --arg Timestamp "$TIMESTAMP" --arg SenderType "$SENDER_TYPE" --arg SenderName "$SENDER_NAME" --arg Bucket "$S3_BUCKET" --arg Folder "$S3_FULL_FOLDER" --arg Status "$STATUS" '{Timestamp: $Timestamp, SenderType: $SenderType, SenderName: $SenderName, Bucket: $Bucket, Folder: $Folder, Status: $Status}'`
/bin/aws sqs send-message --queue-url "$SQS_URL" --message-body "$json"

# Self-destruct
json=`jq -n --arg asg_prefix "htme_" --arg asg_size "0" '{asg_prefix: $asg_prefix, asg_size: $asg_size}'`
/bin/aws sns publish --topic-arn "$SNS_ARN" --message "$json"
