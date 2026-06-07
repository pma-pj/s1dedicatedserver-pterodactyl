from pathlib import Path

run_sh = Path("/home/steam/run.sh")
content = run_sh.read_text(encoding="utf-8")

if "PTERODACTYL_S1DS_PATCH" in content:
    print("run.sh already patched")
    raise SystemExit(0)

# Add Pterodactyl-friendly args to the existing Bash array.
# The upstream S1DS image currently ends SERVER_LAUNCH_ARGS with
# --steam-gs-anonymous. Keep this conservative so the build fails visibly
# if upstream changes the runner layout.
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
    raise RuntimeError("Could not find SERVER_LAUNCH_ARGS insertion point in /home/steam/run.sh")

run_sh.write_text(content, encoding="utf-8")
print("Patched /home/steam/run.sh for Pterodactyl")
