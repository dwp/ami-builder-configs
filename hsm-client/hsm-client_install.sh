#!/bin/sh -x

## Script to install hsm-client service

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install HSM client, the SDK and dependencies
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-latest.el7.x86_64.rpm
sudo yum install -y https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/EL7/cloudhsm-client-jce-latest.el7.x86_64.rpm

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

# Disable the service from starting at startup
systemctl disable cloudhsm-client

# Setup Logrotate
sudo cp /tmp/ami-builder/hsm-client/hsm-client.logrotate     /etc/logrotate.d/hsm-client
