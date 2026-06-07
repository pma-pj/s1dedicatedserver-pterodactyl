# Schedule I / S1DedicatedServers for Pterodactyl

This repository contains an optional wrapper image for the ifBars/S1DedicatedServers Docker image.

Created using AI.

Why this wrapper exists:

- S1DS writes to `/home/steam/game` by default.
- Pterodactyl persists and exposes `/home/container`.
- This wrapper sets `STEAMAPPDIR=/home/container`.
- It also patches S1DS `run.sh` so the server receives Pterodactyl-friendly startup flags:
  - `--stdio-console`
  - `-logFile -`
  - `--server-port ${SERVER_PORT}`
  - `--server-name ${SERVER_NAME}`
  - `--max-players ${MAX_PLAYERS}`
  - optional `--server-password ${SERVER_PASSWORD}`

Build:

```bash
docker build -t ghcr.io/YOUR_GHCR_USER/s1ds-pterodactyl-mono:latest .
docker push ghcr.io/YOUR_GHCR_USER/s1ds-pterodactyl-mono:latest
```

Then set the egg Docker image to:

```text
ghcr.io/YOUR_GHCR_USER/s1ds-pterodactyl-mono:latest
```

Use Mono runtime:

```text
S1DS_RUNTIME=mono
STEAMAPPDIR=/home/container
```

Ports:

- Primary allocation: server port, default 38465
- Additional allocation: 27016 UDP for Steam query/listing when using SteamGameServer

Steam credentials are needed on first boot so SteamCMD can download Schedule I.
