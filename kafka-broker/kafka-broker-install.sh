#!/bin/sh

## Script to install a kafka & zookeeper broker inc: Java

# Java(TM) SE Runtime Environment (build 1.8.0_181-b13Java(TM)
# Install Java
	sudo yum install -y java-1.8.0-openjdk-devel

# Install kafka & zookeeper
	sudo useradd kafka -m
	cd /usr/local
	mkdir kafka
	chown kafka:kafka -R /usr/local/kafka
 	curl "http://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
	tar -xvzf /tmp/kafka.tgz --strip 1
	chmod u+x /usr/local/kafka/bin/zookeeper-server-start.sh
    chmod u+x /usr/local/kafka/bin/kafka-server-start.sh
