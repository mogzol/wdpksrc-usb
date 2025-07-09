#!/bin/bash

# Stop and remove the old container
docker stop portainer
docker rm portainer

# Download the latest container build from dockerhub
docker pull portainer/portainer-ce:latest

./install_portainer.sh
