# 贡献指南

感谢您对 Useful Scripts Collection 项目的关注！我们欢迎任何形式的贡献，包括但不限于：

- 🐛 Bug 报告
- 💡 功能建议
- 📝 文档改进
- 🔧 代码贡献
- 🧪 测试用例

## 🚀 快速开始

### 1. Fork 项目
点击项目页面右上角的 "Fork" 按钮，将项目 fork 到您的 GitHub 账户。

### 2. 克隆到本地
```bash
git clone https://github.com/YOUR_USERNAME/useful_scripts.git
cd useful_scripts
```

### 3. 创建开发分支
```bash
git checkout -b feature/your-feature-name
# 或
git checkout -b fix/your-fix-name
```

## 📋 开发环境设置

### 系统要求
- macOS 10.15 或更高版本
- Python 3.7+
- Git

### 安装依赖
```bash
# 安装 Python 依赖
pip install pandas openpyxl python-docx python-pptx tiktoken markitdown

# 安装系统工具
brew install pandoc
brew install --cask libreoffice

# 给脚本添加执行权限
find . -name "*.sh" -exec chmod +x {} \;
```

### 设置 Git hooks (可选)
```bash
# 设置提交前的代码检查
cp .githooks/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

## 🛠️ 开发规范

### 代码风格

#### Shell 脚本规范
请遵循项目中的 [Shell脚本代码规范文档.md](Shell脚本代码规范文档.md)，主要包括：

- 使用 `#!/bin/bash` 作为 shebang
- 函数名使用 snake_case
- 变量名使用大写字母和下划线
- 添加适当的注释和错误处理
- 使用 `common_functions.sh` 中的通用函数

```bash
#!/bin/bash
# 脚本功能描述

# 导入通用函数
source "$(dirname "$0")/common_functions.sh" 2>/dev/null || {
    echo "错误：无法加载 common_functions.sh"
    exit 1
}

# 主函数
main() {
    show_processing "开始处理..."
    # 你的代码
    show_success "处理完成"
}

main "$@"
```

#### Python 脚本规范
- 遵循 PEP 8 编码规范
- 使用 type hints (Python 3.5+)
- 添加适当的文档字符串
- 使用 `argparse` 处理命令行参数

```python
#!/usr/bin/env python3
"""
脚本功能描述
"""

import argparse
from pathlib import Path
from typing import List, Optional

def process_files(files: List[Path]) -> bool:
    """
    处理文件列表
    
    Args:
        files: 要处理的文件列表
        
    Returns:
        bool: 处理是否成功
    """
    # 你的代码
    pass

def main():
    parser = argparse.ArgumentParser(description="脚本描述")
    parser.add_argument("input", help="输入文件")
    args = parser.parse_args()
    
    # 你的代码

if __name__ == "__main__":
    main()
```

### 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Type 类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式化（不影响功能）
- `refactor`: 代码重构
- `test`: 添加或修改测试
- `chore`: 构建过程或辅助工具的变动

**示例：**
```
feat(convert): 添加批量PPTX转换功能

- 支持递归目录扫描
- 添加进度显示
- 优化内存使用

Closes #123
```

## 🧪 测试

### 运行测试
```bash
# 运行所有测试脚本
./run_tests.sh

# 测试特定功能
./test_convert.sh
./test_extract.sh
```

### 添加测试
在 `tests/` 目录下创建对应的测试文件：

```bash
tests/
├── test_convert_all.sh
├── test_pptx2md.py
└── sample_data/
    ├── test.docx
    ├── test.pptx
    └── test.xlsx
```

## 📝 文档贡献

### 文档类型
- **README.md**: 项目主要说明
- **脚本内注释**: 代码功能说明
- **用户文档**: 使用说明和示例
- **API 文档**: 函数和类的文档

### 文档要求
- 使用清晰的中文表达
- 提供实际的使用示例
- 包含必要的截图（如果适用）
- 保持与代码的同步更新

## 🐛 Bug 报告

### 报告模板
使用以下模板报告 Bug：

```markdown
**Bug 描述**
简要描述遇到的问题

**重现步骤**
1. 执行 '...'
2. 点击 '....'
3. 看到错误

**期望行为**
期望发生什么

**实际行为**
实际发生了什么

**环境信息**
- OS: macOS 版本
- Python: 版本号
- 相关软件版本

**附加信息**
- 错误日志
- 相关文件（如果适用）
- 屏幕截图
```

## 💡 功能建议

### 建议模板
```markdown
**功能描述**
简要描述建议的功能

**使用场景**
什么情况下会用到这个功能

**实现建议**
如何实现这个功能（可选）

**替代方案**
是否有其他实现方式
```

## 🔄 Pull Request 流程

### 1. 提交前检查
- [ ] 代码遵循项目规范
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] 所有测试通过
- [ ] 提交信息格式正确

### 2. 创建 Pull Request
- 提供清晰的 PR 标题和描述
- 链接相关的 Issue
- 添加适当的标签
- 请求相应的审查者

### 3. PR 模板
```markdown
## 变更内容
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 代码重构

## 描述
简要描述此 PR 的内容

## 测试
- [ ] 单元测试已通过
- [ ] 手动测试已完成
- [ ] 添加了新的测试用例

## 相关 Issue
Closes #(issue)

## 截图（如适用）

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 自测通过
- [ ] 文档已更新
```

## 🎯 贡献建议

### 优先级功能
1. **测试覆盖**: 为现有脚本添加测试用例
2. **错误处理**: 改进脚本的错误处理和用户提示
3. **性能优化**: 优化大文件处理性能
4. **跨平台支持**: 添加 Linux/Windows 支持
5. **UI 改进**: 添加图形化界面或 Web 界面

### 简单的开始
- 修复文档中的错别字
- 添加使用示例
- 改进错误消息
- 添加命令行帮助信息
- 优化脚本输出格式

## 📞 联系方式

如果您有任何问题或建议，可以通过以下方式联系：

- 创建 [Issue](../../issues)
- 发起 [Discussion](../../discussions)
- 发送邮件至：[your-email@example.com]

## 🙏 致谢

感谢所有为项目做出贡献的开发者和用户！

---

**再次感谢您的贡献！每一个贡献都让这个项目变得更好。** 🚀 