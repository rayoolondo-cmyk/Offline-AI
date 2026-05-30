# 🦞 Offline AI - Asistente de IA portátil en USB

Lleva tu propio asistente de inteligencia artificial en un USB. Funciona en cualquier Ubuntu o Windows sin instalar nada en el sistema.

## ¿Qué es?

Offline AI es un asistente de IA completamente portable que arranca desde un USB. Todo lo necesario va dentro del USB: el motor de IA (llama.cpp), los modelos, Python y el chat web.

## Características

- 🔌 **100% portable** — conecta el USB y ejecuta un script, nada más
- 🪟 **Linux y Windows** — mismo chat, mismos archivos, mismo motor de IA
- 🌐 **Chat web local** — interfaz en el navegador sin internet
- 🔍 **Búsqueda web** — cuando hay wifi, busca información actual
- 📎 **Lee archivos** — PDF, Word, Excel, PowerPoint, TXT, código...
- 🖼 **Sube imágenes** — adjunta imágenes con compresión automática
- 💬 **Historial** — guarda tus conversaciones entre sesiones (imágenes incluidas)
- 🤖 **Cambio de modelo** — cambia entre modelos GGUF desde el chat con el botón **+**
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

### 2. Descarga llama.cpp para Linux
```bash
mkdir -p llama
curl -L "https://github.com/ggml-org/llama.cpp/releases/download/b9374/llama-b9374-bin-ubuntu-x64.tar.gz" -o /tmp/llama-linux.tar.gz
tar xzf /tmp/llama-linux.tar.gz -C llama/
mv llama/llama-b9374/* llama/ && rm -rf llama/llama-b9374
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

### 5. Descarga un modelo GGUF
```bash
mkdir -p models
curl -L "https://huggingface.co/bartowski/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf" -o models/qwen2.5-1.5b.gguf
```

Para modelos con visión necesitas dos archivos — el modelo y su proyector:
```bash
| `gemma-3-1b-it-Q4_K_M.gguf` | 1.1 GB | Texto e imágenes (proyector incluido) |
| `gemma-3-4b-it-Q4_K_M.gguf` | 3.3 GB | Mejor calidad con imágenes (proyector incluido) |
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

[Qwen2.5-1.5B-Instruct-Q4_K_M.gguf](https://huggingface.co/bartowski/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf)

### 6. Copia los archivos al USB

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

Las imágenes se comprimen automáticamente y se guardan en el historial entre sesiones. Para análisis de imágenes necesitas un modelo con visión.

**Leer un documento:**
> Sube un PDF, Word, Excel o PowerPoint y pregunta "resume este documento"

**Buscar información actual:**
> Activa 🌐 y pregunta "últimas noticias sobre IA"

**Cambiar de modelo:**
> Pulsa **+** → selecciona el modelo → **Usar**

El servidor se reinicia automáticamente con el nuevo modelo.

---

## Modelos recomendados

| Modelo | Tamaño | Uso |
|--------|--------|-----|
| `Qwen2.5-0.5B-Q4_K_M.gguf` | 400 MB | Muy ligero, texto |
| `Qwen2.5-1.5B-Q4_K_M.gguf` | 1 GB | Buena calidad, texto |
| `Qwen2.5-3B-Q4_K_M.gguf` | 2 GB | Alta calidad, texto |
| `gemma-3-1b-it-Q4_K_M.gguf` + `mmproj-*.gguf` | 1.1 GB | Texto e imágenes |
| `gemma-3-4b-it-Q4_K_M.gguf` + `mmproj-*.gguf` | 3.3 GB | Mejor calidad con imágenes |

> ⚠️ Para modelos con visión coloca tanto el archivo del modelo como el archivo `mmproj-*.gguf` en la carpeta `models/`.

Los modelos GGUF se pueden encontrar en [huggingface.co/bartowski](https://huggingface.co/bartowski) y [huggingface.co/ggml-org](https://huggingface.co/ggml-org).

---

## Stack

- [llama.cpp](https://github.com/ggml-org/llama.cpp) — motor de IA portable para Linux y Windows
- Python 3.12 portable — servidor web, proxy de búsqueda y lectura de archivos
- HTML/JS puro — interfaz del chat sin dependencias externas
