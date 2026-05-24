# Local AI - Asistente de IA portátil en USB

Lleva tu propio asistente de inteligencia artificial en un USB. Funciona en cualquier Ubuntu sin instalar nada en el sistema.

## ¿Qué es?

Local AI es un asistente de IA completamente portable que arranca desde un USB. Todo lo necesario va dentro del USB: el motor de IA (Ollama), los modelos, Python y el chat web.

## Características

- 🔌 **100% portable** — conecta el USB y ejecuta un script, nada más
- 🌐 **Chat web local** — interfaz en el navegador sin internet
- 🔍 **Búsqueda web** — cuando hay wifi, busca información actual
- 📎 **Lee archivos** — PDF, Word, Excel, PowerPoint, TXT, código...
- 🖼 **Sube imágenes** — adjunta imágenes a tus mensajes
- 💬 **Historial** — guarda tus conversaciones entre sesiones
- 🤖 **Multimodelo** — cambia entre modelos instalados desde el chat
- 🔒 **Sin nube** — todo corre localmente, tus datos no salen del USB

## Requisitos

- Ubuntu 20.04 o superior
- USB de 8GB o más (ext4)
- `zstd` instalado: `sudo apt install zstd -y`

## Instalación en un USB nuevo

**1. Formatea el USB** (cambia `sdX1` por el tuyo)
```bash
sudo umount /dev/sdX1
sudo mkfs.ext4 -L local-ai /dev/sdX1
udisksctl mount -b /dev/sdX1
sudo chown $USER:$USER /run/media/$USER/local-ai
cd /run/media/$USER/local-ai
```

**2. Descarga Ollama**
```bash
mkdir -p ollama
curl -L "https://github.com/ollama/ollama/releases/download/v0.24.0/ollama-linux-amd64.tar.zst" -o /tmp/ollama.tar.zst
tar -I zstd -xf /tmp/ollama.tar.zst -C ollama/
```

**3. Descarga Python portable**
```bash
curl -L https://github.com/indygreg/python-build-standalone/releases/download/20240814/cpython-3.12.5+20240814-x86_64-unknown-linux-gnu-install_only.tar.gz -o /tmp/python.tar.gz
tar xzf /tmp/python.tar.gz && mv python python-portable && rm /tmp/python.tar.gz
```

**4. Instala librerías Python**
```bash
python-portable/bin/pip3 install PyPDF2 python-docx openpyxl python-pptx -q
```

> `PyPDF2` — leer PDFs | `python-docx` — Word | `openpyxl` — Excel | `python-pptx` — PowerPoint

**5. Descarga el modelo**
```bash
OLLAMA_MODELS=$PWD/models ollama/bin/ollama serve &
sleep 3
OLLAMA_MODELS=$PWD/models ollama/bin/ollama pull llama3.2:3b
```

**6. Copia los archivos al USB**

Descarga `chat.html`, `start-offline.sh` y `search-proxy.py` de este repositorio y cópialos al USB.

```bash
chmod +x start-offline.sh
```

## Uso

En cualquier Ubuntu, solo conecta el USB y ejecuta:

```bash
bash /run/media/$USER/local-ai/start-offline.sh
```

El chat se abre automáticamente en el navegador.

## Stack

- [Ollama](https://ollama.com) — motor de IA local
- Python 3.12 portable — servidor web y proxy de búsqueda
- HTML/JS puro — interfaz del chat sin dependencias externas
