#!/bin/bash

USB=$(findmnt -rn -S LABEL=offline-ai -o TARGET 2>/dev/null | head -1)

if [ -z "$USB" ]; then
  USB=$(find /run/media /media -maxdepth 2 -name "offline-ai" -type d 2>/dev/null | head -1)
fi

if [ -z "$USB" ]; then
  USB="$(cd "$(dirname "$0")" && pwd)"
fi

echo "USB encontrado en: $USB"

pkill -f "llama-server" 2>/dev/null
pkill -f "python.*8080" 2>/dev/null
pkill -f "python.*8081" 2>/dev/null
sleep 2

# Detectar modelo GGUF automaticamente
MODEL=$(ls "$USB/models/"*.gguf 2>/dev/null | head -1)
if [ -z "$MODEL" ]; then
  echo "No se encontro ningun modelo GGUF en models/"
  exit 1
fi

echo "Modelo: $MODEL"

echo "Arrancando llama-server con $(nproc) nucleos..."
nohup "$USB/llama/llama-server" \
  -m "$MODEL" \
  --host 127.0.0.1 \
  --port 11434 \
  --threads $(nproc) \
  -c 4096 \
  -fa auto \
  &>/tmp/llama.log &

echo "Esperando a que llama-server este listo..."
for i in $(seq 1 30); do
  if curl -s http://localhost:11434/health 2>/dev/null | grep -q "ok"; then
    echo "Servidor listo."
    break
  fi
  sleep 1
done

echo "Arrancando servidor chat..."
nohup "$USB/python-portable/bin/python3" -m http.server 8080 --directory "$USB" &>/tmp/chat.log &

# Proxy arranca siempre — necesario para archivos y expertos aunque no haya wifi
echo "Arrancando proxy..."
nohup "$USB/python-portable/bin/python3" "$USB/search-proxy.py" &>/tmp/proxy.log &

sleep 2

if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
  echo "Wifi detectado - busqueda web disponible"
else
  echo "Sin wifi - modo offline"
fi

echo "Abriendo navegador..."
(sleep 2 && xdg-open "http://localhost:8080/chat.html") &

echo ""
echo "Offline AI corriendo con: $MODEL"
echo "Para parar: pkill -f llama-server; pkill -f python"
sleep 3
