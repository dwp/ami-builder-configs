#!/bin/sh

## Script to install a kafka & zookeeper broker inc: Java
# Java(TM) SE Runtime Environment (build 1.8.0_181-b13Java(TM)
	sudo yum install -y java-1.8.0-openjdk-devel

# Install kafka & zookeeper
	sudo useradd kafka -m
	cd /usr/local
	mkdir kafka && cd kafka
	chown kafka:kafka /usr/local/kafka
 	curl "http://www-eu.apache.org/dist/kafka/1.0.2/kafka_2.12-1.0.2.tgz" -o /tmp/kafka.tgz
	tar -xvzf /tmp/kafka.tgz --strip 1
	cd /usr/local/kafka
	chown -R kafka:kafka *

 # Build Kafka config file
       >/usr/local/kafka/config/server.properties

 	echo "broker.id=0" 			          >> /usr/local/kafka/config/server.properties
 	echo "num.network.threads=3" 		          >> /usr/local/kafka/config/server.properties
 	echo "num.io.threads=8" 		          >> /usr/local/kafka/config/server.properties
 	echo "socket.send.buffer.bytes=102400" 	          >> /usr/local/kafka/config/server.properties
 	echo "socket.receive.buffer.bytes=102400"         >> /usr/local/kafka/config/server.properties
 	echo "socket.request.max.bytes=104857600" 	  >> /usr/local/kafka/config/server.properties
 	echo "log.dirs=/tmp/kafka-logs" 		  >> /usr/local/kafka/config/server.properties
 	echo "num.partitions=1" 			  >> /usr/local/kafka/config/server.properties
 	echo "num.recovery.threads.per.data.dir=1" 	  >> /usr/local/kafka/config/server.properties
 	echo "offsets.topic.replication.factor=1" 	  >> /usr/local/kafka/config/server.properties
 	echo "transaction.state.log.replication.factor=1" >> /usr/local/kafka/config/server.properties
 	echo "transaction.state.log.min.isr=1"            >> /usr/local/kafka/config/server.properties
 	echo "log.retention.hours=168"                    >> /usr/local/kafka/config/server.properties
 	echo "log.segment.bytes=1073741824"               >> /usr/local/kafka/config/server.properties
 	echo "log.retention.check.interval.ms=300000"     >> /usr/local/kafka/config/server.properties
 	echo "zookeeper.connect=localhost:2181"           >> /usr/local/kafka/config/server.properties
 	echo "zookeeper.connection.timeout.ms=6000"       >> /usr/local/kafka/config/server.properties
 	echo "group.initial.rebalance.delay.ms=0"         >> /usr/local/kafka/config/server.properties
        chown kafka:kafka                                    /usr/local/kafka/config/server.properties

# Start Zookeeper & Kafka service
	chmod u+x /usr/local/kafka/bin/zookeeper-server-start.sh
	chmod u+x /usr/local/kafka/bin/kafka-server-start.sh
	/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties &
sleep 10
	/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
