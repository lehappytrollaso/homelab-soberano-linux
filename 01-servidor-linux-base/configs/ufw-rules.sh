#!/bin/bash
# ==============================================================================
# Configuración Defensiva de Cortafuegos (UFW) para Servidor Doméstico
# ==============================================================================
# Uso: sudo bash ufw-rules.sh
# ==============================================================================
set -euo pipefail

echo "=== Configurando reglas de cortafuegos UFW ==="

# Política por defecto: Denegar entrada, permitir salida
ufw default deny incoming
ufw default allow outgoing

# 1. SSH (Acceso administrativo seguro)
ufw allow 22/tcp comment 'SSH Administracion'

# 2. Resolución mDNS local (Avahi / Bonjour: homelab.local, server.local)
ufw allow 5353/udp comment 'mDNS Avahi'

# 3. Cockpit Web UI (Monitorización de sistema en red local)
ufw allow from 192.168.0.0/16 to any port 9090 proto tcp comment 'Cockpit LAN'
ufw allow from 10.0.0.0/8 to any port 9090 proto tcp comment 'Cockpit VPN'

# 4. Jellyfin Media Server (Streaming multimedia en red local)
ufw allow from 192.168.0.0/16 to any port 8096 proto tcp comment 'Jellyfin LAN'
ufw allow from 10.0.0.0/8 to any port 8096 proto tcp comment 'Jellyfin VPN'
ufw allow 1900/udp comment 'Jellyfin DLNA Discovery'
ufw allow 7359/udp comment 'Jellyfin Client Auto-discovery'

# 5. Jellyseerr (Peticiones multimedia en red local)
ufw allow from 192.168.0.0/16 to any port 5055 proto tcp comment 'Jellyseerr LAN'

# 6. qBittorrent (Puerto de escucha P2P entrante para clientes torrent)
# NOTA: Si usas VPN con Gluetun, este puerto se expone exclusivamente dentro del túnel VPN.
ufw allow 6881/tcp comment 'qBittorrent P2P'
ufw allow 6881/udp comment 'qBittorrent P2P'

# Los paneles internos (Radarr 7878, Sonarr 8989, Prowlarr 9696, Bazarr 6767, WAHA 3000)
# deben mantenerse vinculados a 127.0.0.1 o accesibles únicamente mediante VPN (Tailscale)
# o túnel Cloudflare para máxima seguridad.

# Activar UFW
ufw --force enable
ufw status verbose
echo "=== Cortafuegos UFW activado con éxito ==="
