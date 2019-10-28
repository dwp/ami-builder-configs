#!/bin/sh -x

## Script to install a kafka & zookeeper broker

# Install Java & AWS CLI
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel
sudo pip install awscli

# Install Amazon SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
# pip is not available in CentOS 7 core repositories there is a requirement to enable EPEL repositories prior
sudo yum --enablerepo=extras install -y epel-release
sudo yum install -y python-pip
# gcc and python-devel are required to enable the twofish indirect dependency -
# of acm-pca-cert-generator to be built and installed
sudo yum install -y gcc
sudo yum install -y python-devel
sudo pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
sudo yum remove -y gcc python-devel

# Install kafka & zookeeper
sudo useradd kafka -m
sudo mkdir /usr/local/kafka
sudo chown kafka:kafka -R /usr/local/kafka
sudo curl "https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz" -o /tmp/kafka.tgz
sudo tar -xvzf /tmp/kafka.tgz --strip 1 --directory /usr/local/kafka
sudo cp /tmp/ami-builder/kafka-broker/zookeeper     /etc/init.d
sudo cp /tmp/ami-builder/kafka-broker/kafka         /etc/init.d
sudo cp /tmp/ami-builder/kafka-broker/server.properties     /usr/local/kafka/config
sudo mkdir /var/log/kafka
sudo mkdir /tmp/kafka-logs
sudo mkdir /tmp/zookeeper
sudo touch  /var/log/kafka/zookeeper.out /var/log/kafka/zookeeper.err /var/log/kafka/kafka.out /var/log/kafka/kafka.err
sudo chmod u+x             /etc/init.d/zookeeper
sudo chmod u+x             /etc/init.d/kafka
sudo chmod u+x             /usr/local/kafka/bin/zookeeper-server-start.sh
sudo chmod u+x             /usr/local/kafka/bin/kafka-server-start.sh
sudo chown kafka:kafka -R  /usr/local/kafka
sudo chown kafka:kafka -R  /var/log/kafka
sudo chown kafka:kafka -R  /tmp/zookeeper
sudo chown kafka:kafka -R  /tmp/kafka-logs
sudo chkconfig --add zookeeper
sudo chkconfig --add kafka
# Prevent Kafka startup until it's fully configured by userdata script
sudo systemctl disable zookeeper
sudo systemctl disable kafka
