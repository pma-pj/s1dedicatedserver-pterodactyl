#!/bin/bash
set -e

export STEAMAPPDIR="${STEAMAPPDIR:-/home/container}"
export S1DS_RUNTIME="${S1DS_RUNTIME:-mono}"

export STEAM_ROOT="${STEAM_ROOT:-/home/container/steam}"
export HOME="$STEAM_ROOT"
export WINEPREFIX="${WINEPREFIX:-$STEAM_ROOT/wineprefix}"

export STEAMCMD_DIR="$STEAM_ROOT/steamcmd"
export STEAMWORKS_REDIST_DIR="$STEAM_ROOT/steamworks_redist"

mkdir -p /home/container
mkdir -p "$STEAM_ROOT"
mkdir -p "$STEAMCMD_DIR"
mkdir -p "$STEAMWORKS_REDIST_DIR"
mkdir -p "$STEAM_ROOT/Steam"
mkdir -p "$STEAM_ROOT/.steam"
mkdir -p "$STEAM_ROOT/.local/share"
mkdir -p "$STEAM_ROOT/.config"
mkdir -p "$WINEPREFIX"

if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
  echo "Copying SteamCMD to writable directory: $STEAMCMD_DIR"
  cp -a /home/steam/steamcmd/. "$STEAMCMD_DIR/"
fi

chmod +x "$STEAMCMD_DIR/steamcmd.sh" || true
chmod +x "$STEAMCMD_DIR/linux32/steamcmd" || true
chmod +x "$STEAMCMD_DIR/linux64/steamcmd" || true

cd /home/container

echo "Pterodactyl S1DS wrapper"
echo "  UID/GID: $(id)"
echo "  STEAMAPPDIR=$STEAMAPPDIR"
echo "  STEAM_ROOT=$STEAM_ROOT"
echo "  HOME=$HOME"
echo "  WINEPREFIX=$WINEPREFIX"
echo "  S1DS_RUNTIME=$S1DS_RUNTIME"
echo "  SteamCMD=$STEAMCMD_DIR/steamcmd.sh"
echo "  Steamworks redist=$STEAMWORKS_REDIST_DIR"
echo "  Server port=${SERVER_PORT:-unset}"
echo "  Server name=${SERVER_NAME:-unset}"

# S1DS expects steam_api64.dll in the game root. Schedule I ships it under
# Schedule I_Data/Plugins/x86_64, so copy it into place when present.
if [ ! -f "/home/container/steam_api64.dll" ] \
   && [ -f "/home/container/Schedule I_Data/Plugins/x86_64/steam_api64.dll" ]; then
  echo "Copying steam_api64.dll into game root"
  cp -f "/home/container/Schedule I_Data/Plugins/x86_64/steam_api64.dll" \
        "/home/container/steam_api64.dll"
fi

exec /bin/bash /usr/local/bin/s1ds-run.sh