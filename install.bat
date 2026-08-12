@echo off
rem ============================================================
rem  TaN Localization Installer (entry point)
rem  This file is pure ASCII - encoding-safe on any codepage.
rem  Actual logic lives in install.ps1 (UTF-8 with BOM).
rem ============================================================
setlocal
set "PS1=%~dp0install.ps1"
if not exist "%PS1%" (
    echo [ERROR] install.ps1 not found next to this script.
    echo         Keep install.bat and install.ps1 in the same folder.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
exit /b %errorlevel%
