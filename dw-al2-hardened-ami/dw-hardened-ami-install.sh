#!/bin/sh
set -eEu

## Script to prepare general Dataworks AMI

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Java
yum install -y java-1.8.0-openjdk-devel jq rng-tools
chkconfig rngd on

# Turn down cloud-init logs to prevent false CloudWatch alarms regarding DEBUG logs
sed -i s/DEBUG/INFO/ /etc/cloud/cloud.cfg.d/05_logging.cfg
