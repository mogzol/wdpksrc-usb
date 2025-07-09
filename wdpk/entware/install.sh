#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

NAS_PROG=$2

# copy the WD entware package to App
cp -rf "$APKG_PATH" "$NAS_PROG"

# create the entware root in a location that is not shared by samba
mkdir -p "$OPT_ROOT"
echo "APKG_DEBUG: mount $APP_DATA to /opt"
mount --bind "$OPT_ROOT" /opt

ARCH="$(uname -m)"
if [ "$ARCH" = "x86_64" ]; then
    ENT_ARCH="x64"
elif [ "$ARCH" = "armv5tel" ]; then
    ENT_ARCH="armv5sf"
else
    ENT_ARCH="armv7sf"
fi

echo "APKG_DEBUG: download and install entware-ng for $ARCH"
wget -O - "http://bin.entware.net/$ENT_ARCH-k3.2/installer/generic.sh" | /bin/sh

/opt/bin/opkg update
/opt/bin/opkg upgrade

echo "Restore WD service module paths"
WD_OPT=/usr/local/modules/opt/wd
ln -sf "$WD_OPT" /opt/wd

# Myron @ 28-01-2021 10:18 - On the DL4100 firefly and perl links are also in the /opt directory
# These directories are not in WD_OPT, but appear to be created during OS3 startup so replicate
# in entware install. (For some reason the perl link is broken. This works-round that issue.)
echo "Restore firefly and perl5 paths created during OS3 startup"
ln -sf "$OPT_ROOT/firefly" /usr/local/firefly
ln -sf "$OPT_ROOT/perl5" /usr/local/modules/perl5

echo "Unmount again"
umount /opt

echo "APKG_DEBUG: entware-ng install.sh ready"
