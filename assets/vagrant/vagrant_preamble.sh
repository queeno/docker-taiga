#!/usr/bin/env bash

# Refer to the docker installation guide on ubuntu: https://docs.docker.com/installation/ubuntulinux/
DOCKER_VERSION='1.8.2-0~trusty'

# Install GPG key
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add docker apt source
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list

# Update local apt cache
apt-get -qq update

# Install docker (and JSON Parser)
apt-get install -y \
  jq \
  docker-engine=${DOCKER_VERSION}

# Build the taiga docker container
cd /vagrant
./build.sh

# Run the postgres container
docker run -d --name postgres postgres

# Sleep for 5 seconds to allow postgres to start
sleep 5

# Initialise the database
docker exec postgres sh -c "su postgres --command 'createuser -d -r -s taiga'"
docker exec postgres sh -c "su postgres --command 'createdb -O taiga taiga'"

# Run taiga
docker run -d -p 8000:8000 --name taiga --link postgres:postgres ipedrazas/taiga

# Populate the database
docker exec taiga bash regenerate.sh

# Symlink the docker volumes in /root
DOCKER_INSPECT="$(docker inspect taiga)"

MOUNT0=($(echo ${DOCKER_INSPECT} | tee >(jq -r ".[0].Mounts[0].Source") >(jq -r ".[0].Mounts[0].Destination") 1> /dev/null))
MOUNT1=($(echo ${DOCKER_INSPECT} | tee >(jq -r ".[0].Mounts[1].Source") >(jq -r ".[0].Mounts[1].Destination") 1> /dev/null))
MOUNT2=($(echo ${DOCKER_INSPECT} | tee >(jq -r ".[0].Mounts[2].Source") >(jq -r ".[0].Mounts[2].Destination") 1> /dev/null))

ln -s "${MOUNT0[1]}" "/root/$(basename ${MOUNT0[0]})"
ln -s "${MOUNT1[1]}" "/root/$(basename ${MOUNT1[0]})"
ln -s "${MOUNT2[1]}" "/root/$(basename ${MOUNT2[0]})"
