from pathlib import Path

run_sh = Path("/home/steam/run.sh")
content = run_sh.read_text(encoding="utf-8")

# ---------------------------------------------------------------------------
# Patch 1:
# Add Pterodactyl-friendly launch args to the S1DS server launch arguments.
# ---------------------------------------------------------------------------

server_args_marker = "# PTERODACTYL_S1DS_PATCH"

if server_args_marker not in content:
    markers = [
        "  --steam-gs-anonymous\n\n)",
        "  --steam-gs-anonymous\n)",
    ]

    replacement = """  --steam-gs-anonymous
  --stdio-console
  -logFile
  -
  --server-port
  "${SERVER_PORT:-38465}"
  --server-name
  "${SERVER_NAME:-Schedule I Dedicated Server}"
  --max-players
  "${MAX_PLAYERS:-16}"
)
# PTERODACTYL_S1DS_PATCH
if [ -n "${SERVER_PASSWORD:-}" ]; then
  SERVER_LAUNCH_ARGS+=(--server-password "${SERVER_PASSWORD}")
fi
"""

    for marker in markers:
        if marker in content:
            content = content.replace(marker, replacement, 1)
            break
    else:
        raise RuntimeError(
            "Could not find SERVER_LAUNCH_ARGS insertion point in /home/steam/run.sh"
        )


# ---------------------------------------------------------------------------
# Patch 2:
# Schedule I ships steam_api64.dll under:
#   Schedule I_Data/Plugins/x86_64/steam_api64.dll
#
# S1DS checks for steam_api64.dll in the game root:
#   ${STEAMAPPDIR}/steam_api64.dll
#
# On first install, the entrypoint runs before the game files exist, so the
# copy must happen inside run.sh after SteamCMD has installed the game but
# before the Steam runtime DLL presence check runs.
# ---------------------------------------------------------------------------

steam_api_patch_marker = "# PTERODACTYL_STEAM_API64_PATCH"

if steam_api_patch_marker not in content:
    steam_api_patch = r'''
# PTERODACTYL_STEAM_API64_PATCH
SCHEDULE_I_STEAM_API64="${STEAMAPPDIR}/Schedule I_Data/Plugins/x86_64/steam_api64.dll"
ROOT_STEAM_API64="${STEAMAPPDIR}/steam_api64.dll"

if [ ! -f "$ROOT_STEAM_API64" ] && [ -f "$SCHEDULE_I_STEAM_API64" ]; then
    echo "Copying steam_api64.dll from Schedule I plugin directory into game root..."
    cp -f "$SCHEDULE_I_STEAM_API64" "$ROOT_STEAM_API64"
fi
'''

    insert_markers = [
        'echo "Writing steam_appid.txt (${STEAMAPPID})"\necho "${STEAMAPPID}" > "${STEAMAPPDIR}/steam_appid.txt"\n',
        'echo "${STEAMAPPID}" > "${STEAMAPPDIR}/steam_appid.txt"\n',
    ]

    for insert_marker in insert_markers:
        if insert_marker in content:
            content = content.replace(
                insert_marker,
                insert_marker + steam_api_patch + "\n",
                1,
            )
            break
    else:
        raise RuntimeError(
            "Could not find steam_appid.txt write point in /home/steam/run.sh"
        )


run_sh.write_text(content, encoding="utf-8")
print("Patched /home/steam/run.sh for Pterodactyl")