# Schedule I / S1DedicatedServers for Pterodactyl

Pterodactyl/Wings usually starts game containers as an unprivileged UID/GID with a read-only root filesystem. Only `/home/container` is writable and persistent. The upstream S1DedicatedServers image expects runtime state below `/home/steam`, which can fail under Pterodactyl.

Created using AI.

This wrapper image fixes that by:

- forcing `HOME=/home/container`
- forcing `STEAMAPPDIR=/home/container`
- forcing `WINEPREFIX=/home/container/.wine`
- copying SteamCMD into `/home/container/steamcmd`
- patching the S1DS runner to use `/home/container/steamcmd`
- adding Pterodactyl-friendly server launch args:
  - `--stdio-console`
  - `-logFile -`
  - `--server-port ${SERVER_PORT}`
  - `--server-name ${SERVER_NAME}`
  - `--max-players ${MAX_PLAYERS}`
  - optional `--server-password ${SERVER_PASSWORD}`

## Pterodactyl egg settings

Use your GHCR image, for example:

```text
ghcr.io/pma-pj/s1dedicatedserver-pterodactyl:v1.0.0
```

Suggested startup command:

```bash
bash /usr/local/bin/pterodactyl-entrypoint.sh
```

The image also has this as its `ENTRYPOINT`, so the startup command can be simple, but do not use an `echo`-only startup command if your egg relies on executing `STARTUP`.

Required/important variables:

```text
STEAM_USER
STEAM_PASS
STEAM_GUARD              temporary only
S1DS_RUNTIME=mono
STEAMAPPDIR=/home/container
SERVER_PORT=38465
SERVER_NAME=Schedule I Dedicated Server
MAX_PLAYERS=16
SERVER_PASSWORD=optional
FORCE_STEAMCMD_UPDATE=false
RESET_STEAMCMD=false     set true once if SteamCMD cache is broken
```

Ports:

```text
38465/tcp
38465/udp
27016/tcp
27016/udp
```

## SteamCMD cache recovery

If SteamCMD gets stuck in a broken bootstrap state, set this Pterodactyl variable once:

```text
RESET_STEAMCMD=true
```

Start the server, then set it back to:

```text
RESET_STEAMCMD=false
```

## Build locally

```bash
docker build --no-cache -t s1ds-ptero-local:test .
```

## Local Pterodactyl-like test

Copy the examples:

```bash
cp .env.example .env
cp steam.env.example steam.env
```

Edit `.env` and `steam.env`.

Important for Steam passwords with special characters: keep the value single-quoted in `steam.env`:

```env
STEAM_PASS='abc$def#ghi!123'
```

Build and start debug:

```bash
docker compose build --no-cache
docker compose up debug --force-recreate
```

Start the actual test container:

```bash
docker compose up s1ds --force-recreate
```

If SteamCMD asks for Steam Guard, enter the one-time code once. After successful login, clear `STEAM_GUARD` again.
