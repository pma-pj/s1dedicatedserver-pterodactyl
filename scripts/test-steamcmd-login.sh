#!/bin/bash
set -e

export HOME=/home/container
export STEAMAPPDIR=/home/container

mkdir -p /home/container/steamcmd
if [ ! -f /home/container/steamcmd/steamcmd.sh ]; then
  cp -a /home/steam/steamcmd/. /home/container/steamcmd/
fi

cd /home/container/steamcmd
chmod +x steamcmd.sh linux32/steamcmd 2>/dev/null || true

./steamcmd.sh \
  +login "$STEAM_USER" "$STEAM_PASS" \
  +quit
