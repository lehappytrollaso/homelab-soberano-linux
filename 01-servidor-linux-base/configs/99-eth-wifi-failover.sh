#!/bin/bash
# ==============================================================================
# Script Dispatcher de NetworkManager: Conmutación Automática Ethernet <-> Wi-Fi
# ==============================================================================
# Ubicación en el sistema: /etc/NetworkManager/dispatcher.d/99-eth-wifi-failover.sh
# Permisos requeridos: chmod 755
#
# Comportamiento:
# 1. Si la interfaz Ethernet se conecta (UP): Se desconecta la Wi-Fi para evitar
#    enrutamiento asimétrico, colisiones ARP y gasto innecesario de energía.
# 2. Si la interfaz Ethernet se desconecta (DOWN): Se reconecta la Wi-Fi de forma
#    automática e inmediata para asegurar que el servidor nunca quede incomunicado.
# ==============================================================================

INTERFACE="$1"
ACTION="$2"

# Configura los nombres de tus interfaces de red (identifícalas con 'ip link'):
ETH_INTERFACE="eth0"
WIFI_INTERFACE="wlan0"

# Comprobar si la acción afecta a la interfaz cableada
if [ "$INTERFACE" = "$ETH_INTERFACE" ]; then
    case "$ACTION" in
        up)
            logger -t "net-failover" "Ethernet ($ETH_INTERFACE) CONECTADA. Apagando Wi-Fi ($WIFI_INTERFACE)..."
            nmcli device disconnect "$WIFI_INTERFACE" 2>/dev/null || true
            ;;
        down)
            logger -t "net-failover" "Ethernet ($ETH_INTERFACE) DESCONECTADA. Levantando Wi-Fi de respaldo ($WIFI_INTERFACE)..."
            nmcli device connect "$WIFI_INTERFACE" 2>/dev/null || true
            ;;
    esac
fi
