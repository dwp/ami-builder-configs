#!/bin/sh -x

export SPRING_PROFILES_ACTIVE=AWS,KMS,INSECURE
java -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -jar /opt/dks/dks.jar