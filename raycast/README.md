# Raycast 脚本工具集

这是一个功能齐全的Raycast脚本工具集，旨在提高macOS用户的工作效率。通过Raycast快速启动和执行各种常用操作。

## 📋 目录结构

```
raycast/
├── common_functions.sh         # 公共函数库
├── trf/                       # 文件格式转换工具
├── yabai/                     # Yabai窗口管理工具
└── [各种功能脚本]
```

## 🚀 功能概览

### 📱 应用程序启动
- **Cursor** (`ray_ap_cursor.sh`): 在当前Finder目录打开Cursor编辑器
- **Ghostty** (`ray_ap_ghossty.sh`): 在当前Finder目录打开Ghostty终端
- **Nvim in Ghostty** (`ray_ap_nvimGh.sh`): 在Ghostty中用Nvim打开选中文件
- **Default Terminal** (`ray_ap_terminal.sh`): 在当前目录打开默认终端
- **Windsurf** (`ray_ap_winsurf.sh`): 在当前目录打开Windsurf编辑器

### 📁 文件管理
- **Copy Filename** (`ray_copy_filename.sh`): 复制选中文件的文件名到剪贴板
- **Copy Name and Content** (`ray_copy_filename_content.sh`): 复制文件名和内容到剪贴板
- **Create Folder** (`ray_create_folder.sh`): 在选中位置创建新文件夹
- **Move Up Remove** (`ray_move_up_remove.sh`): 将文件夹内容移到上级并删除空文件夹
- **Add Folder Prefix** (`ray_add_folder_prefix.sh`): 为文件夹内文件添加文件夹名前缀

### 🔧 实用工具
- **Run File** (`ray_ap_runfile.sh`): 运行选中的shell或python脚本
- **Run Files in Parallel** (`ray_ap_runfile_1.sh`): 并行运行多个脚本文件
- **Compare Data** (`ray_comp_data.sh`): 比较两个Excel文件数据
- **Split Excel Sheets** (`ray_splitsheets.sh`): 将Excel文件拆分为单独的工作表
- **FZF Goto Folder** (`ray_fgf.sh`): 使用FZF快速跳转到文件夹
- **Launch MIS** (`ray_launch_mis.sh`): 启动必要的应用程序
- **Terminate All Python** (`ray_terminate_py.sh`): 终止所有Python进程

## 📖 详细功能说明

### 🖥️ 应用程序启动工具

#### **Cursor & Windsurf**
```bash
# 功能: 在当前Finder目录打开代码编辑器
# 使用: 在Finder中选择目录，然后运行脚本
# 输出: 在选中目录中启动编辑器
```

#### **Ghostty Terminal**
```bash
# 功能: 在当前目录打开Ghostty终端
# 使用: 在任何Finder位置运行
# 特点: 自动切换到当前Finder目录
```

#### **Nvim in Ghostty**
```bash
# 功能: 在Ghostty中用Nvim打开选中文件
# 使用: 选择文件后运行脚本
# 特点: 自动在文件所在目录启动Nvim
```

### 📂 文件操作工具

#### **文件内容复制**
- **copy_filename**: 仅复制文件名
- **copy_filename_content**: 复制文件名+完整内容
- 支持多文件批量操作
- 自动格式化输出

#### **文件夹管理**
```bash
# Create Folder
# - 在选中位置创建新文件夹
# - 自动处理重名冲突
# - 支持在文件或文件夹上操作

# Move Up Remove
# - 递归移动文件夹内容到上级
# - 自动添加前缀防止冲突
# - 删除处理后的空文件夹

# Add Folder Prefix
# - 批量为文件添加文件夹名前缀
# - 防止重复添加前缀
# - 支持多文件夹同时处理
```

### ⚙️ 脚本执行工具

#### **Run File (单文件)**
```bash
# 支持格式: .sh, .py
# 功能:
# - 自动添加执行权限
# - 在脚本目录中运行
# - 显示详细输出和错误信息
# - 成功/失败状态反馈
```

#### **Run Files in Parallel (多文件)**
```bash
# 支持格式: .sh, .py
# 功能:
# - 并行执行多个脚本
# - 独立的日志记录
# - PyQt6环境自动配置
# - 详细的执行结果报告
```

### 📊 数据处理工具

#### **Excel数据比较**
```bash
# 功能: 比较两个Excel文件的差异
# 使用: 选择恰好两个Excel文件
# 输出: 详细的差异分析报告
```

