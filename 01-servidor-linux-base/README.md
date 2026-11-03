# Módulo 1 · Servidor Linux Base y Hardening 24/7

Guía integral para transformar un equipo x86_64 de bajo consumo (Mini PC, placa compacta o servidor doméstico) en un nodo soberano, desatendido (*headless*), energéticamente eficiente y resiliente ante cortes de suministro eléctrico.

---

## 1. Selección de Hardware y Topología Recomendada

- **Procesador (CPU)**: Arquitectura x86_64 moderna de bajo consumo (ej. Intel N100, Core i3/i5/i7 o equivalentes) con transcodificación por hardware integrada (Intel QuickSync / VA-API).
- **Memoria RAM**: 8 GB a 16 GB DDR4/DDR5.
- **Almacenamiento**:
  - Unidad de Sistema: NVMe M.2 o SSD SATA (250 GB - 500 GB).
  - Unidad de Medios: SSD/HDD externo o interno (1 TB a 8 TB) formateado en `ext4` con permisos POSIX nativos.
- **Conectividad Dual**: Puerto Ethernet Gigabit (prioritario) + tarjeta Wi-Fi integrada (respaldo automático).

---

## 2. Configuración Mandatoria de la BIOS (AMI Aptio / Genérica)

Para garantizar que el servidor arranque siempre sin monitor ni teclado conectado y se recupere automáticamente tras un apagón, aplica estos ajustes al encender la máquina (pulsando `DEL` o `F7`):

1. **Recuperación tras Corte Eléctrico (*State After G3* / *Restore on AC Power Loss*)**:
   - Ajuste: **`Power On`**.
   - *Por qué*: Si se corta el suministro eléctrico o se desenchufa la regleta, el equipo arrancará de forma autónoma en cuanto regrese la corriente, sin requerir intervención física.
2. **Arranque Rápido (*Fast Boot*)**:
   - Ajuste: **`Disabled`**.
   - *Por qué*: Asegura que la BIOS inicialice y enumere todos los buses USB y controladores de almacenamiento antes de buscar el sector de arranque UEFI.
3. **Prioridad de Arranque (*Boot Option Priorities*)**:
   - Ajuste: Selecciona la partición **UEFI** del disco de sistema como *Boot Option #1*.
4. **Modo Gráfico Inicial**:
   - Si la BIOS dispone de la opción *Primary Display*, mantén *IGFX / Auto* y reserva al menos 128 MB a la GPU integrada (iGPU).

### 💡 Análisis Técnico: ¿Por qué *State After G3* supera a *Wake-on-LAN (WoL)*?

| Característica | State After G3: Power On | Wake-on-LAN (WoL) |
|---|---|---|
| **Corte de luz general** | ✅ **Arranca solo al volver la luz** | ❌ **Inútil**: el router también se apaga y nadie envía el *Magic Packet*. |
| **Intervención manual** | ✅ Cero intervención requerida | ❌ Requiere otro dispositivo encendido en la red para mandar el paquete. |
| **Consumo en reposo** | 0W (apagado total) | 0.5W - 1.5W (mantiene tarjeta de red energizada). |
| **Recomendación 24/7** | **Crítica y obligatoria** | Secundaria / Opcional. |

---

## 3. Instalación del Sistema Operativo y Particionado

Se recomienda **Ubuntu Server 24.04 LTS** o **26.04 LTS**:

1. **Esquema de Particionado GPT**:
   - `/boot/efi`: 1.0 GB, sistema de archivos **FAT32**, bandera ESP/Boot.
   - `/`: Espacio restante, sistema de archivos **ext4**, opciones de montaje recomendadas: `noatime,errors=remount-ro`.
2. **Swap Comprimido en RAM (ZRAM)**:
   - En lugar de gastar ciclos de escritura en el disco SSD/NVMe con particiones de swap clásicas, se configura **ZRAM (zstd)** al 50% de la RAM física. Previene caídas por agotamiento de memoria (*OOM*) comprimiendo páginas en RAM de forma ultra-rápida.

---

## 4. Hardening y Seguridad del Sistema

### 4.1. Acceso SSH Exclusivo por Clave Criptográfica
Edita `/etc/ssh/sshd_config.d/hardening.conf`:
```sshconfig
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
KbdInteractiveAuthentication no
MaxAuthTries 3
```
Reinicia el servicio: `sudo systemctl restart ssh`

### 4.2. Cortafuegos Perimetral (UFW)
Aplica el script incluido en `configs/ufw-rules.sh`:
- Deniega todo tráfico entrante por defecto.
- Permite SSH (puerto 22) y descubrimiento mDNS (puerto 5353 UDP).
- Restringe paneles de administración (Cockpit, Jellyfin, Jellyseerr) exclusivamente a la subred local (`192.168.0.0/16`) o VPN.

### 4.3. Parámetros de Kernel y Red (`sysctl`)
El archivo `configs/sysctl-hardening.conf` optimiza:
- Algoritmo de congestión TCP **BBR** (multiplica el rendimiento de streaming y descargas).
- `vm.swappiness = 10` (retrasa el volcado a disco).
- Protección activa contra ataques SYN Flood y spoofing IP.

---

## 5. Redundancia de Red y Resolución Local

### 5.1. Resolución Local sin IPs (mDNS / Avahi)
Con `avahi-daemon` instalado, tu servidor resolverá automáticamente en toda la red local mediante:
```bash
ssh usuario@tu-servidor.local
```
Sin necesidad de configurar IPs estáticas complejas en el router.

### 5.2. Conmutación Automática Ethernet <-> Wi-Fi (Failover)
El script dispatcher `configs/99-eth-wifi-failover.sh` detecta el estado del cable:
- Cable conectado: Apaga la Wi-Fi para evitar tablas de enrutamiento duplicadas.
- Cable desconectado accidentalmente: Levanta la interfaz Wi-Fi inmediatamente.

---

## 6. Acceso Remoto Seguro (Zero-Trust)

Para acceder a tu servidor desde fuera de casa **sin abrir puertos en tu router (sin NAT/PAT)**:

- **Opción A · Cloudflare Tunnel (`cloudflared`)**:
  Ideal para exponer servicios web de forma segura o conectar webhooks:
  ```bash
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
  sudo apt-get update && sudo apt-get install -y cloudflared
  ```
- **Opción B · Tailscale (Mesh VPN)**:
  Crea una red privada cifrada WireGuard punto a punto entre tu móvil, portátil y servidor:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up
  ```

---

## 7. Despliegue Rápido Automatizado

Para aprovisionar un servidor recién instalado con todos estos ajustes, ejecuta:
```bash
sudo bash scripts/01_bootstrap_server.sh
```
