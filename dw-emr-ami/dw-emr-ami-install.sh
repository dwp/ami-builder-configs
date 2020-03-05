#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for EMR to work

# Make Concourse green again

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF
sed -i -e 's/selinux=0/selinux=1 enforcing=0/' /boot/grub/menu.lst

# Relax umask settings and defaults
sed -i 's/^.*umask 0.*$/umask 022/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 022/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 022/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 022/' /etc/init.d/functions
