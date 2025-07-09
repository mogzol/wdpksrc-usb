#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# invalidate old entware installation leftovers
# restore them if necessary
BACKUP=$ENTWARE_ROOT.bak
[[ -d "$ENTWARE_ROOT" ]] && mv "$ENTWARE_ROOT" "$BACKUP"
