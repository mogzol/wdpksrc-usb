#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# disable default docker by moving the original start script
[ -L /usr/sbin/docker_daemon.sh ] && mv /usr/sbin/docker_daemon.sh /usr/sbin/docker_daemon.sh.bak
[ -L /usr/sbin/docker ] && mv /usr/sbin/docker /usr/sbin/docker.bak

# create folder for the redirecting webpage
WEB_PATH="/var/www/docker"
ln -sfn "$APKG_PATH/web" "$WEB_PATH"
