#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

echo "Entware init.sh linking files from path: $APKG_PATH"

# create link to binary...
OPKG=/opt/bin/opkg
if [ ! -f "$OPKG" ]; then
	[ ! -d "$OPT_ROOT" ] && echo "Entware root dir not found!" && exit 1
	mount --bind "$OPT_ROOT" /opt
	echo "Mounted Entware root to /opt"
fi

# update profile
PROFILE=/etc/profile
[ ! -f "$PROFILE" ] && cp "$APKG_PATH/profile" $PROFILE

# restore home dir
HOME=/home/root
if [ ! -L "$HOME" ]; then
	echo "Setup persistent home directory"
	rm -rf "$HOME"
	mkdir -p "$HOME_ROOT"
	ln -sf "$HOME_ROOT" "$HOME"
	chown -R root:root "$HOME"
	chown -R root:root "$HOME_ROOT"

  if [ -d "$ENTWARE_ROOT.bak" ]; then
    echo "Previous installation found, restoring home directory..."
    cp -a "$ENTWARE_ROOT.bak/home/." "$HOME_ROOT"
    echo "NOTE: Apps from the previous installation will not be restored! Re-install them manually."
  fi
fi

WEB_PATH=/var/www
mkdir -p "$WEB_PATH/apps"
ln -sfn "$APKG_PATH/web" "$WEB_PATH/apps/entware"
ln -sf "$APKG_PATH/cgi-bin/entware.py" $WEB_PATH/cgi-bin
echo "Created Entware web dir symlink"
