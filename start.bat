@echo off
setlocal enabledelayedexpansion

set USB=%~dp0
set USB=%USB:~0,-1%

taskkill /F /IM llama-server.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1

set MODEL=
for %%f in ("%USB%\models\*.gguf") do (
  echo %%f | findstr /i "mmproj" > nul
  if errorlevel 1 (
    if "!MODEL!"=="" set MODEL=%%f
  )
)

if "%MODEL%"=="" (
  echo No se encontro ningun modelo GGUF en la carpeta models.
  pause
  exit /b 1
)

echo Modelo encontrado: %MODEL%

echo Arrancando llama-server...
start /B "" "%USB%\llama\llama-server.exe" -m "%MODEL%" --host 127.0.0.1 --port 11434 --threads %NUMBER_OF_PROCESSORS% -c 4096 > "%TEMP%\llama.log" 2>&1

echo Esperando llama-server (max 60s)...
set /a TRIES=0
:WAIT_LOOP
  ping -n 2 127.0.0.1 > nul
  set /a TRIES+=1
  curl -s http://localhost:11434/health 2>nul | findstr "ok" > nul
  if not errorlevel 1 goto SERVER_READY
  if %TRIES% geq 30 goto SERVER_READY
goto WAIT_LOOP
:SERVER_READY

echo Arrancando servidor chat...
start /B "" "%USB%\python\python.exe" -m http.server 8080 --directory "%USB%" > "%TEMP%\chat.log" 2>&1

echo Arrancando proxy...
start /B "" "%USB%\python\python.exe" "%USB%\search-proxy.py" > "%TEMP%\proxy.log" 2>&1

ping -n 3 127.0.0.1 > nul

ping -n 1 -w 2000 8.8.8.8 > nul 2>&1
if errorlevel 1 (
  echo Sin WiFi - modo offline
) else (
  echo WiFi disponible - busqueda web activada
)

echo Abriendo navegador...
start "" "http://localhost:8080/chat.html"

echo.
echo Offline AI corriendo con: %MODEL%
echo Cierra esta ventana para parar todo.
echo.

pause

taskkill /F /IM llama-server.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1
