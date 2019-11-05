#!/bin/sh
set -eEuo pipefail

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
sed -i -e 's/^metalink=/#&/' -e 's@^#baseurl=.*@baseurl=http://mirrors.coreix.net/fedora-epel/7/$basearch@' /etc/yum.repos.d/epel.repo

# Install Java
yum install -y java-1.8.0-openjdk-devel python-pip gcc python-devel jq rng-tools

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install awscli

yum remove -y gcc python-devel --remove-leaves

systemctl enable rngd
