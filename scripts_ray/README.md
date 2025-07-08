# 实用工具脚本集合

这是一系列用于macOS的实用工具脚本，旨在自动化日常的文件处理、格式转换和系统管理任务。所有脚本都经过重构，以实现代码的简洁性、一致性和可维护性。

## 设计原则

- **代码即文档**: 脚本应尽可能自解释，避免不必要的注释。
- **模块化**: 通用功能被提取到 `common_functions.sh` (Bash) 和 `common_utils.py` (Python) 中。
- **一致性**: 所有脚本都遵循统一的结构、参数处理和消息输出标准。
- **简洁性**: 每个脚本都保持在200行以内，专注于核心功能。

## 安装

### 1. 克隆仓库

```bash
git clone <your-repo-url>
cd useful_scripts
```

### 2. 安装依赖

#### Python 依赖

所有Python脚本的依赖都已在 `requirements.txt` 中列出。

```bash
pip3 install -r scripts_ray/requirements.txt
```

#### 系统依赖

某些脚本需要通过 Homebrew 安装系统工具：

- **pandoc**: 用于文档格式转换。
  ```bash
  brew install pandoc
  ```
- **LibreOffice**: 用于Office文档的高保真转换。
  ```bash
  brew install --cask libreoffice
  ```

## 脚本说明

### 文件操作 (`file_ops.sh`)

这是一个文件处理工具的启动器。

- **用法**: `./file_ops.sh <command> [args...]`
- **命令**:
  - `compress`: 压缩文件或文件夹 (调用 `compress_select.sh`)。
  - `merge_md`: 合并Markdown文件 (调用 `merge_markdown_files.sh`)。
  - `merge_csv`: 合并CSV文件 (调用 `merge_csv_files.sh`)。
  - `split_excel`: 按工作表拆分Excel文件 (调用 `splitsheets.py`)。

---

### Office 操作 (`office_ops.sh`)

这是一个Office文件处理工具的启动器。

- **用法**: `./office_ops.sh <command> [args...]`
- **命令**:
  - `extract_img`: 从Office文档中提取图片 (调用 `extract_images_office.py`)。
  - `extract_tbl`: 从Office文档中提取表格 (调用 `extract_tables_office.py`)。
  - `convert`: 批量转换Office文档格式 (调用 `convert_office_batch.sh`)。

---

### 文件组织 (`organize_files.sh`)

这是一个用于文件和目录维护的工具启动器。

- **用法**: `./organize_files.sh <command> [args...]`
- **命令**:
  - `list`: 列出文件内容，支持递归、隐藏文件和扩展名排除 (调用 `list_contents.sh`)。
  - `add-header`: 为多种类型的文件添加标准的注释头 (调用 `add_comment_header.sh`)。
  - `format-md`: 格式化Markdown文件，如替换标点和添加标题编号 (调用 `format_md.sh`)。
  - `move-by-prefix`: 根据文件名的数字前缀移动文件到对应编号的文件夹 (调用 `move_files_by_prefix.sh`)。
  - `flatten-destructive`: 将子目录文件移到上层并删除空的子目录 (调用 `flatten_directory_destructive.sh`)。
  - `flatten-keep`: 将子目录文件移到上层但保留子目录结构 (调用 `flatten_directory_keep_folders.sh`)。

---

### 格式转换脚本

这些脚本可以直接调用，用于单一类型的格式转换。所有转换脚本都支持 `-r` (递归) 和 `-h` (帮助) 选项。

- **Python**:
  - `convert_csv_to_txt.py`
  - `convert_csv_to_xlsx.py`
  - `convert_txt_to_csv.py`
  - `convert_txt_to_xlsx.py`
  - `convert_xlsx_to_csv.py`
  - `convert_xlsx_to_txt.py`
  - `convert_pptx_to_md.py`
  - `splitsheets.py` (拆分Excel)

- **Bash**:
  - `convert_doc_to_text.sh`
  - `convert_docx_to_md.sh`
  - `convert_docx_to_pdf.sh`

---

### 提取与分析脚本

- `extract_images_office.py`: 从 `.docx`, `.pptx`, `.xlsx` 文件中提取所有图片。
- `extract_tables_office.py`: 从 `.docx`, `.pptx`, `.xlsx` 文件中提取所有表格为CSV。
- `extract_text_tokens.py`: 分析文本文件，提取并统计词元。

---

### 其他工具

- `manage_pip_packages.sh`: 用于安装、更新、导出和检查Python包。
- `link_bind_files.py`: 将源目录的文件链接到一个中央目录，并可选择监控文件变化。
- `common_functions.sh`: Bash脚本的通用函数库。
- `common_utils.py`: Python脚本的通用工具库。

## 使用示例

### 示例 1: 压缩Finder中选中的文件

1. 在Finder中选中一些文件或文件夹。
2. 运行脚本:
   ```bash
   ./scripts_ray/file_ops.sh compress
   ```
   压缩后的ZIP文件将出现在当前文件夹。

### 示例 2: 递归将所有DOCX转为PDF

```bash
./scripts_ray/convert_docx_to_pdf.sh -r ./my_documents
```

### 示例 3: 提取PPTX中的所有图片和表格

```bash
# 提取图片
./scripts_ray/office_ops.sh extract_img my_presentation.pptx

# 提取表格
./scripts_ray/office_ops.sh extract_tbl my_presentation.pptx
```
提取的内容将保存在以演示文稿名命名的文件夹中。

### 示例 4: 批量转换所有Office文档

运行一个命令来处理当前目录（包括子目录）中的所有Word、Excel和PowerPoint文件。

```bash
./scripts_ray/office_ops.sh convert -a -r
```

### 示例 5: 为项目中所有脚本添加文件头

```bash
./scripts_ray/organize_files.sh add-header ./scripts_ray
```
