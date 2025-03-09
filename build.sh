#!/bin/sh
set -eu

APP_DIR="$(realpath "$1")"
SCRIPT_DIR="$(dirname "$0")"
APP_NAME="$(basename "$APP_DIR")"

cd "$APP_DIR"
VERSION="$(awk '/Version/{print $NF}' apkg.rc)"

echo "Building ${APP_NAME} version ${VERSION}"

RELEASE_DIR="${SCRIPT_DIR}/packages/${APP_NAME}"
mkdir -p "${RELEASE_DIR}"

# Currently only outputting for the EX4100. Update this variable to include other outputs.
# MODELS="WDMyCloudEX4100-EX4100 WDMyCloudDL4100-DL4100 WDMyCloudEX2100-EX2100
#         WDMyCloudDL2100-DL2100 WDMyCloudMirror-MirrorG2 MyCloudEX2Ultra-EX2Ultra
#         MyCloudPR4100-PR4100 MyCloudPR2100-PR2100"
MODELS="WDMyCloudEX4100-EX4100"

for fullmodel in $MODELS; do
  model=${fullmodel%-*}
  name=${fullmodel#*-}
  "${SCRIPT_DIR}/mksapkg-OS5" -E -s -m $model
  mv ../${model}*.bin* "${RELEASE_DIR}/${APP_NAME}_${VERSION}_${name}.bin"
done

echo "Built ${APP_NAME} version ${VERSION}"
