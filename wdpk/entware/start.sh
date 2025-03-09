#!/bin/bash
source "$1/common.sh"

# start all entware init.d services
/opt/etc/init.d/rc.unslung start
