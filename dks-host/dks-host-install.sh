#!/bin/sh -x

## Script to install DKS service

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

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

sudo chmod u+x         /etc/init.d/dks
sudo chown dks:dks -R  /opt/dks
sudo chown dks:dks -R  /var/log/dks

sudo chkconfig --add dks
