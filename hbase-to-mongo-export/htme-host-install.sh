#!/bin/sh -x

## Script to install htme service

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

sudo mkdir /opt/htme
sudo mkdir /var/log/htme

# rngd is required to generate some entropy without a long wait
sudo yum install -y rng-tools
sudo systemctl enable rngd

# Download & install latest hbase-to-mongo-export service artifact
VERSION=$(curl -s https://api.github.com/repos/dwp/hbase-to-mongo-export/releases/latest | grep browser_download_url |grep hbase-to-mongo-export | cut -d '/' -f 8)
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
