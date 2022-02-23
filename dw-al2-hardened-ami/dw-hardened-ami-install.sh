#!/bin/sh
set -eEu

# Install Java
yum install -y java-1.8.0-openjdk-devel jq rng-tools

# CVE-2021-41617, CVE-2022-0156, CVE-2022-0158, CVE-2022-0213, CVE-2022-0261, CVE-2022-0318, CVE-2022-0351, CVE-2022-0359
# udpate OpenSSH and vim
yum update -y openssh vim

chkconfig rngd on

# Turn down cloud-init logs to prevent false CloudWatch alarms regarding DEBUG logs
sed -i s/DEBUG/INFO/ /etc/cloud/cloud.cfg.d/05_logging.cfg
