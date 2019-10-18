#!/bin/sh -x

## Script to prepare general Dataworks AMI

[ ! -z $HTTP_PROXY ] && pip_http_proxy=" --proxy $(echo $HTTP_PROXY | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g')"

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.10.0

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip

# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
sudo yum install -y gcc
sudo yum install -y python-devel
sudo pip install$pip_http_proxy https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
sudo yum remove -y gcc python-devel

# Adding in netcat and jq for troubleshooting
sudo yum install -y nmap-ncat jq

# Download & install AWS-CLI
sudo pip install$pip_http_proxy awscli

# rngd is required to generate some entropy without a long wait
sudo yum install -y rng-tools
sudo systemctl enable rngd
