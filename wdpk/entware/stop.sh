#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# stop all entware init.d services
/opt/etc/init.d/rc.unslung stop
