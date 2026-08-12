# ============================================================
#  TaN 汉化包一键卸载脚本 (PowerShell)
#  用法：双击 uninstall.bat（入口）或直接运行本脚本
#  功能：1) 从备份恢复原文件 2) 移除 BepInEx 与 doorstop
#  编码：本文件 UTF-8 with BOM（PowerShell 5.1/7 均正确识别）
# ============================================================
$ErrorActionPreference = 'Continue'
$Host.UI.RawUI.WindowTitle = 'Travelling at Night 汉化包卸载程序'

$GAME_NAME = 'Travelling at Night Demo'
$GAME_ALT  = 'Travelling at Night'
$GAME_EXE  = 'travelling.exe'

Write-Host ''
Write-Host ' === Travelling at Night 汉化包卸载程序 ==='
Write-Host '  将恢复备份的原文件并移除汉化插件，游戏恢复原版。'
Write-Host ''

# ---------- 1. 检测游戏目录（同安装脚本） ----------
$GAME_DIR = $null
if ($args.Count -gt 0) {
    $cand = $args[0]
    if (Test-Path (Join-Path $cand $GAME_EXE)) {
        $GAME_DIR = $cand
        Write-Host "  [拖拽] 使用游戏目录: $GAME_DIR"
    }
}

if (-not $GAME_DIR) {
    $steamPath = $null
    try { $steamPath = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -Name 'SteamPath' -ErrorAction Stop).SteamPath } catch {}
    if (-not $steamPath) { try { $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -Name 'InstallPath' -ErrorAction Stop).InstallPath } catch {} }
    if (-not $steamPath) { try { $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -Name 'InstallPath' -ErrorAction Stop).InstallPath } catch {} }
    if ($steamPath) {
        $steamPath = $steamPath.Replace('/', '\')
        $mainLib = Join-Path $steamPath 'steamapps\common'
        foreach ($g in @($GAME_NAME, $GAME_ALT)) {
            $cand = Join-Path $mainLib $g
            if (Test-Path (Join-Path $cand $GAME_EXE)) { $GAME_DIR = $cand; break }
        }
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
Write-Host "  游戏目录: $GAME_DIR"
Write-Host ''

# ---------- 2. 确认 ----------
Write-Host '  即将执行卸载：'
Write-Host "   - 删除 $GAME_DIR\BepInEx"
Write-Host '   - 删除 winhttp.dll / .doorstop_version / doorstop_config.ini'
Write-Host '   - 从 TaN_CN_Backup* 恢复原文件'
Write-Host ''
$ans = Read-Host '  输入 y 确认卸载（其他任意键取消）'
if ($ans -ne 'y' -and $ans -ne 'Y') {
    Write-Host '  已取消。'
    Read-Host '按回车退出'
    exit 0
}

# ---------- 3. 移除汉化 ----------
$bepDir = Join-Path $GAME_DIR 'BepInEx'
if (Test-Path $bepDir) { Remove-Item $bepDir -Recurse -Force; Write-Host '  已删除 BepInEx' }
foreach ($f in @('winhttp.dll', '.doorstop_version', 'doorstop_config.ini')) {
    $p = Join-Path $GAME_DIR $f
    if (Test-Path $p) { Remove-Item $p -Force; Write-Host "  已删除 $f" }
}

# ---------- 4. 恢复备份 ----------
$backups = Get-ChildItem -Path $GAME_DIR -Directory -Filter 'TaN_CN_Backup*' -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending
if ($backups) {
    $bak = $backups[0].FullName
    Write-Host "  从备份恢复: $bak"
    foreach ($f in @('winhttp.dll', '.doorstop_version', 'doorstop_config.ini')) {
        $src = Join-Path $bak $f
        if (Test-Path $src) { Copy-Item $src (Join-Path $GAME_DIR $f) -Force; Write-Host "  已恢复 $f" }
    }
    $bakBep = Join-Path $bak 'BepInEx'
    if (Test-Path $bakBep) {
        Copy-Item $bakBep (Join-Path $GAME_DIR 'BepInEx') -Recurse -Force
        Write-Host '  已恢复 BepInEx'
    }
} else {
    Write-Host '  未找到备份目录，跳过恢复（原文件已被移除）。'
}

Write-Host ''
Write-Host '  卸载完成。游戏已恢复原版。'
Read-Host '按回车退出'
exit 0
