#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# restore orig docker
mv -f /usr/sbin/docker.bak /usr/sbin/docker

# remove bins
rm -rf /sbin/docker*

# remove mountpoint
rm -rf /var/lib/docker

# remove docker data
umount "$DOCKER_ROOT"
rm -rf "$DOCKER_ROOT"

# remove the app from Nas_Prog
rm -rf "$APKG_PATH"
