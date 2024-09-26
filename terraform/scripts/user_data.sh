#!/bin/bash
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz
tar -xvf kafka_2.12-3.8.0.tgz
yum install java-1.8.0-openjdk -y
java -version
