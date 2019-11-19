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

# Install Yum plugin that will remove unused dependencies after a package is uninstalled
yum install -y yum-plugin-remove-with-leaves

# Disable default caching of repo metadata
# EPEL is particularly fast moving so can have trouble getting packages/metadata files
# The Amazon Linux repos have caching specified in their individual .repo files
sed -i -e 's/# metadata_expire=.*/metadata_expire=0/' /etc/yum.conf

# Tidy cloud.cfg to prevent yum locks in hardened AMI builds
sed -i.bak -e 's/repo_upgrade: security/repo_upgrade: none/' \
       -e 's/repo_upgrade_exclude:/repo_update: false/' \
       -e '/.-.nvidia.*/ d' \
       -e '/.-.kernel.*/ d' \
       -e '/.-.cudatoolkit.*/ d' /etc/cloud/cloud.cfg

sed -i -e 's/^mirrorlist=/#&/' -e 's@^#baseurl=.*@baseurl=http://mirrors.coreix.net/fedora-epel/6/$basearch@' /etc/yum.repos.d/epel.repo
yum-config-manager --enable epel

yum install -y python27-devel python27-pip gcc
# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install --upgrade awscli

yum remove -y gcc python27-devel java-1.7.0 --remove-leaves

echo "export PATH=$PATH:/usr/local/bin" >> /etc/environment

cat > /usr/local/bin/set_yum_proxy.sh << 'SETYUMPROXY'
TAG_NAME="internet_proxy"
INSTANCE_ID="`curl -s http://instance-data/latest/meta-data/instance-id`"
REGION="`curl -s http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
if [ -n "${TAG_VALUE}" ]; then
  sed -i -e "/^enabled=/a \
proxy=$TAG_VALUE" /etc/yum.repos.d/{amzn-*,epel*}.repo
fi
SETYUMPROXY
chmod 0700 /usr/local/bin/set_yum_proxy.sh

cat > /etc/cloud/cloud.cfg.d/15_yum_proxy.cfg << CLOUDCFG
bootcmd:
 - [ cloud-init-per, once, set-yum-proxy, /usr/local/bin/set_yum_proxy.sh ]
CLOUDCFG

# Force fresh YUM metadata retrieval when an instance first runs YUM
yum clean all
