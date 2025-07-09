#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# restore startup script
[ -f /usr/sbin/docker_daemon.sh.bak ] && mv -f /usr/sbin/docker_daemon.sh.bak /usr/sbin/docker_daemon.sh

# remove binaries

# remove lib symlink
rm -f /var/lib/docker

# remove web
rm -f /var/www/docker
