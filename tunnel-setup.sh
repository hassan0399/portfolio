#!/usr/bin/env bash
set -e

CONFIG=/etc/cloudflared/config.yml
TUNNEL_ID=6a17bfe5-f1f4-4aef-bad5-91f12e51f20f

echo "==> Backing up tunnel config..."
cp "$CONFIG" "${CONFIG}.bak"

echo "==> Injecting new hostnames into $CONFIG ..."
python3 - << 'PYEOF'
import re

path = "/etc/cloudflared/config.yml"
with open(path) as f:
    content = f.read()

new_entries = """\
  - hostname: imhassan.dev
    service: http://localhost:8085
  - hostname: www.imhassan.dev
    service: http://localhost:8085
  - hostname: store.imhassan.dev
    service: http://localhost:8085
"""

# Insert before the catch-all fallback rule
marker = "  - service: http_status:404"
if "imhassan.dev\n    service: http://localhost:8085" in content:
    print("  (hostnames already present, skipping insert)")
elif marker in content:
    content = content.replace(marker, new_entries + marker)
    with open(path, "w") as f:
        f.write(content)
    print("  Done.")
else:
    print("  ERROR: could not find fallback marker in config!")
    raise SystemExit(1)
PYEOF

echo "==> Routing DNS for imhassan.dev ..."
cloudflared tunnel route dns "$TUNNEL_ID" imhassan.dev

echo "==> Routing DNS for www.imhassan.dev ..."
cloudflared tunnel route dns "$TUNNEL_ID" www.imhassan.dev

echo "==> Routing DNS for store.imhassan.dev ..."
cloudflared tunnel route dns "$TUNNEL_ID" store.imhassan.dev

echo "==> Restarting cloudflared ..."
systemctl restart cloudflared
sleep 2
systemctl is-active cloudflared && echo "==> cloudflared is running" || echo "ERROR: cloudflared failed to start"

echo ""
echo "Done. Live URLs:"
echo "  https://imhassan.dev"
echo "  https://www.imhassan.dev"
echo "  https://store.imhassan.dev"
