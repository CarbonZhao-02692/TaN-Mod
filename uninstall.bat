@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Travelling at Night 汉化包卸载程序

rem ============================================================
rem  TaN 汉化包一键卸载脚本
rem  用法：双击运行；或拖拽游戏根目录到本脚本上
rem  动作：1) 从最近备份恢复原文件 2) 移除 BepInEx 与 doorstop
rem ============================================================

set "GAME_NAME=Travelling at Night Demo"
set "GAME_ALT=Travelling at Night"
set "GAME_EXE=travelling.exe"

echo.
echo  === Travelling at Night 汉化包卸载程序 ===
echo  将恢复备份的原文件并移除汉化插件，游戏恢复原版。
echo.

rem ---------- 1. 检测游戏目录（同安装脚本） ----------
set "GAME_DIR="
if not "%~1"=="" (
    if exist "%~1\%GAME_EXE%" (set "GAME_DIR=%~1")
    if defined GAME_DIR echo  [拖拽] 使用游戏目录: !GAME_DIR!
)
if not defined GAME_DIR (
    call :find_steam_game
    if defined GAME_DIR echo  [Steam] 检测到游戏目录: !GAME_DIR!
)
if not defined GAME_DIR (
    echo  [手动] 请输入游戏根目录（含 %GAME_EXE% 的目录，回车则退出）：
    set /p GAME_DIR=
    if not defined GAME_DIR (echo  未输入目录，退出。 & pause & exit /b 1)
)
echo  游戏目录: !GAME_DIR!
echo.

rem ---------- 2. 确认 ----------
echo  即将执行：
echo    - 删除 !GAME_DIR!\BepInEx
echo    - 删除 winhttp.dll / .doorstop_version / doorstop_config.ini
echo    - 从 TaN_CN_Backup* 恢复原文件
set /p CONFIRM=  输入 y 确认卸载（其他任意键取消）：
if /i not "!CONFIRM!"=="y" (echo  已取消。 & pause & exit /b 0)

rem ---------- 3. 恢复备份 ----------
echo.
echo  [1/3] 恢复备份 ...
set "BACKUP="
for /d %%d in ("!GAME_DIR!\TaN_CN_Backup*") do set "BACKUP=%%d"
if defined BACKUP (
    for %%F in (winhttp.dll .doorstop_version doorstop_config.ini) do (
        if exist "!BACKUP!\%%F" copy /y "!BACKUP!\%%F" "!GAME_DIR!\%%F" >nul
    )
    if exist "!BACKUP!\BepInEx" (
        echo  删除现有 BepInEx，从备份恢复 ...
        if exist "!GAME_DIR!\BepInEx" rmdir /s /q "!GAME_DIR!\BepInEx"
        robocopy "!BACKUP!\BepInEx" "!GAME_DIR!\BepInEx" /E /NFL /NDL /NJH /NJS >nul
    )
    echo  [恢复] 已从 !BACKUP! 恢复
) else (
    echo  [提示] 未找到备份目录，跳过恢复。
)

rem ---------- 4. 移除部署 ----------
echo  [2/3] 移除部署文件 ...
if exist "!GAME_DIR!\BepInEx" rmdir /s /q "!GAME_DIR!\BepInEx"
for %%F in (winhttp.dll .doorstop_version doorstop_config.ini) do (
    if exist "!GAME_DIR!\%%F" del /f /q "!GAME_DIR!\%%F"
)

rem ---------- 5. 完成 ----------
echo  [3/3] 完成。汉化已卸载，游戏恢复原版（如需彻底清理可删除 TaN_CN_Backup* 目录）。
echo.
pause
exit /b 0

rem ============================================================
rem  find_steam_game — 同 install.bat
rem ============================================================
:find_steam_game
    set "STEAM_PATH="
    for /f "skip=2 tokens=2,*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM_PATH=%%~b"
    if not defined STEAM_PATH for /f "skip=2 tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do set "STEAM_PATH=%%~b"
    if not defined STEAM_PATH for /f "skip=2 tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul') do set "STEAM_PATH=%%~b"
    if defined STEAM_PATH set "STEAM_PATH=%STEAM_PATH:/=\%"
    if not defined STEAM_PATH exit /b 0
    set "LIBFILE=!STEAM_PATH!\steamapps\libraryfolders.vdf"
    if exist "!LIBFILE!" (
        for /f "usebackq tokens=1,*" %%a in ("!LIBFILE!") do (
            if "%%~a"=="path" (
                set "LIB=%%~b"
                set "LIB=!LIB:\\=\!"
                if exist "!LIB!\steamapps\common\!GAME_NAME!" set "GAME_DIR=!LIB!\steamapps\common\!GAME_NAME!" & exit /b 0
                if not defined GAME_DIR if exist "!LIB!\steamapps\common\!GAME_ALT!" set "GAME_DIR=!LIB!\steamapps\common\!GAME_ALT!" & exit /b 0
            )
        )
    )
    if exist "!STEAM_PATH!\steamapps\common\!GAME_NAME!" set "GAME_DIR=!STEAM_PATH!\steamapps\common\!GAME_NAME!" & exit /b 0
    if exist "!STEAM_PATH!\steamapps\common\!GAME_ALT!" set "GAME_DIR=!STEAM_PATH!\steamapps\common\!GAME_ALT!" & exit /b 0
    exit /b 0
