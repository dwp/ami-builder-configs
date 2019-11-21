#!/bin/sh
set -eEu

## Script to prepare general Dataworks AMI

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Make changes to hardened-ami that are required for EMR to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF
sed -i -e 's/selinux=0/selinux=1 enforcing=0/' /boot/grub/menu.lst

# Relax umask settings adn defaults
sed -i 's/^.*umask 0.*$/umask 022/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 022/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 022/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 022/' /etc/init.d/functions
