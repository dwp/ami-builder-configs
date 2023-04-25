#!/bin/sh
set -eEu

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# write amzn2-extras repo file with fixed base url
# this is a temp work around, may need little elegant solution
cat > /etc/yum.repos.d/amzn2-extras.repo << AMZN2EXTRAS
[amzn2extra-ecs]
enabled = 1
name = Amazon Extras repo for ecs
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2
priority = 10
skip_if_unavailable = 1
report_instanceid = yes
AMZN2EXTRAS
curl -O "http://amazonlinux.eu-west-2.amazonaws.com/2/extras/ecs/latest/x86_64/mirror.list"
echo "baseurl=$(cat mirror.list)" >> /etc/yum.repos.d/amzn2-extras.repo && rm -f mirror.list

cat >> /etc/yum.repos.d/amzn2-extras.repo << AMZN2EXTRAS
[amzn2extra-epel]
enabled = 1
name = Amazon Extras repo for epel
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2
priority = 10
skip_if_unavailable = 1
report_instanceid = yes
AMZN2EXTRAS
curl -O "http://amazonlinux.eu-west-2.amazonaws.com/2/extras/epel/latest/x86_64/mirror.list"
echo "baseurl=$(cat mirror.list)" >> /etc/yum.repos.d/amzn2-extras.repo && rm -f mirror.list

cat /etc/yum.repos.d/amzn2-extras.repo


sudo yum install -y ecs-init jq
sudo yum install -y ecs-init-1.68.2-1.amzn2.x86_64

systemctl enable --now ecs amazon-ecs-volume-plugin

# import gpg keys: draios & epel7
rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
rpm --import https://download.sysdig.com/DRAIOS-GPG-KEY.public

# setup draio & epel repo files
curl -s -o /etc/yum.repos.d/draios.repo https://download.sysdig.com/stable/rpm/draios.repo
cat > /etc/yum.repos.d/epel.repo << EPEL
[epel]
name=Extra Packages for Enterprise Linux 7 - x86_64
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=x86_64
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
EPEL

# install sysdig and s3fs
yum install -y sysdig s3fs-fuse

# Install Tenable
yum -y install NessusAgent --disablerepo=* --enablerepo tenable
/sbin/service nessusagent start  # starts and enables the service

# accept anything that wasn't specifically covered
# temp change until we configure iptables to mirror sg
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# flushing all rules
iptables -F

# presisting rules for next boot
service iptables save
