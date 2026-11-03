#!/usr/bin/env bash
# ==============================================================================
# Script de Instalación del Entorno del Agente Autónomo
# ==============================================================================
set -euo pipefail

echo "=== Configurando entorno virtual para el Agente Soberano ==="

# 1. Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# 2. Actualizar pip e instalar dependencias básicas
pip install --upgrade pip wheel setuptools
pip install \
    google-genai \
    pydantic \
    pyyaml \
    python-telegram-bot \
    httpx \
    faster-whisper \
    piper-tts \
    playwright \
    apscheduler \
    rich

# 3. Instalar navegador para tareas de automatización web (Playwright)
echo "Instalando Chromium Headless para Playwright..."
playwright install chromium
playwright install-deps chromium || true

# 4. Descargar modelo de voz en Español de España (Castellano Peninsular)
MODELS_DIR="data/models/piper"
mkdir -p "$MODELS_DIR"
if [ ! -f "$MODELS_DIR/es_ES-carlfm-high.onnx" ]; then
    echo "Descargando modelo de voz Piper VITS ONNX (es_ES-carlfm-high)..."
    curl -L "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/high/es_ES-carlfm-high.onnx" \
        -o "$MODELS_DIR/es_ES-carlfm-high.onnx"
    curl -L "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/high/es_ES-carlfm-high.onnx.json" \
        -o "$MODELS_DIR/es_ES-carlfm-high.onnx.json"
fi

echo "=== Entorno del Agente configurado correctamente ==="
