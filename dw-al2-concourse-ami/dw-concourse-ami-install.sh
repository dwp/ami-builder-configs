#!/bin/sh
set -eEu

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# Relax umask settings and defaults
sed -i 's/^.*umask 0.*$/umask 002/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 002/' /etc/init.d/functions

# Install Tenable
yum -y install NessusAgent --disablerepo=* --enablerepo tenable
/sbin/service nessusagent start  # starts and enables the service

# Download and Install Concourse
CONCOURSE_TARBALL=$(find /tmp -type f -name *.tgz)
tar -xzf $CONCOURSE_TARBALL -C /usr/local
rm $CONCOURSE_TARBALL
