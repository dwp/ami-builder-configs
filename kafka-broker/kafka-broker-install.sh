#!/bin/sh

## Script to install a kafka & zookeeper broker

# Install kafka & zookeeper
sudo useradd kafka -m

cd /usr/local && mkdir kafka
chown kafka:kafka -R /usr/local/kafka
curl "http://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
tar -xvzf /tmp/kafka.tgz --strip 1
cp /tmp/kafka-broker/kafka /etc/init.d
cp /tmp/kafka-broker/zookeeper /etc/init.d
yum install -y java-1.8.0-openjdk-devel
cp /tmp/zookeeper     /etc/rc.d/init.d
cp /tmp/kafka         /etc/rc.d/init.d
cp /tmp/server.properties     /usr/local/kafka/config
touch  /var/log/kafka/zookeeper.out /var/log/kafka/zookeeper.err /var/log/kafka/kafka.out /var/log/kafka/kafka.err
chmod u+x             /etc/rc.d/init.d/zookeeper
chmod u+x             /etc/rc.d/init.d/kafka
chmod u+x             /usr/local/kafka/bin/zookeeper-server-start.sh
chmod u+x             /usr/local/kafka/bin/kafka-server-start.sh
chmod u+x             /etc/rc.d/rc.local
chown kafka:kafka -R  /usr/local/kafka
chown kafka:kafka -R  /var/log/kafka
chown kafka:kafka -R  /tmp/zookeeper
chown kafka:kafka -R  /tmp/kafka-logs
chkconfig zookeeper on
chkconfig kafka on
