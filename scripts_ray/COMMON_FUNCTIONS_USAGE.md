# 通用函数使用说明

该文档旨在说明 `common_functions.sh` 和 `common_utils.py` 中提供的通用函数，以便在开发新脚本时能够方便地复用。

## Bash 函数 (`common_functions.sh`)

这些函数提供了一致的消息输出、文件验证、命令检查等功能。

### 消息输出

- `show_success <message>`: 显示成功消息 (绿色)。
- `show_error <message>`: 显示错误消息 (红色)。
- `show_warning <message>`: 显示警告消息 (黄色)。
- `show_info <message>`: 显示参考信息 (蓝色)。
- `show_processing <message>`: 显示正在处理的消息。

### 帮助与版本

- `show_help_header <script_name> <description>`: 显示标准的帮助信息头部。
- `show_help_footer`: 显示标准的帮助信息尾部。
- `show_version_template`: 显示一个标准的版本信息模板。

### 文件与目录

- `validate_input_file <file_path>`: 验证输入文件是否存在且可读。
- `check_file_extension <file_path> <expected_ext>`: 检查文件扩展名。
- `get_file_basename <file_path>`: 获取不含扩展名的文件名。
- `get_file_extension <file_path>`: 获取文件扩展名。
- `ensure_directory <dir_path>`: 确保目录存在，如果不存在则创建。
- `generate_unique_filename <base> <ext> [dir]`: 在指定目录生成一个唯一的文件名。

### 命令与执行

- `check_command_exists <command>`: 检查指定的系统命令是否存在。
- `retry_command <command_with_args...>`: 尝试最多3次来执行一个命令。

### Finder 集成 (macOS)

- `get_finder_selection`: 获取在Finder中选中的文件列表。
- `get_finder_directory`: 获取Finder当前打开的目录。
- `validate_finder_directory <dir_path>`: 验证Finder目录的有效性。
- `reveal_file_in_finder <file_path>`: 在Finder中显示一个文件。

---

## Python 工具 (`common_utils.py`)

这些工具为Python脚本提供了一致的功能，包括消息显示、文件处理和进度跟踪。

### 消息输出

- `show_success(message)`
- `show_error(message)`
- `show_warning(message)`
- `show_info(message)`
- `show_processing(message)`
- `fatal_error(message)`: 显示错误消息并退出程序。

### 文件与目录

- `validate_input_file(path)`: 验证输入文件。
- `check_file_extension(path, ext)`: 检查文件扩展名。
- `get_file_basename(path)`: 获取不含扩展名的文件名。
- `ensure_directory(path)`: 确保目录存在。
- `find_files_by_extension(paths, exts, recursive)`: 根据扩展名查找文件。

### 依赖检查

- `check_python_packages(packages)`: 检查指定的Python包是否已安装。

### 进度跟踪

- `ProgressTracker(total)`: 一个简单的进度跟踪器。
  - `tracker.show(message)`: 显示当前进度和消息。

### 版本信息

- `show_version_info(script_name, version, author, updated)`: 显示标准的版本信息。 