#!/usr/bin/env bash

set -e

# disable firewall and selinux
sudo sed -i "/SELINUX=enforcing/c\SELINUX=permissive" /etc/selinux/config
sudo setenforce 0
sudo systemctl disable firewalld.service
sudo systemctl stop firewalld.service

# install docker and required packages
sudo yum install -y docker device-mapper-event-libs

# enable and start docker
sudo systemctl enable docker.service
sudo systemctl start docker.service


# allow connections to docker
export DOCKER_OPTIONS="'-H 0.0.0.0:2376 -H unix:///var/run/docker.sock'"
sudo sed -i "/OPTIONS=*/c\OPTIONS=$DOCKER_OPTIONS" /etc/sysconfig/docker
sudo systemctl restart docker.service