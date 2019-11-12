#!/bin/sh
set -eEu

## Script to prepare general Dataworks AMI

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Update packages on the instance.
yum update -y

# Install Yum plugin that will remove unused dependancies after a package is uninstalled
yum install -y yum-plugin-remove-with-leaves

sed -i -e 's/repo_upgrade: security/repo_upgrade: none/' /etc/cloud/cloud.cfg
yum-config-manager --enable epel

yum install -y python-devel python-pip gcc
# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install --upgrade awscli

yum remove -y gcc python-devel java-1.7.0 --remove-leaves

echo "export PATH=$PATH:/usr/local/bin" >> /etc/environment
