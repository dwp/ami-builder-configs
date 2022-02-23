#!/bin/sh
set -eEu

# Install Java
yum install -y java-1.8.0-openjdk-devel jq rng-tools

# udpate OpenSSH and vim
yum update -y openssh vim

chkconfig rngd on

# Turn down cloud-init logs to prevent false CloudWatch alarms regarding DEBUG logs
sed -i s/DEBUG/INFO/ /etc/cloud/cloud.cfg.d/05_logging.cfg
