#!/bin/sh -x

export SPRING_PROFILES_ACTIVE=AWS,KMS,SECURE
java -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Ddks.log.directory=/var/log/dks -Ddks.log.level.console=WARN -Ddks.log.level.file=INFO -jar /opt/dks/dks.jar
