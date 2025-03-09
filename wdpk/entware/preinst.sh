#!/bin/bash
source "$1/common.sh"

# invalidate old entware installation leftovers
# restore them if necessary
ENTWARE_ROOT=$DATA_ROOT/$APP_NAME
BACKUP=$ENTWARE_ROOT.bak
[[ -d "$ENTWARE_ROOT" ]] && mv "$ENTWARE_ROOT" "$BACKUP"
