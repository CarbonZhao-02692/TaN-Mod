# TaN钢源汉化Mod

《Travelling at Night》Demo 简体中文本地化 Mod（BepInEx 插件式注入，非修改式）。

## 包含内容

| 文件/目录 | 说明 |
|---|---|
| `install.bat` | 一键安装（双击运行，无需管理员权限） |
| `uninstall.bat` | 一键卸载，恢复原版（双击运行） |
| `payload/` | 部署负载：BepInEx 6 运行时 + 汉化插件 + 译文数据 |
| `README.md` | 本说明 |

## 安装

1. 双击 `install.bat`
2. 脚本自动检测游戏目录（Steam 注册表 + 多库扫描）；未检测到时手动输入路径，或把游戏根目录拖到脚本图标上
3. 脚本自动备份原文件到游戏目录下 `TaN_CN_Backup*`（卸载/还原用），随后部署并自检
4. 提示完成后**重启游戏**（若游戏已打开）

## 验证是否生效

- 游戏内对话、界面文本应显示为简体中文
- 中文字体自动注入（微软雅黑），无需手动配置
- 安装日志见游戏目录 `TaN_CN_install.log`

## 卸载

1. 双击 `uninstall.bat`
2. 脚本自动从备份目录还原原版文件，并移除 BepInEx 与插件
3. 重启游戏即恢复英文原版

## 使用说明与注意事项

- **存档兼容**：本 Mod 不修改存档与游戏数据，仅运行时替换显示文本，存档可随时切换中/英
- **游戏更新**：游戏版本更新后如译文未生效，请等待汉化包更新（内置指纹防错位机制）
- **备份目录**：`TaN_CN_Backup*` 为安装时自动备份，请勿删除（卸载需要）
- **已知限制**：部分 UI 命名纹理（约 315 处）为图片形式，无法文本汉化，属正常现象
- **已知限制**：游戏内「新闻」按钮的更新日志（patch notes）尚未翻译，后续版本补译


## 译文对照表与术语表

本 Release 附两份参考数据（仓库 docs/ 目录同步收录）：

| 文件 | 内容 | 用途 |
|---|---|---|
| translation-table.csv | 全量 6698 条原文-译文对照（entry_id / source_text 原文 / translation_zh 译文） | 校对、审阅、二次修改参考 |
| glossary-upload.csv | 术语表 516 行（英文术语 / 中文定译 / 类别 / 来源 / 状态 / 依据） | 术语统一性核查，欢迎社区指正 |

两份文件均为 UTF-8（含 BOM），可用 Excel/WPS 直接打开。

## 翻译说明

- 文本量：6698 条（对话/状态/道具/界面全量覆盖）
- 术语基准：Cultist Simulator 官方中文 + 前作《司辰之书》定译 + paratranz 人工译者阵地 + 灰机 wiki
- 特约定译示例：漫宿、噤声居屋、司辰、法兰西斧币、太阳居屋、迷金症/恋金癖、凋零

## 免责声明

本汉化包为非官方社区作品，仅供学习交流。若游戏作者或发行方认为构成侵权，请联系仓库所有者下架。

## 致谢

- 游戏作者允许本地化与 Mod 制作
- paratranz.cn 人工译者阵地（术语参考）
- 灰机 wiki（cultist/boh）前作定译参考
- BepInEx 与 Harmony 开源项目

## 版本历史

- v0.0.2（2026-08-12）：修复版——BepInEx 5.4.23.5(兼容 Unity 6000)+UI 文本替换；全量 6698 条；术语基准 CS 官方中文 + paratranz 人工译者 + 灰机 wiki；特约定译（漫宿/噤声居屋/法兰西斧币/太阳居屋/迷金症/恋金癖/凋零等）
- v0.0.2a（2026-08-12，数据更新）：术语裁决批量生效——Arts Unconsidered→未识技艺、patrocinia→圣庇、House(the)→居屋、Corona→冕、Gleam→烁、Aubière→奥比埃、Menninger→曼宁格、Huissier→韦西耶、Onteiric→太虚/太虚的、Onteirology→太虚学、Onteiric Coordination→冥合（冥合办公室）、骄阳句双关定译；SO 遗漏文本 282 条补入（含冥合办公室物品描述）；司辰全量 36 位术语入库（双生女巫=Witch-and-Sister / 双生巫女=Sister-and-Witch、Vagabond→浪游旅人可简称旅人）；mapping 6296 条
- v0.0.2a 安装脚本更新（2026-08-12）：修复 bat 编码兼容问题——入口 install.bat / uninstall.bat 改纯 ASCII + 新增 install.ps1 / uninstall.ps1（UTF-8 with BOM），兼容 Windows 默认 GBK(936) 与全局 UTF-8(65001) 双代码页；修复部分系统双击 bat 报格式错误/乱码的问题（根因：UTF-8 无 BOM bat 在 GBK 系统 cmd 下字节偏移错乱）
- v0.0.3（2026-08-12，术语定稿 + 文学引用核查）：本轮 20 项术语裁决落地——Iasnate Eye→亚斯纳特之眼（祆教 Yasna 词源）、Ivinek→魅爪仪式（布列塔尼语词典词）、Chrysolepsis→金痫、CHRYSOCLASM→崩解于金色（入迷四阶：迷金症→恋金癖→金痫→崩解于金色）、Mr Chi's Splendid Emporium→齐先生的骄盛商行、Mufti→便装、Pragmatism collapses abstraction→务实压垮抽象、Xose Xinfluence→可塞景响、Zophistication→贼世故、Xegerdemain→小手法（调试玩笑词照译）、Kedgeree→英式鱼蛋烩饭、Rejoined→归队、BitField→位字段、Outfits 三档（盔甲/魅力/场合）、Sil→西尔、dreamitarium→梦境疗养院、边境疗养院（Sanitarium-in-the-Bounds）；Bounds→边境 统一清理（边界之地旧译 6 处）；真实文学引用核查（启示录 3:20 和合本、君士坦丁 In hoc signo vinces、长枪党口号统一伟大自由、查良铮奥西曼提斯、木偶的步态舞等）；glossary 563 词条；mapping 6294 条

### 安装脚本编码说明
- 入口 install.bat / uninstall.bat 为纯 ASCII，双击即可（任意代码页环境无乱码）
- 实际逻辑在 install.ps1 / uninstall.ps1（UTF-8 with BOM，PowerShell 5.1/7 兼容）
- 兼容 Windows 默认 GBK(936) 与全局 UTF-8(65001) 两种系统
- Steam 游戏目录自动检测（注册表 + libraryfolders.vdf 多库，原生 UTF-8 读取）

### 司辰术语（v0.0.2a 起）
- 全量 36 司辰定译入库（灰机秘史维基 + 官方英文 wiki + 裂楔图书馆三源核对）
- 双生女巫=Witch-and-Sister / 双生巫女=Sister-and-Witch（勿混淆）
- Vagabond→浪游旅人（可简称旅人）
