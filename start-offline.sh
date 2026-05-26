#!/bin/bash

# Detectar USB automáticamente
USB=$(findmnt -rn -S LABEL=local-ai -o TARGET 2>/dev/null | head -1)
if [ -z "$USB" ]; then
    USB=$(find /run/media /media -maxdepth 2 -name "local-ai" -type d 2>/dev/null | head -1)
fi
if [ -z "$USB" ]; then
    USB="$(cd "$(dirname "$0")" && pwd)"
fi
echo "USB encontrado en: $USB"

export OLLAMA_MODELS="$USB/models"
export OLLAMA_NUM_THREAD=$(nproc)
export OLLAMA_FLASH_ATTENTION=1

pkill -f "ollama serve" 2>/dev/null
pkill -f "python.*8080" 2>/dev/null
pkill -f "python.*8081" 2>/dev/null
sleep 2

DEVICE=$(findmnt -rn -T "$USB" -o SOURCE | head -1)

echo "Arrancando Ollama con $(nproc) nucleos..."
OLLAMA_HOME="$USB/ollama" OLLAMA_ORIGINS="*" nohup "$USB/ollama/bin/ollama" serve &>/tmp/ollama.log &

echo "Esperando a que Ollama esté listo..."
for i in $(seq 1 30); do
    if curl -s http://localhost:11434/api/tags &>/dev/null; then
        echo "Ollama listo."
        break
    fi
    sleep 1
done

echo "Precalentando modelo..."
curl -s http://localhost:11434/api/generate \
  -d '{"model":"qwen3.5:2b","prompt":"hola","stream":false}' \
  &>/dev/null &

echo "Arrancando servidor chat..."
nohup "$USB/python-portable/bin/python3" -m http.server 8080 --directory "$USB" &>/tmp/chat.log &

echo "Arrancando proxy de archivos y busqueda..."
nohup "$USB/python-portable/bin/python3" "$USB/search-proxy.py" &>/tmp/search-proxy.log &

sleep 2
echo "Abriendo navegador..."
(sleep 2 && xdg-open "http://localhost:8080/chat.html") &

echo ""
echo "Local AI corriendo en segundo plano."
echo "   Chat: http://localhost:8080/chat.html"
echo "   Para parar: pkill -f 'ollama serve'; pkill -f 'python'"
sleep 3
