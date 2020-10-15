#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for Concourse to work

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

# Download and Install Concourse
CONCOURSE_VERSION=$CONCOURSE_VERSION
CONCOURSE_TARBALL="concourse-$CONCOURSE_VERSION-linux-amd64.tgz"
curl -s -L -O https://github.com/concourse/concourse/releases/download/v$CONCOURSE_VERSION/$CONCOURSE_TARBALL
tar -xzf $CONCOURSE_TARBALL -C /usr/local
rm $CONCOURSE_TARBALL