#### **Excel工作表拆分**
```bash
# 功能: 将Excel文件拆分为单独的工作表文件
# 支持: .xlsx, .xls格式
# 输出: 每个工作表保存为独立文件
```

### 🔍 导航工具

#### **FZF文件夹跳转**
```bash
# 功能: 使用FZF快速查找并跳转到文件夹
# 特点:
# - 模糊搜索
# - 实时预览
# - 排除隐藏文件夹和系统目录
# - 直接在Finder中打开选中目录
```

## 🛠️ 安装和配置

### 系统要求
- **macOS**: 10.14+
- **Raycast**: 最新版本
- **依赖工具**:
  - Python 3 (通过miniforge3)
  - FZF (用于文件夹跳转)
  - Ghostty 终端
  - 相关代码编辑器

### 安装步骤

1. **安装依赖**
```bash
# 安装Homebrew (如果尚未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装FZF
brew install fzf

# 安装miniforge3 (Python环境)
brew install miniforge
```

2. **配置路径**
确保 `common_functions.sh` 中的路径正确：
```bash
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly MINIFORGE_BIN="/Users/tianli/miniforge3/bin"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"
```

3. **设置权限**
```bash
chmod +x raycast/*.sh
chmod +x raycast/trf/*.sh
chmod +x raycast/yabai/*.sh
```

4. **Raycast配置**
- 将脚本目录添加到Raycast扩展目录
- 在Raycast中刷新扩展列表
- 为常用脚本设置快捷键

## 📚 common_functions.sh 公共函数库

提供统一的基础功能：

### 🎯 核心函数
```bash
# Finder操作
get_finder_selection_single()      # 获取单个选中项
get_finder_selection_multiple()    # 获取多个选中项
get_finder_current_dir()          # 获取当前Finder目录

# 消息显示
show_success()    # ✅ 成功消息
show_error()      # ❌ 错误消息  
show_warning()    # ⚠️ 警告消息
show_processing() # 🔄 处理中消息

# 工具函数
check_file_extension()      # 检查文件扩展名
safe_cd()                  # 安全切换目录
check_command_exists()     # 检查命令是否存在
run_in_ghostty()          # 在Ghostty中执行命令
```

### 📦 预定义常量
```bash
PYTHON_PATH     # Python解释器路径
MINIFORGE_BIN   # miniforge3二进制目录
SCRIPTS_DIR     # 脚本根目录
```

## 💡 使用技巧

### 高效工作流程
1. **开发环境**: 使用 `Cursor/Windsurf` 快速打开项目
2. **终端操作**: 使用 `Ghostty` 在项目目录启动终端
3. **文件编辑**: 使用 `Nvim in Ghostty` 快速编辑文件
4. **脚本执行**: 使用 `Run File` 或 `Run Files in Parallel` 执行脚本
5. **文件管理**: 使用各种文件操作工具整理项目结构

### 快捷键建议
```
⌘ + ⌥ + C    # Cursor
⌘ + ⌥ + T    # Ghostty Terminal  
⌘ + ⌥ + V    # Nvim in Ghostty
⌘ + ⌥ + R    # Run File
⌘ + ⌥ + F    # FZF Goto Folder
```

## 🐛 故障排除

### 常见问题

**❌ 脚本权限错误**
```bash
chmod +x raycast/*.sh
```

**❌ Python路径错误**
```bash
# 检查Python路径
which python3
# 更新common_functions.sh中的PYTHON_PATH
```

**❌ Finder选择失败**
```bash
# 确保在Finder中选择了文件/文件夹
# 检查Raycast有访问Finder的权限
```

**❌ 应用程序启动失败**
```bash
# 确保目标应用程序已安装
# 检查应用程序名称是否正确
```

### 调试方法
```bash
# 直接运行脚本查看错误
bash -x script_name.sh

# 检查日志输出
tail -f /tmp/raycast_debug.log
```

## 📈 更新日志

- **v2.0**: 添加了统一的公共函数库
- **v1.8**: 新增并行脚本执行功能
- **v1.5**: 添加了Yabai窗口管理工具
- **v1.3**: 新增文件格式转换工具集
- **v1.0**: 初始版本，包含基础文件操作和应用启动功能

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个工具集！

## 📄 许可证

MIT License - 详见LICENSE文件 