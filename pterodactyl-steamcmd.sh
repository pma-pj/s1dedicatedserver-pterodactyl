#!/bin/bash
set -e

export STEAM_ROOT="${STEAM_ROOT:-/home/container/steam}"
export HOME="${HOME:-$STEAM_ROOT}"

export STEAMCMD_DIR="${STEAMCMD_DIR:-$STEAM_ROOT/steamcmd}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$STEAM_ROOT/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$STEAM_ROOT/.config}"

mkdir -p "$STEAM_ROOT"
mkdir -p "$STEAMCMD_DIR"
mkdir -p "$STEAM_ROOT/Steam/logs"
mkdir -p "$STEAM_ROOT/Steam/package"
mkdir -p "$STEAM_ROOT/.steam"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
  echo "Copying SteamCMD to writable directory: $STEAMCMD_DIR"
  cp -a /home/steam/steamcmd/. "$STEAMCMD_DIR/"
fi

chmod +x "$STEAMCMD_DIR/steamcmd.sh" || true
chmod +x "$STEAMCMD_DIR/linux32/steamcmd" || true

cd "$STEAMCMD_DIR"

exec ./steamcmd.sh "$@"