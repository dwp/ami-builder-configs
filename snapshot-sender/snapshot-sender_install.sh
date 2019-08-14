#!/bin/sh -x

## Script to install snapshot-sender service

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.8.0

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip

# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
sudo yum install -y gcc
sudo yum install -y python-devel
sudo pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
sudo yum remove -y gcc python-devel

# Adding in netcat and jq for troubleshooting
sudo yum install -y nmap-ncat jq

# Download & install AWS-CLI
sudo pip install awscli

# Download & install latest crown snapshot-sender service artifact
#VERSION=`curl -s https://api.github.com/repos/dwp/snapshot-sender/releases/latest | grep browser_download_url |grep snapshot-sender | cut -d '/' -f 8`
#URL=`curl -s https://api.github.com/repos/dwp/snapshot-sender/releases/${VERSION} \
#  | grep browser_download_url \
#  | grep snapshot-sender \
#  | cut -d '"' -f 4`
#curl "$URL" -L -o /tmp/snapshot-sender.jar

sudo mkdir /opt/snapshot-sender
sudo mkdir /var/log/snapshot-sender
#sudo mv /tmp/snapshot-sender.jar /opt/snapshot-sender/
#sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender.sh              /opt/snapshot-sender/
#sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender                 /etc/init.d/

sudo useradd snapshot-sender -m
sudo chown snapshot-sender:snapshot-sender -R  /opt/snapshot-sender
sudo chown snapshot-sender:snapshot-sender -R  /var/log/snapshot-sender
#sudo chmod u+x         /etc/init.d/snapshot-sender
#sudo chmod u+x         /opt/snapshot-sender/snapshot-sender.sh
#sudo chkconfig --add snapshot-sender
#sudo systemctl disable snapshot-sender

# Setup Logrotate
sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender.logrotate     /etc/logrotate.d/snapshot-sender
