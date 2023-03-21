#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for EMR to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF
#sed -i -e 's/selinux=0/selinux=1 enforcing=0/' /boot/grub/menu.lst

#install pcre tools to provide access to pcregrep
yum install -y pcre-tools.x86_64

# Install Tenable
yum -y install NessusAgent --disablerepo=* --enablerepo tenable
/sbin/service nessusagent start  # starts and enables the service

# Relax umask settings and defaults
sed -i 's/^.*umask 0.*$/umask 002/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 002/' /etc/init.d/functions

# clean-up provision files
rm -rf /home/ec2-user/*


