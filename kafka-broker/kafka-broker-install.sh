#!/bin/sh -x

## Script to install a kafka & zookeeper broker

# Install Java
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install kafka & zookeeper
sudo useradd kafka -m
sudo mkdir /usr/local/kafka
sudo chown kafka:kafka -R /usr/local/kafka
sudo curl "http://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
sudo cd /usr/local/kafka
sudo tar -xvzf /tmp/kafka.tgz --strip 1
sudo cp /tmp/ami-builder/kafka-broker/zookeeper     /etc/rc.d/init.d
sudo cp /tmp/ami-builder/kafka-broker/kafka         /etc/rc.d/init.d
sudo cp /tmp/ami-builder/kafka-broker/server.properties     /usr/local/kafka/config
sudo touch  /var/log/kafka/zookeeper.out /var/log/kafka/zookeeper.err /var/log/kafka/kafka.out /var/log/kafka/kafka.err
sudo chmod u+x             /etc/rc.d/init.d/zookeeper
sudo chmod u+x             /etc/rc.d/init.d/kafka
sudo chmod u+x             /usr/local/kafka/bin/zookeeper-server-start.sh
sudo chmod u+x             /usr/local/kafka/bin/kafka-server-start.sh
sudo chown kafka:kafka -R  /usr/local/kafka
sudo chown kafka:kafka -R  /var/log/kafka
sudo chown kafka:kafka -R  /tmp/zookeeper
sudo chown kafka:kafka -R  /tmp/kafka-logs
sudo chkconfig zookeeper on
sudo chkconfig kafka on
