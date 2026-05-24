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

  LOCAL AI - Instrucciones de instalación
════════════════════════════════════════

REQUISITOS
──────────
- Ubuntu 20.04 o superior
- USB de 8GB o más
- Conexión a internet para descargar

PREPARAR UN USB NUEVO
──────────────────────

1. Conecta el USB y averigua su nombre:
   lsblk -o NAME,SIZE,LABEL,MOUNTPOINT

2. Formatea el USB (cambia sdX1 por el tuyo):
   sudo umount /dev/sdX1
   sudo mkfs.ext4 -L local-ai /dev/sdX1

3. Monta el USB:
   udisksctl mount -b /dev/sdX1

4. Da permisos:
   sudo chown $USER:$USER /run/media/$USER/local-ai

5. Entra en el USB:
   cd /run/media/$USER/local-ai

6. Descarga Ollama:
   mkdir -p ollama
   curl -L "https://github.com/ollama/ollama/releases/download/v0.24.0/ollama-linux-amd64.tar.zst" -o /tmp/ollama.tar.zst
   tar -I zstd -xf /tmp/ollama.tar.zst -C ollama/

7. Descarga Python portable:
   curl -L https://github.com/indygreg/python-build-standalone/releases/download/20240814/cpython-3.12.5+20240814-x86_64-unknown-linux-gnu-install_only.tar.gz -o /tmp/python.tar.gz
   tar xzf /tmp/python.tar.gz
   mv python python-portable
   rm /tmp/python.tar.gz

8. Instala librerías Python:
   python-portable/bin/pip3 install PyPDF2 python-docx openpyxl python-pptx -q

9. Arranca Ollama y descarga el modelo:
   OLLAMA_MODELS=$PWD/models ollama/bin/ollama serve &
   sleep 3
   OLLAMA_MODELS=$PWD/models ollama/bin/ollama pull llama3.2:3b

10. Copia los archivos del USB original:
    - chat.html
    - start-offline.sh
    - search-proxy.py

11. Da permisos al script:
    chmod +x start-offline.sh

ARRANCAR
────────
bash /run/media/$USER/local-ai/start-offline.sh

El chat se abre automáticamente en el navegador.

PARAR
─────
pkill -f 'ollama serve'; pkill -f 'python'
