#!/bin/sh -x

## Script to install DKS service

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip
# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
sudo yum install -y gcc
sudo yum install -y python-devel
sudo pip install https://github.com/dwp/acm-pca-cert-generator/releases/download/${acm_pca_cert_generator_version}/acm_pca_cert_generator-${acm_pca_cert_generator_version}.tar.gz
sudo yum remove -y gcc python-devel

# Download & install AWS-CLI
sudo yum install -y unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo /usr/local/bin/python2.7 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
export PATH=/home/ec2-user/.local/bin:$PATH

# Download & install latest DKS service artifact
URL=`curl -s https://api.github.com/repos/dwp/data-key-service/releases/latest \
  | grep browser_download_url \
  | grep data-key-service  \
  | cut -d '"' -f 4`
curl "$URL" -L -o /tmp/dks.jar
sudo useradd dks -m

sudo mkdir /opt/dks
sudo mkdir /var/log/dks
sudo mv /tmp/dks.jar /opt/dks/
sudo cp /tmp/ami-builder/dks-host/server.properties   /opt/dks/
sudo cp /tmp/ami-builder/dks-host/dks.sh              /opt/dks/
sudo cp /tmp/ami-builder/dks-host/dks                 /etc/init.d/

sudo chown dks:dks -R  /opt/dks
sudo chown dks:dks -R  /var/log/dks
sudo chmod u+x         /etc/init.d/dks
sudo chmod u+x         /opt/dks/dks.sh
sudo chkconfig --add dks

# Setup Logrotate
sudo cp /tmp/ami-builder/dks-host/dks.logrotate     /etc/logrotate.d/dks
