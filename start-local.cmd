@echo off
setlocal EnableExtensions
set "ROOT=%~dp0"
set "WEB_PORT=8090"
set "API_PORT=8787"
set "EXE=%~dp0server\target\release\speaklab-server.exe"

echo ==================================================
echo   SpeakLab ±¾µØÆô¶¯
echo     page  http://127.0.0.1:%WEB_PORT%
echo     api   http://127.0.0.1:%API_PORT%   (optional)
echo ==================================================
echo.

rem --- 1) frontend: static HTTP server (mic needs a secure context) ---
netstat -ano | findstr /r /c:":%WEB_PORT% .*LISTENING" >nul 2>&1
if errorlevel 1 (
  where python >nul 2>&1
  if errorlevel 1 (
    echo [1/3] python not found in PATH - skipping the page server.
  ) else (
    echo [1/3] starting page server on port %WEB_PORT% ...
    start "SpeakLab page" /min /d "%ROOT%" python -m http.server %WEB_PORT%
  )
) else (
  echo [1/3] page server already listening on %WEB_PORT% - skip.
)

rem --- 2) backend: Rust service (storage / LLM key / local ASR) ---
netstat -ano | findstr /r /c:":%API_PORT% .*LISTENING" >nul 2>&1
if errorlevel 1 (
  if exist "%EXE%" (
    echo [2/3] starting backend on port %API_PORT% ...
    start "SpeakLab api" /min /d "%~dp0server" "%EXE%"
  ) else (
    echo [2/3] backend exe not found - skipping ^(the page still works without it^).
    echo       to build it:  cd server  ^&^&  cargo run
  )
) else (
  echo [2/3] backend already listening on %API_PORT% - skip.
)

rem --- 3) open the browser ---
echo [3/3] opening browser ...
ping -n 3 127.0.0.1 >nul
start "" "http://127.0.0.1:%WEB_PORT%/"
echo.
echo Done. Close the two minimized windows to stop the services.
endlocal
