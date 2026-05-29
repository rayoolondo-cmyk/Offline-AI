# Offline AI - Asistente de IA portátil en USB

Lleva tu propio asistente de inteligencia artificial en un USB. Funciona en cualquier Ubuntu o Windows sin instalar nada en el sistema.

## ¿Qué es?

Offline AI es un asistente de IA completamente portable que arranca desde un USB. Todo lo necesario va dentro del USB: el motor de IA, los modelos, Python y el chat web.

## Características

- 🔌 **100% portable** — conecta el USB y ejecuta un script, nada más
- 🪟 **Linux y Windows** — mismo chat, mismos archivos, distinto motor de IA
- 🌐 **Chat web local** — interfaz en el navegador sin internet
- 🔍 **Búsqueda web** — cuando hay wifi, busca información actual
- 📎 **Lee archivos** — PDF, Word, Excel, PowerPoint, TXT, código...
- 🖼 **Sube imágenes** — adjunta imágenes a tus mensajes con compresión automática
- 💬 **Historial** — guarda tus conversaciones entre sesiones (imágenes incluidas)
- 🤖 **Multimodelo** — cambia, descarga y elimina modelos desde el chat
- ☁️ **Modelos cloud** — usa modelos de Ollama Cloud con tu cuenta (solo Linux, requiere suscripción)
- 🔗 **Vincular cuenta** — conecta tu cuenta de ollama.com desde el chat
- 🔒 **Credenciales portables** — tu sesión de Ollama se guarda en el USB
- ▶️ **Probar código HTML** — genera juegos y apps web y pruébalos al instante
- ❌ **Cancelar respuesta** — cancela la generación en cualquier momento

---

## 🐧 Instalación en Linux (Ubuntu)

### Requisitos
- Ubuntu 20.04 o superior
- USB de 8GB o más (ext4)
- `zstd` instalado: `sudo apt install zstd -y`

### 1. Formatea el USB

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

### 2. Descarga Ollama
```bash
mkdir -p ollama
curl -L "https://github.com/ollama/ollama/releases/download/v0.24.0/ollama-linux-amd64.tar.zst" -o /tmp/ollama.tar.zst
tar -I zstd -xf /tmp/ollama.tar.zst -C ollama/
```

### 3. Descarga Python portable
```bash
curl -L https://github.com/indygreg/python-build-standalone/releases/download/20240814/cpython-3.12.5+20240814-x86_64-unknown-linux-gnu-install_only.tar.gz -o /tmp/python.tar.gz
tar xzf /tmp/python.tar.gz && mv python python-portable && rm /tmp/python.tar.gz
```

### 4. Instala librerías Python
```bash
python-portable/bin/pip3 install PyPDF2 python-docx openpyxl python-pptx -q
```

> `PyPDF2` — leer PDFs | `python-docx` — Word | `openpyxl` — Excel | `python-pptx` — PowerPoint

### 5. Descarga el modelo
```bash
OLLAMA_HOME=$PWD/ollama OLLAMA_MODELS=$PWD/models ollama/bin/ollama serve &
sleep 3
OLLAMA_HOME=$PWD/ollama OLLAMA_MODELS=$PWD/models ollama/bin/ollama pull llama3.2:3b
```

### 6. Copia los archivos al USB

Descarga `chat.html`, `start-offline.sh` y `search-proxy.py` de este repositorio y cópialos al USB.

```bash
chmod +x start-offline.sh
```

### Uso en Linux

Conecta el USB en cualquier Ubuntu y ejecuta:
```bash
bash /run/media/$USER/offline-ai/start-offline.sh
```

---

## 🪟 Instalación en Windows

### Requisitos
- Windows 10 o superior (64 bits)
- USB de 8GB o más (exFAT)

### 1. Formatea el USB en exFAT

En Windows, abre el explorador de archivos, haz clic derecho en el USB → **Formatear** → Sistema de archivos: **exFAT** → Etiqueta: `offline-ai`.

### 2. Descarga llama.cpp para Windows

