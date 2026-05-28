@echo off
setlocal enabledelayedexpansion

set USB=%~dp0
set USB=%USB:~0,-1%

taskkill /F /IM llama-server.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1

set MODEL=
for %%f in ("%USB%\models\*.gguf") do (
    if "!MODEL!"=="" set MODEL=%%f
)

if "%MODEL%"=="" (
    echo No se encontro ningun modelo GGUF en la carpeta models.
    pause
    exit /b 1
)

echo Modelo encontrado: %MODEL%
echo Arrancando llama-server...
start /B "" "%USB%\llama\llama-server.exe" -m "%MODEL%" --host 127.0.0.1 --port 11434 --threads %NUMBER_OF_PROCESSORS% -c 4096 > "%TEMP%\llama.log" 2>&1

echo Esperando 15 segundos...
ping -n 16 127.0.0.1 > nul

echo Arrancando servidor chat...
start /B "" "%USB%\python\python.exe" -m http.server 8080 --directory "%USB%" > "%TEMP%\chat.log" 2>&1

echo Arrancando proxy...
start /B "" "%USB%\python\python.exe" "%USB%\search-proxy.py" > "%TEMP%\proxy.log" 2>&1

ping -n 4 127.0.0.1 > nul

echo Abriendo navegador...
start "" "http://localhost:8080/chat.html"

echo.
echo Offline AI corriendo con: %MODEL%
echo Cierra esta ventana para parar todo.
pause

taskkill /F /IM llama-server.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1
