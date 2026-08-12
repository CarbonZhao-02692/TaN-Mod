# ============================================================
#  TaN 汉化包一键安装脚本 (PowerShell)
#  用法：双击 install.bat（入口）或直接运行本脚本
#  铁律：安装前自动备份到游戏目录下 TaN_CN_Backup_<日期>
#  编码：本文件 UTF-8 with BOM（PowerShell 5.1/7 均正确识别）
# ============================================================
$ErrorActionPreference = 'Continue'
$Host.UI.RawUI.WindowTitle = 'Travelling at Night 汉化包安装程序'

$GAME_NAME = 'Travelling at Night Demo'
$GAME_ALT  = 'Travelling at Night'
$GAME_EXE  = 'travelling.exe'
$BE_VERSION = '6.0.0-be.577'
$PLUGIN_NAME = 'TaN.Localization'
$PAYLOAD   = Join-Path $PSScriptRoot 'payload'

Write-Host ''
Write-Host ' === Travelling at Night 汉化包安装程序 ==='
Write-Host '  本脚本将向游戏目录部署汉化插件与译文数据。'
Write-Host '  原文件会自动备份（TaN_CN_Backup_日期），卸载运行 uninstall.bat。'
Write-Host ''

# ---------- 1. 检测游戏目录（拖拽 / Steam 注册表+vdf / 手动输入） ----------
$GAME_DIR = $null
if ($args.Count -gt 0) {
    $cand = $args[0]
    if (Test-Path (Join-Path $cand "$GAME_EXE")) {
        $GAME_DIR = $cand
        Write-Host "  [拖拽] 使用游戏目录: $GAME_DIR"
    }
}

if (-not $GAME_DIR) {
    # Steam 注册表检测
    $steamPath = $null
    try { $steamPath = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -Name 'SteamPath' -ErrorAction Stop).SteamPath } catch {}
    if (-not $steamPath) { try { $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -Name 'InstallPath' -ErrorAction Stop).InstallPath } catch {} }
    if (-not $steamPath) { try { $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -Name 'InstallPath' -ErrorAction Stop).InstallPath } catch {} }
    if ($steamPath) {
        $steamPath = $steamPath.Replace('/', '\')
        # 主库
        $mainLib = Join-Path $steamPath 'steamapps\common'
        foreach ($g in @($GAME_NAME, $GAME_ALT)) {
            $cand = Join-Path $mainLib $g
            if (Test-Path (Join-Path $cand $GAME_EXE)) { $GAME_DIR = $cand; break }
        }
        # 多库 vdf（PowerShell 原生 UTF-8 读取，无乱码）
        if (-not $GAME_DIR) {
            $vdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
            if (Test-Path $vdf) {
                $paths = Get-Content $vdf -Encoding UTF8 | Where-Object { $_ -match '"path"' } | ForEach-Object {
                    $_.Replace('"path"', '').Replace('"', '').Trim()
                }
                foreach ($lib in $paths) {
                    foreach ($g in @($GAME_NAME, $GAME_ALT)) {
                        $cand = Join-Path $lib "steamapps\common\$g"
                        if (Test-Path (Join-Path $cand $GAME_EXE)) { $GAME_DIR = $cand; break }
                    }
                    if ($GAME_DIR) { break }
                }
            }
        }
        if ($GAME_DIR) { Write-Host "  [Steam] 检测到游戏目录: $GAME_DIR" }
    }
}

if (-not $GAME_DIR) {
    Write-Host '  [手动] 请输入游戏根目录（含 exe 的目录，回车则退出）：'
    $input = Read-Host
    if ([string]::IsNullOrWhiteSpace($input)) { Write-Host '  未输入目录，退出。'; Read-Host '按回车退出'; exit 1 }
    if (-not (Test-Path $input)) { Write-Host '  目录不存在，退出。'; Read-Host '按回车退出'; exit 1 }
    $GAME_DIR = $input
}

if (-not (Test-Path (Join-Path $GAME_DIR $GAME_EXE))) {
    Write-Host "  警告：未在目录中找到游戏主程序（$GAME_EXE）。"
    Write-Host '  确认目录正确后按回车继续，否则按 Ctrl+C 取消。'
    Read-Host
}
Write-Host "  游戏目录: $GAME_DIR"
Write-Host ''

