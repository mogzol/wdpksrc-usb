#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# start all entware init.d services
/opt/etc/init.d/rc.unslung start
