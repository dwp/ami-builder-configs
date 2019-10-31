#!/bin/sh
set -eEuo pipefail

## Script to prepare general Dataworks AMI

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
