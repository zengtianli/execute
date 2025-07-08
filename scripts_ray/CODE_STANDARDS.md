# `scripts_ray` 代码规范 v2.1

## 核心原则
1.  **代码即文档**: 代码应简洁、自解释，不写非必要的注释。
2.  **DRY (Don't Repeat Yourself)**: 优先使用通用函数库中的函数。
3.  **一致性**: 遵循统一的结构、命名和参数处理方式。
4.  **简洁性**: 保持每个脚本专注于核心功能，行数控制在200行以内。

---

## 1. 标准脚本头部与依赖引入

所有脚本都必须包含标准头部和引入通用函数库。

### 1.1 Shell 脚本

```bash
#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# ... a show_help() function ...
# ... a main() function ...

main "$@"
```

### 1.2 Python 脚本

```python
#!/usr/bin/env python3
"""
脚本一句话描述
版本: 2.0.0
作者: tianli
"""

import sys
import argparse
from pathlib import Path

# 优先从 common_utils 引入函数
from common_utils import (
    show_success, show_error, show_warning, show_info,
    validate_input_file, fatal_error, find_files_by_extension
)

SCRIPT_VERSION = "2.0.0"

# ... functions ...

def main():
    parser = argparse.ArgumentParser(description="脚本功能描述")
    # ... arugment definitions ...
    args = parser.parse_args()
    # ... main logic ...

if __name__ == "__main__":
    main()
```

---

## 2. 关键规范

- **消息输出**: 必须使用 `show_*` 系列函数 (`show_success`, `show_error` 等) 进行所有面向用户的消息输出。
- **参数处理**:
    - **Shell**: 使用标准的 `while-case` 循环。
    - **Python**: 必须使用 `argparse` 模块。
    - 所有脚本都应支持 `-h`/`--help` 和 `--version`。
- **文件操作**: 必须使用通用库中的文件和路径验证函数，如 `validate_input_file`。
- **依赖检查**: 在执行核心逻辑前，使用 `check_command_exists` (Shell) 或 `check_python_packages` (Python) 检查依赖。
- **命名规范**: 文件名使用下划线分隔，并清晰反映其功能 (例如: `convert_docx_to_pdf.sh`)。 