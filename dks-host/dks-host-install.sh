#!/bin/sh -x

## Script to install DKS service

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Amazon SSM agent - download 1st to avoid YUM proxy issues
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install the AWS CloudHSM Client and Command Line Tools
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-latest.el7.x86_64.rpm
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-jce-latest.el7.x86_64.rpm

# Configure YUM repos to point at fixed mirrors so requests through the proxy will work
sed -i -e 's/^mirrorlist=/#&/' -e 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/CentOS-Base.repo
yum --enablerepo=extras install -y epel-release
sed -i -e 's/^metalink=/#&/' -e 's@^#baseurl=.*@baseurl=http://mirrors.coreix.net/fedora-epel/7/$basearch@' /etc/yum.repos.d/epel.repo

# Install Java
yum update -y
yum install -y java-1.8.0-openjdk-devel python-pip gcc python-devel nmap-ncat jq rng-tools

# Spring Boot 2.0 using TomCat 8.5 requires tomcat-native.x86_64 installed to enable HTTP/2
sudo yum install tomcat-native.x86_64

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install awscli

yum remove -y gcc python-devel

systemctl enable rngd

sudo mkdir /opt/dks
sudo mkdir /var/log/dks

# Download & install latest DKS service artifact
VERSION="0.0.45"
URL="https://github.com/dwp/data-key-service/releases/download/${VERSION}/data-key-service-${VERSION}.jar"
echo "JAR_VERSION: $VERSION"
echo "JAR_DOWNLOAD_URL: $URL"
curl "$URL" -L -o /tmp/dks.jar
sudo useradd dks -m

sudo sh -c "echo ${VERSION} > /opt/dks/version"

sudo mv /tmp/dks.jar /opt/dks/
sudo cp /tmp/ami-builder/dks-host/server.properties   /opt/dks/
sudo cp /tmp/ami-builder/dks-host/dks                 /etc/init.d/

sudo chown dks:dks -R  /opt/dks
sudo chown dks:dks -R  /var/log/dks
sudo chmod u+x         /etc/init.d/dks
sudo chkconfig --add dks
sudo systemctl disable dks

# Disable the CloudHSM service from starting at startup so userdata has to enable it if needed
sudo systemctl disable cloudhsm-client

# Setup Logrotate
sudo cp /tmp/ami-builder/dks-host/dks.logrotate     /etc/logrotate.d/dks
