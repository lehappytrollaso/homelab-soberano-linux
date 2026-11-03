# Módulo 4 · Pasarelas de Comunicación (Telegram & WhatsApp)

Guía para conectar tu servidor doméstico y tu agente inteligente con las dos plataformas de mensajería móvil más utilizadas: **Telegram** y **WhatsApp**.

---

## 1. Comparativa de Canales de Comunicación

| Característica | Telegram Bot API | WhatsApp (WAHA NOWEB) |
|---|---|---|
| **Protocolo de conexión** | Long-Polling o Webhook HTTPS | WebSockets internos vía Baileys |
| **Facilidad de configuración** | Inmediata (hablando con `@BotFather`) | Requiere escaneo de código QR |
| **Riesgo de bloqueo/baneo** | **0%** (API pública oficial) | Mínimo si se siguen las pautas anti-baneo |
| **Soporte de notas de voz** | Nativo (.ogg / Opus) | Nativo (.ogg / mp4 audio) |
| **Botones interactivos** | Inline Keyboards avanzados | Texto / Botones básicos |
| **Caso de uso óptimo** | Control técnico, alertas y comandos SRE | Uso familiar y asistente diario |

---

## 2. Enrutador Multicanal Unificado (`multi`)

El agente incluye un router multicanal capaz de escuchar en **Telegram y WhatsApp de forma simultánea dentro del mismo proceso**.

En `config/agent.yaml`:
```yaml
messaging:
  channel: "multi" # Activa Telegram y WhatsApp a la vez
```

El router asocia a cada mensaje un prefijo de canal (`telegram:123456789` o `whatsapp:34600000000`), manteniendo historiales de conversación aislados y enviando las respuestas automáticamente al canal de origen correcto.

---

## 3. Guías Detalladas

- 📘 [Guía de Configuración de Telegram (BotFather y Whitelist)](docs/telegram_setup_guide.md)
- 📗 [Guía de Despliegue de WhatsApp (WAHA, Webhook HMAC y Anti-Baneo)](docs/whatsapp_waha_guide.md)
