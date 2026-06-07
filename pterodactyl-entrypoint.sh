#!/bin/bash
set -e

# Force all runtime-write paths into the Pterodactyl volume.
# Do not allow the upstream image defaults to point back to /home/steam,
# because Wings normally starts containers with a read-only root filesystem.
export HOME="/home/container"
export STEAMAPPDIR="/home/container"
export WINEPREFIX="/home/container/.wine"
export S1DS_RUNTIME="${S1DS_RUNTIME:-mono}"

mkdir -p /home/container
mkdir -p /home/container/.steam
mkdir -p /home/container/Steam/logs
mkdir -p /home/container/steamcmd
mkdir -p /home/container/.wine
mkdir -p /home/container/.local/share
mkdir -p /home/container/.config
mkdir -p /tmp/.X11-unix 2>/dev/null || true
chmod 1777 /tmp/.X11-unix 2>/dev/null || true

# Optional recovery switch for broken SteamCMD bootstrap state.
# Set RESET_STEAMCMD=true once, start the server, then set it back to false.
if [ "${RESET_STEAMCMD:-false}" = "true" ]; then
  echo "RESET_STEAMCMD=true: removing writable SteamCMD cache..."
  rm -rf /home/container/steamcmd /home/container/Steam/package
  mkdir -p /home/container/steamcmd /home/container/Steam/logs
fi

# SteamCMD must run from the writable /home/container volume.
# Running it from /home/steam can fail under Pterodactyl read-only rootfs.
if [ ! -f /home/container/steamcmd/steamcmd.sh ]; then
  echo "Copying SteamCMD to writable directory: /home/container/steamcmd"
  cp -a /home/steam/steamcmd/. /home/container/steamcmd/
fi

chmod +x /home/container/steamcmd/steamcmd.sh 2>/dev/null || true
chmod +x /home/container/steamcmd/linux32/steamcmd 2>/dev/null || true
chmod +x /home/container/steamcmd/linux64/steamcmd 2>/dev/null || true

cd /home/container

echo "Pterodactyl S1DS wrapper"
echo "  UID/GID: $(id)"
echo "  HOME=$HOME"
echo "  STEAMAPPDIR=$STEAMAPPDIR"
echo "  WINEPREFIX=$WINEPREFIX"
echo "  S1DS_RUNTIME=$S1DS_RUNTIME"
echo "  SteamCMD=/home/container/steamcmd/steamcmd.sh"
echo "  Server port=${SERVER_PORT:-38465}"
echo "  Server name=${SERVER_NAME:-Schedule I Dedicated Server}"

exec /bin/bash /usr/local/bin/s1ds-run.sh
