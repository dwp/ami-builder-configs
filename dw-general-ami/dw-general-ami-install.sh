#!/bin/sh
set -eEuo pipefail

## Script to prepare general Dataworks AMI

# Install Amazon SSM agent - download 1st to avoid YUM proxy issues
curl -O https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm
rm -f amazon-ssm-agent.rpm

yum --enablerepo=extras install -y epel-release

# Install Java
yum update -y
yum install -y java-1.8.0-openjdk-devel python-pip gcc python-devel nmap-ncat jq rng-tools

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.10.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install awscli

yum remove -y gcc python-devel

systemctl enable rngd
