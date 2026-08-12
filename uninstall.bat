@echo off
rem ============================================================
rem  TaN Localization Uninstaller (entry point)
rem  This file is pure ASCII - encoding-safe on any codepage.
rem  Actual logic lives in uninstall.ps1 (UTF-8 with BOM).
rem ============================================================
setlocal
set "PS1=%~dp0uninstall.ps1"
if not exist "%PS1%" (
    echo [ERROR] uninstall.ps1 not found next to this script.
    echo         Keep uninstall.bat and uninstall.ps1 in the same folder.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
exit /b %errorlevel%
