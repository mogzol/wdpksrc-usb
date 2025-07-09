#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

docker ps -a | grep portainer-ce
if [ $? = 1 ]; then
    docker run -d -p 9000:9000 --restart always \
               --name portainer -v /var/run/docker.sock:/var/run/docker.sock \
               -v "$DOCKER_ROOT/portainer:/data" portainer/portainer-ce
fi

docker ps -a
