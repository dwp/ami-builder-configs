#!/bin/sh -x

## Script to install a kafka & zookeeper broker

# Install Java
###sudo yum update -y
####sudo yum install -y java-1.8.0-openjdk-devel

# Install kafka & zookeeper
sudo useradd kafka -m
sudo mkdir /usr/local/kafka
sudo chown kafka:kafka -R /usr/local/kafka
sudo curl "https://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
sudo tar -xvzf /tmp/kafka.tgz --strip 1 --directory /usr/local/kafka
echo " Debugging content of /tmp/ami-builder/kafka-broker"
sudo ls -ltr /tmp/ami-builder
sudo ls -ltr /tmp/ami-builder/kafka-broker
echo " printing the heading of /tmp/ami-builder/kafka-broker/kafka"
sudo head -15 /tmp/ami-builder/kafka-broker/kafka
echo " printing the heading of /tmp/ami-builder/kafka-broker/zookeper"
sudo head -15 /tmp/ami-builder/kafka-broker/zookeper
echo " Starting copy zookeeper to /etc/init.d/"
sudo cp /tmp/ami-builder/kafka-broker/zookeeper     /etc/init.d
echo " Starting copy kafka to /etc/init.d/"
sudo cp /tmp/ami-builder/kafka-broker/kafka         /etc/init.d
sudo cp /tmp/ami-builder/kafka-broker/server.properties     /usr/local/kafka/config
###REMOVE THIS BLOCK LATER
###
#sudo cp /tmp/ami-builder/kafka-broker/zookeeper     /etc/rc.d/init.d
#sudo cp /tmp/ami-builder/kafka-broker/kafka         /etc/rc.d/init.d
#sudo cp /tmp/ami-builder/kafka-broker/rc.local     /etc/rc.d
#sudo chmod u+x             /etc/rc.d/rc.local
#sudo chmod u+x             /etc/rc.d/init.d/zookeeper
#sudo chmod u+x             /etc/rc.d/init.d/kafka
############################

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
echo "Checking permitions of file /etc/init.d/zookeeper"
sudo ls -ltr /etc/init.d/zookeeper
echo "Printing the head of file /etc/init.d/zookeeper"
sudo  head -15 /etc/init.d/zookeeper
echo "Checking permitions of file /etc/init.d/kafka"
sudo ls -ltr /etc/init.d/kafka
echo "Printing the head of file /etc/init.d/kafka"
sudo  head -15 /etc/init.d/kafka
sudo chkconfig --add zookeeper
sudo chkconfig --add kafka
sudo systemctl start zookeeper
sudo systemctl start kafka
