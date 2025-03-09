#!/bin/bash
source "$1/common.sh"

# remove /opt from shell path
rm -f /etc/profile

# (un)comment these to control what's deleted on uninstallation
# rm -rf "$HOME_ROOT"
rm -rf "$OPT_ROOT"
# rm -rf "$DATA_ROOT/entware"

# Remove the app from Nas_Prog
rm -rf "$APKG_PATH"

# APKG should run the clean script before this one, which handles all other cleanup
