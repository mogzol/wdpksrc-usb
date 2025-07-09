#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

echo 'DOCKER START: start daemon'
"$APKG_PATH/daemon.sh" start

sleep 3

# Verify docker works
docker ps
