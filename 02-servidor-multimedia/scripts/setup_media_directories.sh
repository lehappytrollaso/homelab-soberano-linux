#!/usr/bin/env bash
# ==============================================================================
# Script de Creación de Estructura Atómica y Hardlinks (TRaSH Guides)
# ==============================================================================
# La clave de una suite Servarr eficiente es que descargas y biblioteca residan
# en el MISMO sistema de archivos montado. Esto permite que el sistema operativo
# cree enlaces duros (hardlinks) instantáneos sin duplicar espacio ni saturar el disco.
# ==============================================================================
set -euo pipefail

BASE_DIR="${1:-/srv/storage/data}"
TARGET_USER="${SUDO_USER:-$USER}"

echo "Creando estructura atómica de directorios en: $BASE_DIR"

mkdir -p "$BASE_DIR/torrents"/{movies,tv,music}
mkdir -p "$BASE_DIR/media"/{movies,tv,music}
mkdir -p "$BASE_DIR/config"/{jellyfin,jellyseerr,radarr,sonarr,prowlarr,bazarr,qbittorrent}

echo "Ajustando permisos POSIX para usuario: $TARGET_USER"
chown -R "$TARGET_USER:$TARGET_USER" "$BASE_DIR"
chmod -R 775 "$BASE_DIR"

echo "Estructura creada con éxito:"
find "$BASE_DIR" -maxdepth 2 -type d
