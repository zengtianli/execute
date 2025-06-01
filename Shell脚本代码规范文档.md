# Shell 脚本代码规范文档

## 目标
统一所有 Raycast 脚本的代码风格和实现方式，提高代码的可维护性、可读性和一致性。

## 核心原则
1. **DRY (Don't Repeat Yourself)**: 相同功能使用统一的实现
2. **一致性**: 相同场景使用相同的代码模式
3. **健壮性**: 所有操作都需要错误处理
4. **可读性**: 代码结构清晰，注释完整

## 1. 必须引入的通用函数库

在每个脚本开头，必须引入以下通用函数库：

```bash
#!/bin/bash

# 引入通用函数库
source "/Users/tianli/useful_scripts/raycast/common_functions.sh"
```

### 通用函数库内容 (common_functions.sh)

```bash
#!/bin/bash

# ===== 常量定义 =====
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly MINIFORGE_BIN="/Users/tianli/miniforge3/bin"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"

# ===== 通用函数 =====

# 获取 Finder 中选中的单个文件/文件夹
# 返回: 文件路径或空字符串
get_finder_selection_single() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    else
        ""
    end if
end tell
EOF
}

# 获取 Finder 中选中的多个文件/文件夹
# 返回: 逗号分隔的路径列表
get_finder_selection_multiple() {
    osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            set end of posixPaths to POSIX path of (thisItem as alias)
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    else
        return ""
    end if
end tell
EOF
}

# 获取当前 Finder 目录或选中项目的目录
get_finder_current_dir() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        set firstItem to item 1 of (selection as list)
        if class of firstItem is folder then
            POSIX path of (firstItem as alias)
        else
            POSIX path of (container of firstItem as alias)
        end if
    else
        POSIX path of (insertion location as alias)
    end if
end tell
EOF
}

# 检查文件扩展名
# 参数: $1 = 文件路径, $2 = 期望的扩展名（不带点）
# 返回: 0 = 匹配, 1 = 不匹配
check_file_extension() {
    local file="$1"
    local expected_ext="$2"
    local actual_ext="${file##*.}"
    
    [[ "${actual_ext,,}" == "${expected_ext,,}" ]]
}

# 在 Ghostty 中执行命令
# 参数: $1 = 要执行的命令
run_in_ghostty() {
    local command="$1"
    local command_escaped=$(printf "%s" "$command" | sed 's/"/\\"/g')
    
    osascript <<EOF
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "n" using command down
    end tell
end tell
EOF
    
    sleep 1
    
    osascript <<EOF
tell application "Ghostty"
    activate
    delay 0.2
    set the clipboard to "$command_escaped"
    tell application "System Events"
        keystroke "v" using command down
        delay 0.1
        key code 36
    end tell
end tell
EOF
}

# 显示成功消息
# 参数: $1 = 消息内容
show_success() {
    echo "✅ $1"
}

# 显示错误消息
# 参数: $1 = 消息内容
show_error() {
    echo "❌ $1"
}

# 显示警告消息
# 参数: $1 = 消息内容
show_warning() {
    echo "⚠️ $1"
}

# 显示处理中消息
# 参数: $1 = 消息内容
show_processing() {
    echo "🔄 $1"
}

# 安全切换目录
# 参数: $1 = 目标目录
# 返回: 0 = 成功, 1 = 失败
safe_cd() {
    local target_dir="$1"
    if cd "$target_dir" 2>/dev/null; then
        return 0
    else
        show_error "无法进入目录: $target_dir"
        return 1
    fi
}

# 检查命令是否存在
# 参数: $1 = 命令名称
check_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        show_error "$cmd 未安装"
        return 1
    fi
    return 0
}
```

## 2. 代码规范细则

### 2.1 Raycast 参数头部

所有脚本必须包含完整的 Raycast 参数头部：

```bash
#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title 脚本标题
# @raycast.mode silent/compact/fullOutput
# @raycast.icon 图标
# @raycast.packageName 包名
# @raycast.description 脚本描述
# @raycast.argument1 { "type": "text", "placeholder": "参数说明", "optional": false }  # 如果需要参数
```

### 2.2 获取 Finder 选择的标准方式

**单个文件/文件夹：**
```bash
SELECTED_ITEM=$(get_finder_selection_single)
if [ -z "$SELECTED_ITEM" ]; then
    show_error "没有在 Finder 中选择任何文件或文件夹"
    exit 1
fi
```

**多个文件/文件夹：**
```bash
SELECTED_ITEMS=$(get_finder_selection_multiple)
if [ -z "$SELECTED_ITEMS" ]; then
    show_error "没有在 Finder 中选择任何文件或文件夹"
    exit 1
fi

# 转换为数组
IFS=',' read -ra ITEMS_ARRAY <<< "$SELECTED_ITEMS"
```

### 2.3 文件类型检查

```bash
# 使用通用函数检查
if ! check_file_extension "$FILE_PATH" "pdf"; then
    show_warning "跳过: $(basename "$FILE_PATH") - 不是 PDF 文件"
    continue
fi
```

### 2.4 执行 Python 脚本

```bash
# 始终使用常量
"$PYTHON_PATH" "$SCRIPTS_DIR/execute/script.py" "$PARAM1" "$PARAM2"
```

### 2.5 错误处理模式

```bash
# 命令执行检查
if ! command_here; then
    show_error "命令执行失败"
    exit 1
fi

# 目录切换
safe_cd "$TARGET_DIR" || exit 1

# 文件操作
if [ ! -f "$FILE_PATH" ]; then
    show_error "文件不存在: $FILE_PATH"
    exit 1
fi
```

### 2.6 输出消息格式

```bash
# 统一使用 show_* 函数
show_success "操作完成"
show_error "操作失败"
show_warning "注意事项"
show_processing "正在处理..."

# 计数显示
if [ $COUNT -eq 1 ]; then
    show_success "处理了 1 个文件"
else
    show_success "处理了 $COUNT 个文件"
fi
```

### 2.7 在终端中打开的标准方式

```bash
# 获取目录
CURRENT_DIR=$(get_finder_current_dir)

# 在 Ghostty 中打开
run_in_ghostty "cd \"$CURRENT_DIR\""
show_success "Ghostty 已在 $(basename "$CURRENT_DIR") 中打开"
```

## 3. 修改示例

### 修改前：
```bash
#!/bin/bash
SELECTED_FILE=$(osascript -e 'tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    end if
end tell')

if [ -z "$SELECTED_FILE" ]; then
    echo "No file selected"
    exit 1
fi

if [[ "$SELECTED_FILE" != *".pdf" ]]; then
    echo "Not a PDF file"
    exit 1
fi

cd "$(dirname "$SELECTED_FILE")"
/Users/tianli/miniforge3/bin/python3 convert.py "$SELECTED_FILE"
echo "Done"
```

### 修改后：
```bash
#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Convert PDF
# @raycast.mode silent
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description 转换选中的 PDF 文件

# 引入通用函数库
source "/Users/tianli/useful_scripts/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 检查文件类型
if ! check_file_extension "$SELECTED_FILE" "pdf"; then
    show_error "选中的不是 PDF 文件"
    exit 1
fi

# 切换到文件目录
FILE_DIR=$(dirname "$SELECTED_FILE")
safe_cd "$FILE_DIR" || exit 1

# 执行转换
show_processing "正在转换 $(basename "$SELECTED_FILE")..."
if "$PYTHON_PATH" "$SCRIPTS_DIR/execute/convert.py" "$SELECTED_FILE"; then
    show_success "转换完成"
else
    show_error "转换失败"
    exit 1
fi
```

## 4. 特殊情况处理

### 4.1 PyQt 应用

```bash
# 设置 Qt 环境变量
export QT_PLUGIN_PATH="$MINIFORGE_BIN/../lib/python3.10/site-packages/PyQt6/Qt6/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="$QT_PLUGIN_PATH/platforms"
```

### 4.2 需要 PATH 环境变量的命令

```bash
# 添加必要的路径
export PATH="$MINIFORGE_BIN:$PATH:/usr/local/bin:/opt/homebrew/bin"
```

## 5. 执行修改的步骤

1. **创建通用函数库文件** `/Users/tianli/useful_scripts/execute/raycast/common_functions.sh`
2. **逐个修改脚本**：
   - 添加 `source` 语句引入函数库
   - 替换所有 Finder 选择相关代码
   - 替换所有输出消息为 `show_*` 函数
   - 替换所有 Python 路径为 `$PYTHON_PATH`
   - 添加适当的错误处理
   - 确保 Raycast 头部参数完整
3. **测试每个修改后的脚本**确保功能正常

## 6. 检查清单

修改每个脚本时，确保：
- [ ] 引入了通用函数库
- [ ] 使用统一的 Finder 选择函数
- [ ] 使用统一的消息输出函数
- [ ] 使用常量代替硬编码路径
- [ ] 有适当的错误处理
- [ ] Raycast 参数头部完整
- [ ] 代码风格一致（缩进、空格等）
- [ ] 注释清晰明了


