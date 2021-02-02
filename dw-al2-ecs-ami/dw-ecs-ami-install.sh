#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for ECS to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# Download and Install ECS Agent
amazon-linux-extras disable docker
amazon-linux-extras enable -y ecs
yum install -y ecs-int
systemctl enable --now ecs

# Install Sysdig

amazon-linux-extras install -y epel
rpm --import https://download.sysdig.com/DRAIOS-GPG-KEY.public
curl -s -o /etc/yum.repos.d/draios.repo https://download.sysdig.com/stable/rpm/draios.repo
yum install -y sysdig s3fs-fuse
