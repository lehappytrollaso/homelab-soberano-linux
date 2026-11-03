#!/usr/bin/env bash
# ==============================================================================
# Script de Aprovisionamiento Maestro para Servidor Linux (Ubuntu/Debian)
# ==============================================================================
# Ejecución: sudo bash 01_bootstrap_server.sh
# ==============================================================================
set -euo pipefail

TARGET_USER="${SUDO_USER:-$USER}"

echo "=========================================================="
echo " Aprovisionando Servidor Linux Soberano para usuario: $TARGET_USER"
echo "=========================================================="

# 1. Actualización de paquetes
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y

# 2. Instalación de paquetes esenciales del sistema y aceleración de hardware
apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    ca-certificates \
    avahi-daemon \
    avahi-utils \
    ufw \
    htop \
    iotop \
    ncdu \
    tmux \
    jq \
    zram-tools \
    smartmontools \
    net-tools \
    cockpit \
    va-driver-all \
    vainfo

# Si es arquitectura Intel, instalar el driver Iris Xe / QuickSync non-free
if lscpu | grep -qi "intel"; then
    echo "Detectada CPU Intel: Instalando drivers VA-API Intel Media..."
    apt-get install -y intel-media-va-driver-non-free || true
fi

# 3. Configuración de ZRAM (Swap comprimido en memoria RAM, 50% de capacidad)
echo "Configurando ZRAM..."
cat << 'EOF' > /etc/default/zramswap
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF
systemctl restart zramswap || true

# 4. Instalación oficial de Docker Engine y Docker Compose v2
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker Engine oficial..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# 5. Permisos de Docker y persistencia de demonios de usuario (Linger)
echo "Añadiendo usuario '$TARGET_USER' al grupo docker..."
usermod -aG docker "$TARGET_USER"

echo "Activando systemd Linger para usuario '$TARGET_USER' (persistencia 24/7 sin GUI)..."
loginctl enable-linger "$TARGET_USER"

# 6. Copia y aplicación de sysctl hardening
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../configs/sysctl-hardening.conf" ]; then
    echo "Aplicando optimizaciones de kernel y red sysctl..."
    cp "$SCRIPT_DIR/../configs/sysctl-hardening.conf" /etc/sysctl.d/99-homelab-hardening.conf
    sysctl --system || true
fi

# 7. Configuración de dispatcher NetworkManager
if [ -f "$SCRIPT_DIR/../configs/99-eth-wifi-failover.sh" ]; then
    echo "Instalando script de conmutación Ethernet/Wi-Fi..."
    mkdir -p /etc/NetworkManager/dispatcher.d
    cp "$SCRIPT_DIR/../configs/99-eth-wifi-failover.sh" /etc/NetworkManager/dispatcher.d/
    chmod +x /etc/NetworkManager/dispatcher.d/99-eth-wifi-failover.sh
fi

echo "=========================================================="
echo " ¡Aprovisionamiento base completado con éxito!"
echo " Reinicia el servidor o cierra e inicia sesión para aplicar grupos."
echo "=========================================================="
