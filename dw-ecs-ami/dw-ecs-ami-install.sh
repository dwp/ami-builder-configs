#!/bin/sh
set -eEu

# Set Proxy
echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Make changes to hardened-ami that are required for ECS to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF
sed -i -e 's/selinux=0/selinux=1 enforcing=0/' /boot/grub/menu.lst

# Download and Install ECS Agent
yum update
yum install -y ecs-init
service docker start
start ecs
