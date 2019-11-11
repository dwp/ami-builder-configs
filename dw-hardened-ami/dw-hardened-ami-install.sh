#!/bin/sh
set -eEu

## Script to prepare general Dataworks AMI

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Java
yum install -y java-1.8.0-openjdk-devel python-devel jq rng-tools
yum remove -y gcc python-devel java-1.7.0 --remove-leaves
chkconfig rngd on
