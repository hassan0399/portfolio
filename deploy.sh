#!/usr/bin/env bash
set -e

# ── Write nginx virtual host config ──────────────────────────────────────────
cat > /etc/nginx/sites-available/imhassan.dev << 'NGINX'
# imhassan.dev → portfolio
server {
    listen 80;
    server_name imhassan.dev www.imhassan.dev;

    # Restore real visitor IP from Cloudflare proxy
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 2c0f:f248::/32;
    real_ip_header CF-Connecting-IP;

    location / {
        proxy_pass         http://127.0.0.1:8085;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
    }
}

# store.imhassan.dev → store
server {
    listen 80;
    server_name store.imhassan.dev;

    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 2c0f:f248::/32;
    real_ip_header CF-Connecting-IP;

    location / {
        proxy_pass         http://127.0.0.1:8085;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
    }
}
NGINX

# ── Enable site ───────────────────────────────────────────────────────────────
ln -sf /etc/nginx/sites-available/imhassan.dev /etc/nginx/sites-enabled/imhassan.dev

# ── Test and reload ───────────────────────────────────────────────────────────
nginx -t && kill -HUP "$(cat /run/nginx.pid 2>/dev/null || pgrep -o nginx)"

echo ""
echo "✓ nginx reloaded — both virtual hosts active"
echo "  http://imhassan.dev       → portfolio"
echo "  http://store.imhassan.dev → store"
echo ""
echo "Next: add DNS records in Cloudflare (see output below)"
echo "  A  @     62.252.144.107  Proxied ON"
echo "  A  store 62.252.144.107  Proxied ON"
echo "  A  www   62.252.144.107  Proxied ON"
