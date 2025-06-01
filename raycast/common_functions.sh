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
    
    [[ "$(echo "$actual_ext" | tr '[:upper:]' '[:lower:]')" == "$(echo "$expected_ext" | tr '[:upper:]' '[:lower:]')" ]]
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
