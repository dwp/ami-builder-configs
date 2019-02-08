#!/bin/sh -x

## Script to install a kafka & zookeeper broker

# Install Java

sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel

# Install kafka & zookeeper
sudo useradd kafka -m
sudo mkdir /usr/local/kafka
sudo chown kafka:kafka -R /usr/local/kafka
sudo curl "https://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
sudo tar -xvzf /tmp/kafka.tgz --strip 1 --directory /usr/local/kafka
sudo mkdir /var/log/kafka
sudo mkdir /tmp/zookeeper
sudo touch  /var/log/kafka/zookeeper.out /var/log/kafka/zookeeper.err /var/log/kafka/kafka.out /var/log/kafka/kafka.err
sudo chown kafka:kafka -R  /usr/local/kafka
sudo chown kafka:kafka -R  /var/log/kafka
sudo chown kafka:kafka -R  /tmp/zookeeper
sudo chown kafka:kafka -R  /tmp/kafka-logs

sudo find / -name server.properties -print
