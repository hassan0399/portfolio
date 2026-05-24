#!/usr/bin/env bash
set -e

CONFIG=/etc/cloudflared/config.yml

echo "==> Current ingress entries:"
grep "hostname:" "$CONFIG"

python3 - << 'PYEOF'
path = "/etc/cloudflared/config.yml"
with open(path) as f:
    content = f.read()

new_entries = (
    "  - hostname: imhassan.dev\n"
    "    service: http://localhost:8085\n"
    "  - hostname: www.imhassan.dev\n"
    "    service: http://localhost:8085\n"
    "  - hostname: store.imhassan.dev\n"
    "    service: http://localhost:8085\n"
)

marker = "  - service: http_status:404"

# Check for exact standalone hostname (not as suffix of another hostname)
already = (
    "\n  - hostname: imhassan.dev\n" in content or
    "  - hostname: imhassan.dev\n" == content[:len("  - hostname: imhassan.dev\n")]
)

if already:
    print("  Already present, nothing to do.")
elif marker in content:
    content = content.replace(marker, new_entries + marker)
    with open(path, "w") as f:
        f.write(content)
    print("  Inserted 3 new hostname entries.")
else:
    print("  ERROR: fallback marker not found in config")
    raise SystemExit(1)
PYEOF

echo ""
echo "==> Updated ingress entries:"
grep "hostname:" "$CONFIG"

echo ""
echo "==> Restarting cloudflared..."
systemctl restart cloudflared
sleep 2
systemctl is-active cloudflared && echo "==> cloudflared running OK" || echo "ERROR: cloudflared failed"
