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

sudo yum install -y ecs-init
systemctl enable --now ecs

# Install Sysdig
rpm --import https://download.sysdig.com/DRAIOS-GPG-KEY.public
curl -s -o /etc/yum.repos.d/draios.repo https://download.sysdig.com/stable/rpm/draios.repo
yum install -y sysdig s3fs-fuse

# accept anything that wasn't specifically covered
# temp change until we configure iptables to mirror sg
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
