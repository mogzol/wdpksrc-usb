#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

echo 'DOCKER stop: stop daemon'
"$APKG_PATH/daemon.sh" shutdown

sleep 1

echo "Remaining mounts:"
grep docker /proc/self/mounts
