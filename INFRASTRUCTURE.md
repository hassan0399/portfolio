# Portfolio Infrastructure Notes

## Server
- **IP:** 62.252.144.107
- **OS:** Ubuntu (Linux)

## Live URLs
| URL | Serves |
|-----|--------|
| https://imhassan.dev | `index.html` — main portfolio |
| https://www.imhassan.dev | same |
| https://store.imhassan.dev | `store.html` — Shopify CSV data store |
| https://portfolio.imhassan.dev | same as imhassan.dev (older alias) |

## Stack
```
Browser (HTTPS)
  → Cloudflare (SSL termination + CDN)
    → Cloudflare Tunnel (cloudflared)
      → localhost:8085 (Docker: mh-portfolio)
        → nginx inside container routes by Host header
            imhassan.dev / www.imhassan.dev  → index.html
            store.imhassan.dev               → store.html
```

## Docker Container — mh-portfolio
- **Image:** built from `Dockerfile` in this repo
- **Port:** `8085:80`
- **Config:** `nginx.conf` (two server blocks — portfolio + store)
- **Files served:** `index.html`, `store.html`
- **Rebuild & redeploy:**
  ```bash
  cd /home/hassan/portfolio
  docker compose down && docker compose up -d --build
  ```

## Cloudflare Tunnel
- **Tunnel name:** `nextcloud`
- **Tunnel ID:** `6a17bfe5-f1f4-4aef-bad5-91f12e51f20f`
- **Config file:** `/etc/cloudflared/config.yml`
- **Credentials:** `/etc/cloudflared/6a17bfe5-f1f4-4aef-bad5-91f12e51f20f.json`
- **Managed by:** systemd (`cloudflared.service`)
- **Restart:** `sudo systemctl restart cloudflared`

### Adding a new hostname to the tunnel
1. Add entry to `/etc/cloudflared/config.yml` (before the `http_status:404` fallback line):
   ```yaml
   - hostname: subdomain.imhassan.dev
     service: http://localhost:PORT
   ```
2. Create the Cloudflare DNS CNAME:
   ```bash
   TUNNEL_ORIGIN_CERT=/home/hassan/.cloudflared/cert.pem \
     cloudflared tunnel route dns 6a17bfe5-f1f4-4aef-bad5-91f12e51f20f subdomain.imhassan.dev
   ```
3. Restart: `sudo systemctl restart cloudflared`

## Other Services on This Server
| Service | Port | Domain |
|---------|------|--------|
| Nextcloud (Apache) | 80 | cloud.imhassan.dev |
| Nginx Proxy Manager UI | 81 | npm.imhassan.dev |
| NPM HTTP proxy | 8181 | — |
| NPM HTTPS proxy | 4443 | — |
| Guacamole | 8080 | guacamole.imhassan.dev |
| Portainer | 9000 | portainer.imhassan.dev |
| VSCode Server | 8585 | vscode.imhassan.dev |
| Torrent | 8090 | torrent.imhassan.dev |
| alsanidps | 3000 | alsanidps.imhassan.dev |

## NPM API (Nginx Proxy Manager)
- **Admin UI:** http://62.252.144.107:81
- **API base:** http://127.0.0.1:81/api
- **Auth:** POST /api/tokens `{"identity":"lasane.786@gmail.com","secret":"..."}`

## Cloudflare SSL
- **Mode:** Full (Strict) recommended — tunnel handles origin, Cloudflare handles edge
- **DNS records:** All domains are CNAME → `6a17bfe5-f1f4-4aef-bad5-91f12e51f20f.cfargotunnel.com` (auto-created by `cloudflared tunnel route dns`)
