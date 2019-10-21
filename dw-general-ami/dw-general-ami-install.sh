#!/bin/sh
set -eEuo pipefail

## Script to prepare general Dataworks AMI

# Install Java
#yum update -y
#yum install -y java-1.8.0-openjdk-devel

# Install Amazon SSM agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.10.0

# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
yum --enablerepo=extras install -y epel-release
yum install -y python-pip

# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
yum install -y gcc
yum install -y python-devel
pip -vvv install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
yum remove -y gcc python-devel

# Adding in netcat and jq for troubleshooting
yum install -y nmap-ncat jq

# Download & install AWS-CLI
pip install awscli

# rngd is required to generate some entropy without a long wait
yum install -y rng-tools
systemctl enable rngd
