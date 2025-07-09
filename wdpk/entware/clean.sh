#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# ensure services are stopped
/opt/etc/init.d/rc.unslung stop

rm /etc/profile

# remove symlink to home dir
rm /home/root
mkdir /home/root
chown root:root /home/root

# umount, the original /opt mount becomes visible again
if ! umount /opt ; then
   echo "Entware clean umount failed"
   fuser -cv /opt
   echo "Kill them all"
   fuser -ck /opt
   sleep 2
   umount /opt
fi

# remove bin

# remove lib

# remove web
rm -f /var/www/apps/entware
rm -f /var/www/cgi-bin/entware.py
