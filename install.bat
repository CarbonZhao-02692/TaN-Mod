@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Travelling at Night 汉化包安装程序

rem ============================================================
rem  TaN 汉化包一键安装脚本
rem  用法：双击运行；或拖拽游戏根目录到本脚本上
rem  铁律：安装前自动备份到游戏目录下 TaN_CN_Backup_<日期>
rem ============================================================

set "GAME_NAME=Travelling at Night Demo"
set "GAME_EXE=travelling.exe"
set "GAME_ALT=Travelling at Night"
set "BE_VERSION=6.0.0-be.577"
set "PLUGIN_NAME=TaN.Localization"
rem payload 与 install.bat 同级（发布结构 TaN_CN/ 与开发结构 integration/ 均适用）
set "PAYLOAD=%~dp0payload"

echo.
echo  === Travelling at Night 汉化包安装程序 ===
echo  本脚本将向游戏目录部署汉化插件与译文数据。
echo  原文件会自动备份（TaN_CN_Backup_日期），卸载运行 uninstall.bat。
echo.

rem ---------- 1. 检测游戏目录（拖拽 / Steam 注册表+vdf / 手动输入） ----------
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
    echo  [手动] 请输入游戏根目录（含 exe 的目录，回车则退出）：
    set /p GAME_DIR=
    if not defined GAME_DIR (echo  未输入目录，退出。 & pause & exit /b 1)
    if not exist "!GAME_DIR!" (echo  目录不存在，退出。 & pause & exit /b 1)
)
if not exist "!GAME_DIR!\%GAME_EXE%" (
    echo  警告：未在目录中找到游戏主程序（%GAME_EXE%）。
    echo  确认目录正确后按回车继续，否则按 Ctrl+C 取消。
    pause
)
echo  游戏目录: !GAME_DIR!
echo.

rem ---------- 2. 备份原文件 ----------
set "BACKUP=!GAME_DIR!\TaN_CN_Backup"
if exist "!BACKUP!" set "BACKUP=!GAME_DIR!\TaN_CN_Backup_2"
if exist "!BACKUP!" set "BACKUP=!GAME_DIR!\TaN_CN_Backup_3"
mkdir "!BACKUP!"
echo  [1/5] 备份原文件到: !BACKUP!
for %%F in (winhttp.dll .doorstop_version doorstop_config.ini) do (
    if exist "!GAME_DIR!\%%F" copy /y "!GAME_DIR!\%%F" "!BACKUP!\%%F" >nul
)
if exist "!GAME_DIR!\BepInEx" (
    if not exist "!BACKUP!\BepInEx" robocopy "!GAME_DIR!\BepInEx" "!BACKUP!\BepInEx" /E /NFL /NDL /NJH /NJS >nul
    echo  [备份] 已备份原有 BepInEx 目录
)
echo.

rem ---------- 3. 部署 BepInEx %BE_VERSION% + 插件 + 译文数据 ----------
echo  [2/5] 部署 BepInEx %BE_VERSION% ...
if not exist "!GAME_DIR!\BepInEx\core" mkdir "!GAME_DIR!\BepInEx\core"
rem —— payload 解压（bepinex6.zip = BepInEx 6.0.0-be.577 Unity Mono）——
powershell -NoProfile -Command "Expand-Archive -Path '!PAYLOAD!\bepinex6.zip' -DestinationPath '!GAME_DIR!' -Force"

echo  [3/5] 部署插件与译文数据 ...
if not exist "!GAME_DIR!\BepInEx\plugins\TaN" mkdir "!GAME_DIR!\BepInEx\plugins\TaN"
if exist "!PAYLOAD!\plugins\%PLUGIN_NAME%.dll" (
    copy /y "!PAYLOAD!\plugins\%PLUGIN_NAME%.dll" "!GAME_DIR!\BepInEx\plugins\TaN\" >nul
) else (
    echo  提示：插件 %PLUGIN_NAME%.dll 尚未构建（阶段 6 构建后放入 integration\payload\plugins\）
)
rem 译文数据目录（镜像 extract\raw-text 结构）
if exist "!PAYLOAD!\data\loc_zh-hans" (
    if not exist "!GAME_DIR!\BepInEx\plugins\TaN\loc_zh-hans" mkdir "!GAME_DIR!\BepInEx\plugins\TaN\loc_zh-hans"
    robocopy "!PAYLOAD!\data\loc_zh-hans" "!GAME_DIR!\BepInEx\plugins\TaN\loc_zh-hans" /E /NFL /NDL /NJH /NJS >nul
)
echo.

rem ---------- 4. 自检 ----------
echo  [4/5] 自检 ...
set "SELFCHECK_OK=1"
if not exist "!GAME_DIR!\winhttp.dll"      (echo   [失败] doorstop winhttp.dll 缺失 & set "SELFCHECK_OK=0")
if not exist "!GAME_DIR!\BepInEx\core\BepInEx.Preloader.Unity.dll" if not exist "!GAME_DIR!\BepInEx\core\BepInEx.Preloader.dll" (echo   [失败] BepInEx 核心缺失 & set "SELFCHECK_OK=0")
if not exist "!GAME_DIR!\BepInEx\plugins\TaN\%PLUGIN_NAME%.dll" (echo   [警告] 插件未部署（构建后重装）)
echo.

rem ---------- 5. 完成 ----------
if "!SELFCHECK_OK!"=="1" (
    echo  [5/5] 完成。
    echo   请启动游戏（或重启已打开的实例）以加载汉化。
    echo   验证：首次启动后查看游戏目录 BepInEx\LogOutput.txt（旧版为 .log），
    echo   应包含 "TaN Localization loaded" 且无 Error。
    echo   若游戏启动异常：双击 uninstall.bat 一键恢复。
) else (
    echo  [5/5] 部署不完整，请勿启动游戏。先运行 uninstall.bat 回滚，
    echo   再检查报错项后重新运行本脚本。
)
echo.
pause
exit /b 0

rem ============================================================
rem  find_steam_game — Steam 注册表 + libraryfolders.vdf 多库检测
rem  成功则设置 GAME_DIR
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
