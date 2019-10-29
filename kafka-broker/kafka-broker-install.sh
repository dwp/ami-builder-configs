#!/bin/sh -x

## Script to install a kafka & zookeeper broker

echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

# Install Amazon SSM agent - download 1st to avoid YUM proxy issues
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Configure YUM repos to point at fixed mirrors so requests through the proxy will work
sed -i -e 's/^mirrorlist=/#&/' -e 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/CentOS-Base.repo
yum --enablerepo=extras install -y epel-release
sed -i -e 's/^metalink=/#&/' -e 's@^#baseurl=.*@baseurl=http://mirrors.coreix.net/fedora-epel/7/$basearch@' /etc/yum.repos.d/epel.repo

# Install Java
# yum update -y
yum install -y java-1.8.0-openjdk-devel python-pip gcc python-devel nmap-ncat jq rng-tools

# Install acm cert helper
acm_cert_helper_repo=acm-pca-cert-generator
acm_cert_helper_version=0.11.0
pip install https://github.com/dwp/${acm_cert_helper_repo}/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz
pip install awscli

yum remove -y gcc python-devel

systemctl enable rngd

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