Descarga el zip de CPU desde [github.com/ggml-org/llama.cpp/releases](https://github.com/ggml-org/llama.cpp/releases), busca `llama-bXXXX-bin-win-cpu-x64.zip` y extrae el contenido en la carpeta `llama\` del USB.

### 3. Descarga Python embeddable para Windows

Descarga `python-3.12.x-embed-amd64.zip` desde [python.org/downloads](https://www.python.org/downloads/windows/) y extrae el contenido en la carpeta `python\` del USB.

### 4. Instala las librerías Python

Edita el archivo `python\python312._pth` y asegúrate de que contiene estas líneas:
```
python312.zip
.
import site
Lib\site-packages
```

Luego instala las librerías desde PowerShell:
```powershell
.\python\python.exe .\python\get-pip.py
.\python\python.exe -m pip install PyPDF2 python-docx openpyxl python-pptx --target .\python\Lib\site-packages\
```

> `PyPDF2` — leer PDFs | `python-docx` — Word | `openpyxl` — Excel | `python-pptx` — PowerPoint

### 5. Descarga un modelo GGUF

Descarga cualquier modelo en formato `.gguf` y colócalo en la carpeta `models\` del USB. Recomendado para empezar:

[Qwen2.5-0.5B-Instruct-Q4_K_M.gguf](https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf)

### 5. Copia los archivos al USB

Descarga `chat.html`, `start.bat` y `search-proxy.py` de este repositorio y cópialos al USB.

### Uso en Windows

Haz doble clic en `start.bat`. Espera a que cargue el modelo y el chat se abrirá automáticamente en el navegador.

---

## Ejemplos de uso

**Generar y probar un juego HTML al instante:**
> "Crea un juego de Snake en HTML5"

Sparki genera el código y aparece un botón **▶ probar** junto al código para abrirlo en una pestaña nueva directamente.

**Analizar una imagen:**
> Sube una foto y pregunta "¿qué ves en esta imagen?"

Las imágenes se comprimen automáticamente y se guardan en el historial entre sesiones.

**Leer un documento:**
> Sube un PDF, Word, Excel o PowerPoint y pregunta "resume este documento"

**Buscar información actual:**
> Activa 🌐 y pregunta "últimas noticias sobre IA"

**Usar modelos cloud (solo Linux):**
> Pulsa **+** → escribe `glm-5:cloud` → **Usar / Descargar**

Necesitas vincular tu cuenta de ollama.com con el botón **🔗 Cuenta**. Los modelos cloud requieren suscripción.

---

## Modelos recomendados

### Linux (Ollama)

| Modelo | Tamaño | Uso |
|--------|--------|-----|
| `llama3.2:3b` | 2 GB | Por defecto, texto |
| `qwen3.5:2b` | 2.7 GB | Texto e imágenes |
| `gemma4:e4b` | 4 GB | Texto e imágenes, alta calidad |
| `llava:7b` | 4 GB | Especializado en imágenes |

### Windows (llama.cpp GGUF)

| Modelo | Tamaño | Uso |
|--------|--------|-----|
| `Qwen2.5-0.5B-Q4_K_M.gguf` | 400 MB | Ligero, texto |
| `Qwen2.5-1.5B-Q4_K_M.gguf` | 1 GB | Buena calidad, texto |
| `Llama-3.2-3B-Q4_K_M.gguf` | 2 GB | Alta calidad, texto |

> ⚠️ Para ver y analizar imágenes necesitas un modelo multimodal como `qwen3.5:2b` (Linux) o `llava` (Windows).

---

## Vincular cuenta Ollama (modelos cloud, solo Linux)

Para usar modelos cloud, vincula tu cuenta desde el chat (**+ → 🔗 Cuenta**) o desde terminal:
```bash
OLLAMA_HOME=/run/media/$USER/offline-ai/ollama /run/media/$USER/offline-ai/ollama/bin/ollama signin
```

Las credenciales se guardan en el USB y funcionan en cualquier ordenador Linux.

---

## Stack

- [Ollama](https://ollama.com) — motor de IA local y cloud (Linux)
- [llama.cpp](https://github.com/ggml-org/llama.cpp) — motor de IA portable (Windows)
- Python 3.12 portable — servidor web, proxy de búsqueda y lectura de archivos
- HTML/JS puro — interfaz del chat sin dependencias externas
