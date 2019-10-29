#!/bin/sh -x

## Script to install htme service

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

# Download & install AWS-CLI
sudo pip install awscli

sudo mkdir /opt/htme
sudo mkdir /var/log/htme

# Download & install latest hbase-to-mongo-export service artifact
VERSION="0.0.44"
URL="https://github.com/dwp/hbase-to-mongo-export/releases/download/${VERSION}/hbase-to-mongo-export-${VERSION}.jar"
echo "JAR_VERSION: $VERSION"
echo "JAR_DOWNLOAD_URL: $URL"
curl "$URL" -L -o /tmp/htme.jar
sudo useradd htme -m

sudo sh -c "echo ${VERSION} > /opt/htme/version"

sudo mv /tmp/htme.jar /opt/htme/
sudo cp /tmp/ami-builder/hbase-to-mongo-export/htme.sh              /opt/htme/
sudo cp /tmp/ami-builder/hbase-to-mongo-export/htme                 /etc/init.d/
sudo cp /tmp/ami-builder/hbase-to-mongo-export/htmewrapper.sh       /opt/htme/

sudo chown htme:htme -R  /opt/htme
sudo chown htme:htme -R  /var/log/htme
sudo chmod u+x         /etc/init.d/htme
sudo chmod u+x         /opt/htme/htme.sh
sudo chmod u+x         /opt/htme/htmewrapper.sh

# Setup Logrotate
sudo cp /tmp/ami-builder/hbase-to-mongo-export/htme.logrotate     /etc/logrotate.d/htme
