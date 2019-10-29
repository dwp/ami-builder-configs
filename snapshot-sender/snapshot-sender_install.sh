#!/bin/sh -x

## Script to install snapshot-sender service

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Amazon SSM agent - download 1st to avoid YUM proxy issues
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Configure YUM repos to point at fixed mirrors so requests through the proxy will work
sed -i -e 's/^mirrorlist=/#&/' -e 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/CentOS-Base.repo
yum --enablerepo=extras install -y epel-release
sed -i -e 's/^metalink=/#&/' -e 's@^#baseurl=.*@baseurl=http://mirrors.coreix.net/fedora-epel/7/$basearch@' /etc/yum.repos.d/epel.repo

# Install Java
# yum update -y
yum install -y java-1.8.0-openjdk-devel python-pip gcc python-devel nmap-ncat jq rng-tools

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install awscli

yum remove -y gcc python-devel

systemctl enable rngd

sudo mkdir /opt/snapshot-sender
sudo mkdir /var/log/snapshot-sender

Download & install latest crown snapshot-sender service artifact
VERSION="0.0.21"
URL="https://github.com/dwp/snapshot-sender/releases/download/${VERSION}/snapshot-sender-${VERSION}.jar"
echo "JAR_VERSION: $VERSION"
echo "JAR_DOWNLOAD_URL: $URL"
curl "$URL" -L -o /tmp/snapshot-sender.jar
sudo useradd sender -m

sudo sh -c "echo ${VERSION} > /opt/snapshot-sender/version"

sudo mv /tmp/snapshot-sender.jar                                         /opt/snapshot-sender/
sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender.sh              /opt/snapshot-sender/
sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender-wrapper.sh      /opt/snapshot-sender/

sudo chown sender:sender -R  /var/log/snapshot-sender
sudo chown sender:sender -R  /opt/snapshot-sender
sudo chmod u+x               /opt/snapshot-sender/snapshot-sender.sh
sudo chmod u+x               /opt/snapshot-sender/snapshot-sender-wrapper.sh

# Setup Logrotate
sudo cp /tmp/ami-builder/snapshot-sender/snapshot-sender.logrotate     /etc/logrotate.d/snapshot-sender
