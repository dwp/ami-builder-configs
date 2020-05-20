#!/bin/sh
set -eEu

# Set Proxy
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

# Relax umask settings and defaults
sed -i 's/^.*umask 0.*$/umask 002/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 002/' /etc/init.d/functions

# Download and Install Concourse
concourse_version=6.1.0
concourse_tarball="concourse-$concourse_version-linux-amd64.tgz"
hostname -i
echo "Downloading $concourse_tarball"
curl -L -O https://github.com/concourse/concourse/releases/download/v$concourse_version/$concourse_tarball
echo "Downloaded $concourse_tarball"

tar -xvf $concourse_tarball -C /usr/local
rm $concourse_tarball