#!/bin/sh
set -eEu

ARCH=$(uname -m)

# Update packages on the instance
yum update -y

# Install Yum plugin that will remove unused dependencies after a package is uninstalled
yum install -y yum-plugin-remove-with-leaves

# Install AWS Inspector Agent for DW-3495
echo "Installing AWS Inspector Agent"

echo "Setting AWS Inspector Agent Proxy Config"
cat > /etc/init.d/awsagent.env << AWSAGENTPROXYCONFIG
export https_proxy=$https_proxy
export http_proxy=$http_proxy
export no_proxy=$no_proxy
AWSAGENTPROXYCONFIG
cat /etc/init.d/awsagent.env

echo "Obtaining AWS Inspector Agent installer"
curl -O https://inspector-agent.amazonaws.com/linux/latest/install

echo "Running AWS Inspector Agent installer"
bash install
if [[ $? -eq 0 ]]; then
    echo "AWS Inspector Agent install successful"
else
    echo "AWS Inspector Agent install failed"
fi
rm install
rm /etc/init.d/awsagent.env

# Tidy cloud.cfg to prevent yum locks in hardened AMI builds
sed -i.bak -e 's/repo_upgrade: security/repo_upgrade: none/' \
-e 's/repo_upgrade_exclude:/repo_update: false/' \
-e '/.-.nvidia.*/ d' \
-e '/.-.kernel.*/ d' \
-e '/.-.cudatoolkit.*/ d' /etc/cloud/cloud.cfg

yum install -y python-pip gcc yum-plugin-remove-with-leaves sudo

yum install -y python3
pip3 install jinja2
pip3 install pyyaml

echo "Install acm cert helper"
echo "Getting default region"
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
echo $AWS_DEFAULT_REGION
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.39.0
echo "Getting cert helper"
$(which aws) s3 cp s3://$ARTEFACT_BUCKET/acm-pca-cert-generator/acm_cert_helper-${acm_cert_helper_version}.tar.gz .

if [[ $ARCH != "x86_64" ]]; then
  echo "Installing ARM specific dependencies"
  yum install libffi-devel -y
  echo "Installing acm_cert_helper"
  pip3 install ./acm_cert_helper-${acm_cert_helper_version}.tar.gz
else
  pip3 install ./acm_cert_helper-${acm_cert_helper_version}.tar.gz
fi

yum remove -y gcc --remove-leaves

echo "export PATH=$PATH:/usr/local/bin" >> /etc/environment

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

# Add node_exporter as systemd service
mkdir -p /etc/systemd/system/

cat > /etc/systemd/system/node_exporter.service << SERVICE
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/bin/bash -ce "exec /home/prometheus/node_exporter/node_exporter >> /var/log/node_exporter.log 2>&1"
[Install]
WantedBy=default.target
SERVICE
chmod 0644 /etc/systemd/system/node_exporter.service

touch /var/log/node_exporter.log && chown prometheus:prometheus /var/log/node_exporter.log

systemctl enable node_exporter
systemctl start node_exporter

# Download and install CloudWatch Agent
yum -y install amazon-cloudwatch-agent

# To maintain CIS compliance
usermod -s /sbin/nologin cwagent
