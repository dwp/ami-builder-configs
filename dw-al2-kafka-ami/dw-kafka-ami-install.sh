#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for ECS to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# Enable ssm agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install Kafka binaries
mkdir /usr/local/kafka && cd /usr/local/kafka
curl "http://archive.apache.org/dist/kafka/2.6.2/kafka_2.12-2.6.2.tgz" -o /usr/local/kafka/kafka.tgz
tar -xvzf /usr/local/kafka/kafka.tgz --strip 1

# Download and Install Kafka Python Client Libs
pip3 install kafka-python
