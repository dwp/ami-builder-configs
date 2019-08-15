#!/bin/sh -x

## Script to install DKS service

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.8.0

# Install the AWS CloudHSM Client and Command Line Tools
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-latest.el7.x86_64.rpm

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip

# Spring Boot 2.0 using TomCat 8.5 requires tomcat-native.x86_64 installed to enable HTTP/2
sudo yum install tomcat-native.x86_64

# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
sudo yum install -y gcc
sudo yum install -y python-devel
sudo pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
sudo yum remove -y gcc python-devel

# Download & install AWS-CLI
sudo pip install awscli

sudo mkdir /opt/dks
sudo mkdir /var/log/dks

# Download & install latest DKS service artifact
VERSION=$(curl -s https://api.github.com/repos/dwp/data-key-service/releases/latest | grep browser_download_url |grep data-key-service | cut -d '/' -f 8)
URL="https://github.com/dwp/data-key-service/releases/download/${VERSION}/data-key-service-${VERSION}.jar"
echo "JAR_VERSION: $VERSION"
echo "JAR_DOWNLOAD_URL: $URL"
curl "$URL" -L -o /tmp/dks.jar
sudo useradd dks -m

sudo mv /tmp/dks.jar /opt/dks/
sudo cp /tmp/ami-builder/dks-host/server.properties   /opt/dks/
sudo cp /tmp/ami-builder/dks-host/dks.sh              /opt/dks/
sudo cp /tmp/ami-builder/dks-host/dks                 /etc/init.d/

sudo chown dks:dks -R  /opt/dks
sudo chown dks:dks -R  /var/log/dks
sudo chmod u+x         /etc/init.d/dks
sudo chmod u+x         /opt/dks/dks.sh
sudo chkconfig --add dks
sudo systemctl disable dks

# Setup Logrotate
sudo cp /tmp/ami-builder/dks-host/dks.logrotate     /etc/logrotate.d/dks
