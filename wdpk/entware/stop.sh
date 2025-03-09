#!/bin/bash
source "$1/common.sh"

# stop all entware init.d services
/opt/etc/init.d/rc.unslung stop
