#!/usr/bin/env bash

# Refer to the docker installation guide on ubuntu: https://docs.docker.com/installation/ubuntulinux/
DOCKER_VERSION='1.8.2-0~trusty'

# Install GPG key
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add docker apt source
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list

# Update local apt cache
apt-get -qq update

# Install docker
apt-get install -y \
  docker-engine=${DOCKER_VERSION}
