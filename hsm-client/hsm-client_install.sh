#!/bin/sh -x

## Script to install hsm-client service

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip

# Adding in netcat and jq for troubleshooting
sudo yum install -y nmap-ncat jq

# Download & install AWS-CLI
sudo pip install awscli

# Install HSM client, the SDK and dependencies
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-latest.el7.x86_64.rpm
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-pkcs11-latest.el7.x86_64.rpm
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-dyn-latest.el7.x86_64.rpm
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-jce-latest.el7.x86_64.rpm

sudo mkdir /opt/hsm-client
sudo mkdir /var/log/hsm-client

# Setup Logrotate
sudo cp /tmp/ami-builder/hsm-client/hsm-client.logrotate     /etc/logrotate.d/hsm-client