# ---------- 2. 备份原文件 ----------
$BACKUP = Join-Path $GAME_DIR 'TaN_CN_Backup'
$i = 2
while ((Test-Path $BACKUP) -and ($i -le 9)) { $BACKUP = Join-Path $GAME_DIR "TaN_CN_Backup_$i"; $i++ }
New-Item -ItemType Directory -Path $BACKUP -Force | Out-Null
Write-Host "  [1/5] 备份原文件到: $BACKUP"

foreach ($f in @('winhttp.dll', '.doorstop_version', 'doorstop_config.ini')) {
    $src = Join-Path $GAME_DIR $f
    if (Test-Path $src) { Copy-Item $src (Join-Path $BACKUP $f) -Force }
}
$bepDir = Join-Path $GAME_DIR 'BepInEx'
if (Test-Path $bepDir) {
    $bepBak = Join-Path $BACKUP 'BepInEx'
    if (-not (Test-Path $bepBak)) { Copy-Item $bepDir $bepBak -Recurse -Force }
    Write-Host '  [备份] 已备份原有 BepInEx 目录'
}
Write-Host ''

# ---------- 3. 部署 BepInEx + 插件 + 译文数据 ----------
Write-Host "  [2/5] 部署 BepInEx $BE_VERSION ..."
$bepZip = Join-Path $PAYLOAD 'bepinex6.zip'
if (Test-Path $bepZip) {
    Expand-Archive -Path $bepZip -DestinationPath $GAME_DIR -Force
} else {
    Write-Host '  [错误] 未找到 payload\bepinex6.zip'
}

Write-Host '  [3/5] 部署插件与译文数据 ...'
$pluginDir = Join-Path $GAME_DIR "BepInEx\plugins\TaN"
New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
$dll = Join-Path $PAYLOAD "plugins\$PLUGIN_NAME.dll"
if (Test-Path $dll) {
    Copy-Item $dll (Join-Path $pluginDir "$PLUGIN_NAME.dll") -Force
} else {
    Write-Host "  提示：插件 $PLUGIN_NAME.dll 尚未构建（阶段 6 构建后放入 payload\plugins\）"
}
$locData = Join-Path $PAYLOAD 'data\loc_zh-hans'
if (Test-Path $locData) {
    $locDest = Join-Path $pluginDir 'loc_zh-hans'
    if (-not (Test-Path $locDest)) { New-Item -ItemType Directory -Path $locDest -Force | Out-Null }
    Copy-Item (Join-Path $locData '*') $locDest -Recurse -Force
}
Write-Host ''

# ---------- 4. 自检 ----------
Write-Host '  [4/5] 自检 ...'
$SELFCHECK_OK = $true
if (-not (Test-Path (Join-Path $GAME_DIR 'winhttp.dll'))) { Write-Host '   [失败] doorstop winhttp.dll 缺失'; $SELFCHECK_OK = $false }
$pre1 = Join-Path $GAME_DIR 'BepInEx\core\BepInEx.Preloader.Unity.dll'
$pre2 = Join-Path $GAME_DIR 'BepInEx\core\BepInEx.Preloader.dll'
if (-not (Test-Path $pre1) -and -not (Test-Path $pre2)) { Write-Host '   [失败] BepInEx 核心缺失'; $SELFCHECK_OK = $false }
if (-not (Test-Path (Join-Path $pluginDir "$PLUGIN_NAME.dll"))) { Write-Host '   [警告] 插件未部署（构建后重装）' }
Write-Host ''

# ---------- 5. 完成 ----------
if ($SELFCHECK_OK) {
    Write-Host '  [5/5] 完成。'
    Write-Host '   请启动游戏（或重启已打开的实例）以加载汉化。'
    Write-Host '   验证：首次启动后查看游戏目录 BepInEx\LogOutput.txt（旧版为 .log），'
    Write-Host '   应包含 "TaN Localization loaded" 且无 Error。'
    Write-Host '   若游戏启动异常：双击 uninstall.bat 一键恢复。'
} else {
    Write-Host '  [5/5] 部署不完整，请勿启动游戏。先运行 uninstall.bat 回滚，'
    Write-Host '   再检查报错项后重新运行本脚本。'
}
Write-Host ''
Read-Host '按回车退出'
exit 0
