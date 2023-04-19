#!/bin/sh
set -eEu

# Make changes to hardened-ami that are specific to JVM applications
echo "Configure AMI changes in ami-builder-configs/dw-al2-jvm-ami"

# Install Java
yum install -y java-1.8.0-openjdk-devel jq rng-tools

# udpate OpenSSH and vim
yum update -y openssh vim

# Install Tenable
yum -y install NessusAgent --disablerepo=* --enablerepo tenable
/sbin/service nessusagent start  # starts and enables the service

chkconfig rngd on

# Turn down cloud-init logs to prevent false CloudWatch alarms regarding DEBUG logs
sed -i s/DEBUG/INFO/ /etc/cloud/cloud.cfg.d/05_logging.cfg

# accept anything that wasn't specifically covered
# temp change until we configure iptables to mirror sg
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# flushing all rules
iptables -F

# presisting rules for next boot
service iptables save
