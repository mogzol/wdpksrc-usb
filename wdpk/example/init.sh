#!/bin/bash
source "$1/common.sh"

mkdir -p /var/www/apps
ln -s "$APKG_PATH/web" /var/www/apps/example
