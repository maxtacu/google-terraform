#!/bin/bash -xe

RESOURCE_INDEX=$1
yum update -y
yum install -y nginx
IP=$(curl -s -H "Metadata-Flavor:Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
echo "Welcome to Resource ${RESOURCE_INDEX} - ${HOSTNAME} (${IP})" > /usr/share/nginx/html/index.html
service nginx start
