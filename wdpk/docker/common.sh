#!/bin/bash
# Common code that is sourced by every script
# shellcheck disable=SC2034

APP_NAME=docker
DATA_ROOT=/mnt/USB/USB1_a1
DOCKER_ROOT=$DATA_ROOT/$APP_NAME
LOG=/tmp/apkg_$APP_NAME.log
APKG_PATH=$1

# If we're not connected to a terminal, set up logging to $LOG
if ! [ -t 0 ] && [ -z "$APKG_LOGGING_SETUP" ]; then
    # Delete existing log if it hasn't been modified in the last week
    find "$LOG" -mtime +7 -delete

    # Ensure /dev/fd works (for process substitution)
    ln -sfn /proc/self/fd /dev/fd

    # Tee STDOUT and STDERR to log file
    exec > >(tee -ia $LOG) 2>&1

    echo "$(date -Iseconds) APKG_DEBUG: $0 $*"
    export APKG_LOGGING_SETUP=true

    set -xo pipefail
fi

# Ensure DATA_ROOT exists
if [ ! -d "$DATA_ROOT" ]; then
    echo "APKG_ERROR: DATA_ROOT does not exist: $DATA_ROOT"
    echo "Continuing, but there will probably be issues..."
fi
