# Offline AI - Asistente de IA portátil en USB

Lleva tu propio asistente de inteligencia artificial en un USB. Funciona en cualquier Ubuntu sin instalar nada en el sistema.

## ¿Qué es?

Offline AI es un asistente de IA completamente portable que arranca desde un USB. Todo lo necesario va dentro del USB: el motor de IA (Ollama), los modelos, Python y el chat web.

## Características

- 🔌 **100% portable** — conecta el USB y ejecuta un script, nada más
- 🌐 **Chat web local** — interfaz en el navegador sin internet
- 🔍 **Búsqueda web** — cuando hay wifi, busca información actual
- 📎 **Lee archivos** — PDF, Word, Excel, PowerPoint, TXT, código...
- 🖼 **Sube imágenes** — adjunta imágenes a tus mensajes
- 💬 **Historial** — guarda tus conversaciones entre sesiones
- 🤖 **Multimodelo** — cambia entre modelos instalados desde el chat
- 🔒 **Sin nube** — todo corre localmente, tus datos no salen del USB
- ▶️ **Probar código HTML** — genera juegos y apps web y pruébalos al instante

## Requisitos

- Ubuntu 20.04 o superior
- USB de 8GB o más (ext4)
- `zstd` instalado: `sudo apt install zstd -y`

## Instalación en un USB nuevo

**1. Formatea el USB**

Primero identifica tu USB:
```bash
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT | grep -v loop
```
Busca tu USB por el tamaño y anota el nombre (ej: `sdb1`). Luego formatea (cambia `sdX1` por el tuyo):
```bash
sudo umount /dev/sdX1
sudo mkfs.ext4 -L offline-ai /dev/sdX1
udisksctl mount -b /dev/sdX1
sudo chown $USER:$USER /run/media/$USER/offline-ai
cd /run/media/$USER/offline-ai
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
bash /run/media/$USER/offline-ai/start-offline.sh
```

El chat se abre automáticamente en el navegador.

## Ejemplos de uso

**Generar y probar un juego HTML al instante:**
> "Crea un juego de Snake en HTML5"

Sparki genera el código y aparece un botón **▶ probar** junto al código para abrirlo en una pestaña nueva directamente.

**Leer un documento:**
> Sube un PDF y pregunta "resume este documento"

**Buscar información actual:**
> Activa 🌐 y pregunta "últimas noticias sobre IA"

## Modelos recomendados

| Modelo | Tamaño | Uso |
|--------|--------|-----|
| `llama3.2:3b` | 2 GB | Por defecto, texto |
| `qwen3.5:2b` | 2.7 GB | Texto e imágenes |
| `llava:7b` | 4 GB | Mejor comprensión de imágenes |
| `gemma3:4b` | 3.3 GB | Buena calidad, texto |

> ⚠️ Para ver y analizar imágenes necesitas un modelo multimodal como `qwen3.5:2b` o `llava`. El modelo por defecto solo lee el nombre del archivo.

Para instalar un modelo adicional con el USB montado:
```bash
OLLAMA_MODELS=/run/media/$USER/offline-ai/models ollama pull qwen3.5:2b
```

## Stack

- [Ollama](https://ollama.com) — motor de IA local
- Python 3.12 portable — servidor web y proxy de búsqueda
- HTML/JS puro — interfaz del chat sin dependencias externas
