#!/bin/bash
# Common code that is sourced by every script
# shellcheck disable=SC2034

APP_NAME=example
LOG=/tmp/apkg_$APP_NAME.log
APKG_PATH=$1

# Delete existing log if it hasn't been modified in the last week
find "$LOG" -mtime +7 -delete

# Ensure /dev/fd works (for process substitution)
ln -sfn /proc/self/fd /dev/fd

# Tee STDOUT and STDERR to log file
exec > >(tee -ia $LOG) 2>&1

echo "$(date -Iseconds) APKG_DEBUG: $0 $*"

set -xo pipefail
