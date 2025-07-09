#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

# define docker version
VERSION="26.1.4"
COMPOSE_VERSION="2.38.2"

NAS_PROG=$2
APP_PATH="$NAS_PROG/$APP_NAME"

echo "Installing from $APKG_PATH to $APP_PATH"

# install all package scripts to the proper location
cp -rf "$APKG_PATH" "$NAS_PROG"

# get current architecture
ARCH="$(uname -m)"

if [ -d $DOCKER_ROOT ]; then
  if [ -d $DOCKER_ROOT/devicemapper ]; then
    echo "Found old docker devicemapper storage.. backup and create new docker root"
    mv "$DOCKER_ROOT" "$DOCKER_ROOT.bak"
    mkdir -p "$DOCKER_ROOT"
  else
    echo "Found existing docker storage. Reusing."
  fi
else
  echo "Creating new docker root"
  mkdir -p "$DOCKER_ROOT"
fi

# download docker binaries
cd "$DOCKER_ROOT" || exit 1
TARBALL="docker-${VERSION}.tgz"

if [ "$ARCH" != "x86_64" ]; then
    # As of docker 26.1.2 this appears to work with the docker provided binaries (at least on EX4100) so no need to compile it anymore
    DOCKER_ARCH="armhf"
    DC_ARCH="armv7"
else
    DOCKER_ARCH="$ARCH"
    DC_ARCH="$ARCH"
fi
URL="https://download.docker.com/linux/static/stable/$DOCKER_ARCH/$TARBALL"

# download and extract the package
if ! curl -L "${URL}" | tar xz; then
	echo "Failed to download/extract docker package"
	exit 1
fi

# setup binaries in PATH before the original v1.7 binaries
ln -sfn "$(readlink -f "$DOCKER_ROOT")"/docker/* /sbin

# start daemon
"$APP_PATH/daemon.sh" start

# install docker-compose
dc="$DOCKER_ROOT/docker/docker-compose"
curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-${DC_ARCH}" -o "$dc"
chmod +x "$dc"

# proof that everything works
docker ps

echo "Addon Docker (install.sh) done"
