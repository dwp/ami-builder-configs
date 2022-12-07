#!/bin/sh
set -eEu

ARCH=$(uname -m)

# disable extra un-necessary repo
find /etc/yum.repos.d/ -type f -exec sed -i '/enabled.*/enabled = 0/g' {} \;

# re-write core repo file with fixed base url
# this is a temp work around, may need little elegant solution
cat > /etc/yum.repos.d/amzn2-core.repo << AMZN2COREREPO
[amzn2-core]
name=Amazon Linux 2 core repository
priority=10
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2
enabled=1
metadata_expire=300
mirrorlist_expire=300
report_instanceid=yes
AMZN2COREREPO
curl -O "http://amazonlinux.eu-west-2.amazonaws.com/2/core/2.0/x86_64/mirror.list"
echo "baseurl=$(cat mirror.list)" >> /etc/yum.repos.d/amzn2-core.repo && rm -f mirror.list
cat /etc/yum.repos.d/amzn2-core.repo

cat > /etc/yum.repos.d/amzn2extra-tomcat8.repo << AMZN2EXTRATOMCAT
[amzn2extra-tomcat8.5]
enabled = 1
name = Amazon Extras repo for tomcat8.5
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2
priority = 10
skip_if_unavailable = 1
report_instanceid = yes
AMZN2EXTRATOMCAT
curl -O "http://amazonlinux.eu-west-2.amazonaws.com/2/extras/tomcat8.5/latest/x86_64/mirror.list"
echo "baseurl=$(cat mirror.list)" >> /etc/yum.repos.d/amzn2extra-tomcat8.repo && rm -f mirror.list
cat /etc/yum.repos.d/amzn2extra-tomcat8.repo

# Update packages on the instance
yum update -y

# Tidy cloud.cfg to prevent yum locks in hardened AMI builds
sed -i.bak -e 's/repo_upgrade: security/repo_upgrade: none/' \
-e 's/repo_upgrade_exclude:/repo_update: false/' \
-e '/.-.nvidia.*/ d' \
-e '/.-.kernel.*/ d' \
-e '/.-.cudatoolkit.*/ d' /etc/cloud/cloud.cfg

yum install -y python3 python-pip gcc yum-plugin-remove-with-leaves sudo

pip3 install jinja2
pip3 install pyyaml

echo "Install acm cert helper"
echo "Getting default region"
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
echo $AWS_DEFAULT_REGION
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.41.0
echo "Getting cert helper"
$(which aws) s3 cp s3://$ARTEFACT_BUCKET/acm-pca-cert-generator/acm_cert_helper-${acm_cert_helper_version}.tar.gz .

pip install ./acm_cert_helper-${acm_cert_helper_version}.tar.gz

yum remove -y gcc --remove-leaves

echo "export PATH=$PATH:/usr/local/bin:/bin" >> /etc/environment

cat > /usr/local/bin/set_yum_proxy.sh << 'SETYUMPROXY'
TAG_NAME="internet_proxy"
INSTANCE_ID="`curl -s http://instance-data/latest/meta-data/instance-id`"
REGION="`curl -s http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
if [ -n "${TAG_VALUE}" ]; then
  sed -i -e "/^enabled=/a \
proxy=$TAG_VALUE" /etc/yum.repos.d/{amzn-*,epel*}.repo
fi
SETYUMPROXY
chmod 0700 /usr/local/bin/set_yum_proxy.sh

cat > /etc/cloud/cloud.cfg.d/15_yum_proxy.cfg << CLOUDCFG
bootcmd:
 - [ cloud-init-per, once, set-yum-proxy, /usr/local/bin/set_yum_proxy.sh ]
CLOUDCFG

# Install node-exporter

useradd -m -s /bin/bash prometheus

# Download node_exporter release from original repo
curl -L -O  https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

tar -xzvf node_exporter-1.0.1.linux-amd64.tar.gz
mv node_exporter-1.0.1.linux-amd64 /home/prometheus/node_exporter
rm -f node_exporter-1.0.1.linux-amd64.tar.gz
chown -R prometheus:prometheus /home/prometheus/node_exporter

# Add node_exporter as systemd service and set HCS Compliance metric
mkdir -p /etc/systemd/system/ && /var/node_exporter/metrics

if [ "${HCS_COMPLIANT}" ]; then
  touch /home/prometheus/hcs_compliant
fi

if [ -f "/home/prometheus/hcs_compliant" ]; then
  echo "hcs_compliant 1" > /var/node_exporter/metrics/hcs_compliant.prom
else
  echo "hcs_compliant 0" > /var/node_exporter/metrics/hcs_compliant.prom
fi

chown -R prometheus:prometheus /var/node_exporter

cat > /etc/systemd/system/node_exporter.service << SERVICE
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/bin/bash -ce "exec /home/prometheus/node_exporter/node_exporter --collector.textfile.directory=/var/node_exporter/metrics >> /var/log/node_exporter.log 2>&1"
[Install]
WantedBy=default.target
SERVICE
chmod 0644 /etc/systemd/system/node_exporter.service

touch /var/log/node_exporter.log && chown prometheus:prometheus /var/log/node_exporter.log

systemctl enable node_exporter
systemctl start node_exporter

# To maintain CIS compliance
usermod -s /sbin/nologin cwagent

# clean-up provision files
rm -rf /home/ec2-user/*