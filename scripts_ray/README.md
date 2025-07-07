# Useful Scripts Collection

一个实用脚本集合，包含文档转换、文件管理、系统自动化等各种工具，主要适用于 macOS 系统。

## 🚀 项目概述

本项目旨在提供一系列实用的脚本工具，帮助用户自动化日常工作流程，包括：

- **文档转换**：支持 DOC/DOCX/PPTX/PDF/Markdown 等格式之间的转换
- **表格处理**：CSV/XLS/XLSX 格式转换和数据处理
- **文件管理**：批量文件操作、提取、合并等功能
- **系统自动化**：Raycast 集成、Yabai 窗口管理、应用程序管理
- **实用工具**：文本处理、Token 计算、图片转换等

## 📁 项目结构

```
useful_scripts/
├── 📄 文档转换工具
│   ├── convert_all.sh          # 综合文档转换工具
│   ├── markitdown_docx2md.sh   # DOCX 转 Markdown
│   ├── pptx2md.py             # PowerPoint 转 Markdown
│   └── d2t_pandoc.sh          # DOC/DOCX 转文本
│
├── 📊 表格处理工具
│   ├── csv2xls.py             # CSV 转 Excel
│   ├── splitsheets.py         # Excel 工作表分离
│   ├── mergecsv.sh           # CSV 文件合并
│   └── csvtxtxlsx/           # 表格格式转换工具集
│
├── 🗂️ 文件管理工具
│   ├── ext_img_dp.py         # 从文档提取图片
│   ├── ext_tab_dp.py         # 从文档提取表格
│   ├── extract_md_files.sh   # 提取 Markdown 文件
│   ├── move_files_up.sh      # 文件向上移动
│   └── list/                 # 文件列表管理工具
│
├── ⚡ Raycast 集成
│   └── raycast/              # Raycast 快捷脚本集合
│       ├── trf/              # 文件转换脚本
│       └── yabai/            # 窗口管理脚本
│
├── 🖥️ 系统工具
│   ├── yabai/                # Yabai 窗口管理器配置
│   ├── launch_mis.sh         # 应用程序管理
│   ├── list_app.sh          # 运行应用列表
│   └── pip_update.sh        # Python 包更新
│
└── 🛠️ 实用工具
    ├── gettoken.py          # Token 数量计算
    ├── wmf2png.sh          # WMF 图片转换
    └── others/             # 其他实用脚本
```

## 🎯 主要功能

### 1. 文档转换
- **一键批量转换**：支持 DOC → DOCX → Markdown 的完整转换链
- **PowerPoint 转换**：将 PPTX 转换为结构化的 Markdown，保留图片和表格
- **格式保留**：尽可能保持原文档的格式和结构

### 2. 表格处理
- **多格式支持**：CSV、XLS、XLSX 之间的相互转换
- **工作表分离**：将多工作表的 Excel 文件分离成单独文件
- **数据合并**：智能合并多个 CSV 文件

### 3. 内容提取
- **图片提取**：从 DOCX/PPTX 文档中提取所有图片，支持 WMF 转 PNG
- **表格提取**：提取文档中的表格并转换为 CSV/Markdown 格式
- **内容管理**：创建符号链接便于统一管理提取的内容

### 4. Raycast 集成
- **快速转换**：通过 Raycast 快速执行文件格式转换
- **窗口管理**：集成 Yabai 的窗口操作命令
- **应用启动**：快速启动常用应用程序

## 🔧 系统要求

- **操作系统**：macOS 10.15 或更高版本
- **Python**：3.7+ (推荐使用 Miniforge)
- **依赖工具**：
  - Microsoft Office (用于 DOC/XLS 转换)
  - LibreOffice (用于 WMF 图片转换)
  - Pandoc (用于文档转换)
  - markitdown (用于 Markdown 转换)

| 脚本名称 | 功能说明 |
|---------|---------|
| common_functions.sh | 通用 Shell 函数库,提供常用功能 |
| common_utils.py | Python 通用工具函数库 |
| convert_csv_to_txt.py | 将 CSV 文件转换为纯文本文件 |
| convert_csv_to_xlsx.py | 将 CSV 文件转换为 Excel 文件 |
| convert_doc_to_text.sh | 将 DOC 文档转换为纯文本 |
| convert_docx_to_md.sh | 将 DOCX 文档转换为 Markdown |
| convert_docx_to_pdf.sh | 将 DOCX 文档转换为 PDF |
| convert_office_batch.sh | 批量转换 Office 文档 |
| convert_pptx_to_md.py | 将 PPT 演示文稿转换为 Markdown |
| convert_txt_to_csv.py | 将纯文本转换为 CSV 格式 |
| convert_txt_to_xlsx.py | 将纯文本转换为 Excel 文件 |
| convert_wmf_to_png.py | 将 WMF 图片转换为 PNG 格式 |
| convert_xlsx_to_csv.py | 将 Excel 文件转换为 CSV |
| convert_xlsx_to_txt.py | 将 Excel 文件转换为纯文本 |
| extract_images_office.py | 从 Office 文档中提取图片 |
| extract_markdown_files.sh | 提取并处理 Markdown 文件 |
| extract_tables_office.py | 从 Office 文档中提取表格 |
| extract_text_tokens.py | 提取文本中的 Token 数量 |
| file_move_up_level.sh | 将文件移动到上一级目录 |
| link_bind_files.py | 创建文件绑定链接 |
| link_create_aliases.sh | 创建文件别名链接 |
| link_images_central.sh | 集中管理图片链接 |
| list_applications.sh | 列出已安装的应用程序 |
| manage_app_launcher.sh | 管理应用程序启动器 |
| manage_pip_packages.sh | 管理 Python 包更新 |
| merge_csv_files.sh | 合并多个 CSV 文件 |
| merge_markdown_files.sh | 合并多个 Markdown 文件 |
| paste_to_finder.sh | 粘贴内容到 Finder |
| ray_toggle_raycast.sh | 切换 Raycast 快捷功能 |
| simple_paste.sh | 简单的粘贴功能 |
| splitsheets.py | 拆分 Excel 工作表为单独文件 |
| compress_select.sh | 智能ZIP压缩工具 - 压缩文件/文件夹（支持命令行+Finder） |
