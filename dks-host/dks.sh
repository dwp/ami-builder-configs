#!/bin/sh -x

export SPRING_PROFILES_ACTIVE=AWS,KMS,INSECURE
java -jar /opt/dks/dks.jar
