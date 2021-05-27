#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for ECS to work

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# Install JDK
yum install -y java-1.8.0-openjdk-devel

# Install Kafka binaries
mkdir /usr/local/kafka && cd /usr/local/kafka
curl "https://apache.mirrors.nublue.co.uk/kafka/2.6.2/kafka_2.13-2.6.2.tgz" -o /usr/local/kafka/kafka.tgz
tar -xvzf ~/Downloads/kafka.tgz --strip 1

# Download and Install Kafka Python Client Libs
pip3 install kafka-python
