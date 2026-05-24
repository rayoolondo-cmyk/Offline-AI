# Local AI - Asistente de IA portátil en USB

Lleva tu propio asistente de inteligencia artificial en un USB. Funciona en cualquier Ubuntu sin instalar nada en el sistema.

## ¿Qué es?

Local AI es un asistente de IA completamente portable que arranca desde un USB. Todo lo necesario va dentro del USB: el motor de IA (Ollama), los modelos, Python y el chat web.

## Características

- 🔌 **100% portable** — conecta el USB y ejecuta un script, nada más
- 🌐 **Chat web local** — interfaz en el navegador sin internet
- 🔍 **Búsqueda web** — cuando hay wifi, Sparki busca información actual
- 📎 **Lee archivos** — PDF, Word, Excel, PowerPoint, TXT, código...
- 🖼 **Sube imágenes** — adjunta imágenes a tus mensajes
- 💬 **Historial** — guarda tus conversaciones entre sesiones
- 🤖 **Multimodelo** — cambia entre modelos instalados desde el chat
- 🔒 **Sin nube** — todo corre localmente, tus datos no salen del USB

## Modelos incluidos

- `llama3.2:3b` — modelo principal, buena calidad en CPU

## Requisitos

- Ubuntu 20.04 o superior
- USB de 8GB o más (ext4)
- No se necesita instalar nada

## Uso

```bash
bash /run/media/TU_USUARIO/local-ai/start-offline.sh
```

## Stack

- [Ollama](https://ollama.com) — motor de IA local
- Python 3.12 portable — servidor web y proxy
- HTML/JS puro — interfaz del chat sin dependencias
