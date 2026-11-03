# Guía de Creación y Configuración del Bot de Telegram

Telegram es el canal más sencillo, robusto y tolerante a fallos para interactuar con tu servidor y tu agente inteligente, sin riesgo de baneos de cuenta y con soporte nativo de notas de voz, botones interactivos y envío de documentos.

---

## 1. Crear el Bot con @BotFather

1. Abre la aplicación de Telegram y busca el usuario oficial **`@BotFather`** (asegúrate de que tenga el tick azul de verificación).
2. Envía el comando `/newbot`.
3. Introduce el nombre público de tu bot (ejemplo: `Mi Servidor Doméstico`).
4. Introduce un nombre de usuario único terminado en `bot` (ejemplo: `mi_servidor_personal_bot`).
5. **@BotFather** te responderá con tu **Token de Acceso HTTP API**:
   ```
   7123456789:AAH...TU_TOKEN_AQUI...XYZ
   ```
   *Guarda este token con recelo; es la llave de acceso a tu bot.*

---

## 2. Obtener tu Chat ID de Usuario (Seguridad y Whitelist)

Por motivos de seguridad perimetral, el agente debe responder **únicamente a ti** y bloquear a cualquier desconocido:

1. En Telegram, busca el bot oficial **`@userinfobot`** y pulsa `/start`.
2. El bot te responderá con tu ID numérico:
   ```
   Id: 123456789
   First: Nombre
   Last: Apellido
   ```
3. Copia ese número entero: será tu valor en `allowed_chat_ids`.

---

## 3. Configuración en el Agente

En `config/agent.yaml`:
```yaml
messaging:
  channel: "telegram" # O "multi" si también usas WhatsApp

telegram:
  bot_token: "7123456789:AAH...TU_TOKEN_AQUI...XYZ"
  allowed_chat_ids:
    - 123456789 # Tu Chat ID
  enable_voice_transcription: true
  debounce_seconds: 2.5
```

---

## 4. Personalizar Comandos en @BotFather (Opcional)

Envía `/setcommands` a `@BotFather`, selecciona tu bot y pega la siguiente lista recomendada:
```
start - Iniciar sesión y saludar
status - Estado de salud y métricas del servidor
media - Consultar descargas y catálogo
help - Ayuda y lista de comandos disponibles
```
