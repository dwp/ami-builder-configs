#!/bin/bash

S3_BUCKET=$1
S3_FOLDER=$2
SQS_URL=$3

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

TODAY=$(date +"%Y-%m-%d")
S3_FULL_FOLDER="$S3_FOLDER/$TODAY"

/opt/htme/htme.sh "$S3_BUCKET" "$S3_FULL_FOLDER" 2>&1 > /var/log/htme/htme.log &
PID=$!
RUNNING=1
while [[ $RUNNING -eq 1 ]]; do
  sleep 5
  RUNNING=`ps --no-headers $PID | awk '{print $1}' | grep -c $PID`
done

# TODO: parse log and check exit status (invert res value)
res=`grep -cP "(ERROR|FAILED)" /var/log/htme/htme.log`
if [[ $res -eq 1 ]]; then
  STATUS="Export successful"
else
  STATUS="Export failed"
fi

TIMESTAMP=`date "+%Y-%m-%dT%H:%M:%S.%3N"`
SENDER_TYPE="HTME"
SENDER_NAME=`hostname -f`

/bin/aws sqs send-message --queue-url "$SQS_URL" --message-body "{ \
  \"Message\": { \
    \"Timestamp\": \"$TIMESTAMP\", \
    \"SenderType\": \"$SENDER_TYPE\", \
    \"SenderName\": \"$SENDER_NAME\", \
    \"Bucket\": \"$S3_BUCKET\", \
    \"Folder\": \"$S3_FULL_FOLDER\", \
    \"Status\": \"$STATUS\" \
  } \
}"

# TODO: Resize ASG on end
#  /bin/aws lambda invoke --function-name asg_resizer --invocation-type Event --payload "{
#  \"asg_prefix\": \"htme_\", \
#  \"asg_size\": \"0\" \
#}"
