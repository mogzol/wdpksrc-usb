#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

echo init

mkdir -p /var/www/apps
ln -s "$APKG_PATH/web" /var/www/apps/example
