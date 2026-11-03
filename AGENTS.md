# Homelab Soberano Linux — AI Agents Context & Architecture Manifest

> **Destinatarios**: Asistentes de IA, modelos de lenguaje (LLMs) y agentes autónomos (AGY, Claude, GPT, Cursor, Copilot, etc.) que analicen, extiendan o desplieguen este repositorio.

---

## 1. Misión y Propósito del Repositorio

Este repositorio es un **blueprint arquitectónico modular, genérico y sanitizado** para construir una infraestructura doméstica soberana 24/7 en Linux x86_64.
El objetivo es proveer a terceros de una suite replicable que unifica:
1. Hardening de servidor base y redundancia de red.
2. Ecosistema multimedia automatizado (Jellyfin + Servarr) con enlaces duros (*hardlinks*).
3. Agente inteligente soberano local con voz y automatización web.
4. Pasarelas de comunicación seguras (Telegram y WhatsApp sin navegador pesado).

---

## 2. Mapa Arquitectónico Rápido para Agentes

```
homelab-soberano-linux/
├── README.md                      # Documentación maestra y visión global para humanos
├── AGENTS.md                      # Este manifiesto de contexto técnico para IAs
├── .env.example                   # Diccionario maestro de variables de entorno
├── .gitignore                     # Filtro anti-fugas de secretos y credenciales
│
├── 01-servidor-linux-base/        # MÓDULO 1: Infraestructura y SO
│   ├── README.md                  # Guía técnica: BIOS (G3 Power On), ZRAM, SSH y UFW
│   ├── configs/                   # Scripts de firewall UFW, failover de red y sysctl BBR
│   └── scripts/                   # Script de aprovisionamiento desatendido (bootstrap)
│
├── 02-servidor-multimedia/        # MÓDULO 2: Stack Multimedia & Servarr
│   ├── README.md                  # El ciclo de vida de 8 etapas y reglas de oro TRaSH Guides
│   ├── docker-compose.yml         # Jellyfin, Radarr, Sonarr, Prowlarr, Bazarr, qBittorrent, etc.
│   ├── .env.example               # Variables y puertos del stack multimedia
│   └── scripts/                   # Script generador del árbol atómico de directorios
│
├── 03-agente-soberano-linux/      # MÓDULO 3: Agente Inteligente Soberano
│   ├── README.md                  # Arquitectura hexagonal, inferencia y TTS/STT local
│   ├── docker-compose.yml         # Despliegue contenerizado alternativo
│   ├── Containerfile              # Definición OCI / Docker
│   ├── config/                    # Plantillas de configuración (agent.example.yaml y RBAC)
│   ├── systemd/                   # Servicio systemd --user para ejecución nativa 24/7
│   └── scripts/                   # Aprovisionamiento de venv, Playwright y Piper ONNX
│
└── 04-pasarelas-comunicacion/     # MÓDULO 4: Telegram & WhatsApp
    ├── README.md                  # Router multicanal unificado y comparativa
    ├── docker-compose.waha.yml    # WAHA NOWEB (Baileys) aislado
    ├── .env.waha.example          # Claves HMAC y credenciales de pasarela
    └── docs/                      # Guías de paso a paso para BotFather y vinculación QR
```

---

## 3. Principios Inmutables de Diseño para IAs

Cualquier agente que modifique o extienda este código DEBE respetar las siguientes reglas:

1. **Regla de Oro de Almacenamiento (TRaSH Guides)**:
   - Todo el contenido multimedia debe estructurarse bajo un único punto de montaje raíz (`/data`).
   - Las descargas van a `/data/torrents/{movies,tv}` y la biblioteca final a `/data/media/{movies,tv}`.
   - **NUNCA** crees montajes separados `/downloads` y `/movies`. Rompería los *hardlinks* atómicos y forzaría copias lentas de bytes.
2. **Aceleración por Hardware (VA-API / QuickSync)**:
   - Jellyfin debe mapear siempre el dispositivo `/dev/dri:/dev/dri`.
3. **Privacidad y Cero Fugas**:
   - NUNCA introduzcas IPs reales, nombres de usuario personales, teléfonos reales ni nombres comerciales de hardware específico en este repositorio.
   - Utiliza siempre nombres genéricos (`homelab.local`, `sovereign-agent`, `127.0.0.1`, `PUID=1000`).
4. **Seguridad en WhatsApp**:
   - WAHA debe operar exclusivamente con el motor `NOWEB` (evitar Chromium para ahorrar RAM).
   - Todo webhook entrante debe validar la firma criptográfica `WHATSAPP_HOOK_HMAC_KEY`.
   - Activar siempre `simulate_typing: true` y lista blanca de números E.164.

---

## 4. Matriz de Puertos y Servicios para Resolución de Conflictos

| Servicio | Puerto Predeterminado | Protocolo | Binding de Seguridad |
|---|---|---|---|
| **SSH** | 22 | TCP | Red local / Clave pública |
| **mDNS Avahi** | 5353 | UDP | Multicast local |
| **Cockpit** | 9090 | HTTPS | Red local |
| **Jellyfin** | 8096 | HTTP | Red local / Tailscale |
| **Jellyseerr** | 5055 | HTTP | Red local / Cloudflare Tunnel |
| **Radarr** | 7878 | HTTP | Interno / Red local |
| **Sonarr** | 8989 | HTTP | Interno / Red local |
| **Prowlarr** | 9696 | HTTP | Interno / Red local |
| **Bazarr** | 6767 | HTTP | Interno / Red local |
| **qBittorrent** | 8080 (Web) / 6881 (P2P) | HTTP / BitTorrent | Web en LAN, P2P abierto o en VPN |
| **FlareSolverr** | 8191 | HTTP | Red interna Docker |
| **WAHA Gateway** | 3000 | HTTP | Exclusivo `127.0.0.1` |
| **Agente Webhook** | 8088 | HTTP | Exclusivo `127.0.0.1` |
