#!/bin/bash

# ===== 常量定义 =====
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly MINIFORGE_BIN="/Users/tianli/miniforge3/bin"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"
readonly EXECUTE_DIR="/Users/tianli/useful_scripts/execute"

# ===== 颜色定义 =====
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

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
    echo -e "${GREEN}✅ $1${NC}"
}

# 显示错误消息
# 参数: $1 = 消息内容
show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 显示警告消息
# 参数: $1 = 消息内容
show_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# 显示处理中消息
# 参数: $1 = 消息内容
show_processing() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# 显示信息消息
# 参数: $1 = 消息内容
show_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
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

# 验证文件路径安全性
# 参数: $1 = 文件路径
# 返回: 0 = 安全, 1 = 不安全
validate_file_path() {
    local path="$1"
    # 检查路径是否包含恶意字符
    if [[ "$path" =~ \.\./|\||\; ]]; then
        show_error "不安全的文件路径: $path"
        return 1
    fi
    return 0
}

# 检查文件大小
# 参数: $1 = 文件路径, $2 = 最大大小(MB,可选,默认100)
# 返回: 0 = 文件大小正常, 1 = 文件过大
check_file_size() {
    local file="$1"
    local max_size_mb=${2:-100}
    local size_mb=$(du -m "$file" 2>/dev/null | cut -f1)
    
    if [ -z "$size_mb" ]; then
        show_error "无法获取文件大小: $file"
        return 1
    fi
    
    if [ $size_mb -gt $max_size_mb ]; then
        show_warning "文件较大 (${size_mb}MB)，处理可能需要较长时间"
        return 1
    fi
    return 0
}

# 带重试机制的命令执行
# 参数: $@ = 要执行的命令
# 返回: 命令执行结果
retry_command() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        show_warning "第 $attempt 次尝试失败，正在重试..."
        ((attempt++))
        sleep 1
    done
    
    show_error "命令执行失败，已重试 $max_attempts 次"
    return 1
}

# 运行AppleScript
# 参数: $1 = AppleScript代码
run_applescript() {
    local script="$1"
    osascript <<EOF
$script
EOF
}

# 验证输入文件
# 参数: $1 = 文件路径
# 返回: 0 = 文件有效, 1 = 文件无效
validate_input_file() {
    local file="$1"
    
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        show_error "文件不存在: $file"
        return 1
    fi
    
    # 检查文件是否可读
    if [ ! -r "$file" ]; then
        show_error "文件不可读: $file"
        return 1
    fi
    
    # 验证路径安全性
    validate_file_path "$file" || return 1
    
    return 0
}

# 显示进度
# 参数: $1 = 当前数量, $2 = 总数量, $3 = 项目名称(可选)
show_progress() {
    local current="$1"
    local total="$2"
    local item="${3:-项目}"
    show_processing "处理中 ($current/$total): $item"
}

# 显示百分比进度
# 参数: $1 = 当前数量, $2 = 总数量
show_percentage() {
    local current="$1"
    local total="$2"
    local percentage=$((current * 100 / total))
    echo -e "${BLUE}📊 进度: $percentage% ($current/$total)${NC}"
}

# 致命错误 - 立即退出
# 参数: $1 = 错误消息
fatal_error() {
    show_error "$1"
    exit 1
}

# 可恢复错误 - 记录但继续
# 参数: $1 = 错误消息
recoverable_error() {
    show_warning "$1"
    return 1
}

# 创建临时目录
# 返回: 临时目录路径
create_temp_dir() {
    local temp_dir=$(mktemp -d)
    echo "$temp_dir"
}

# 清理临时文件
# 参数: $1 = 临时目录路径
cleanup_temp_dir() {
    local temp_dir="$1"
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}

# 获取文件基本名称（不含扩展名）
# 参数: $1 = 文件路径
# 返回: 文件基本名称
get_file_basename() {
    local file="$1"
    basename "${file%.*}"
}

# 获取文件扩展名
# 参数: $1 = 文件路径
# 返回: 文件扩展名（小写）
get_file_extension() {
    local file="$1"
    echo "${file##*.}" | tr '[:upper:]' '[:lower:]'
}

# 确保目录存在
# 参数: $1 = 目录路径
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            show_error "无法创建目录: $dir"
            return 1
        }
    fi
    return 0
}

# 检查Python环境
check_python_env() {
    if [ ! -f "$PYTHON_PATH" ]; then
        show_error "Python 未找到: $PYTHON_PATH"
        return 1
    fi
    return 0
}

# 检查必需的Python包
# 参数: $@ = 包名列表
check_python_packages() {
    local missing_packages=()
    
    for package in "$@"; do
        if ! "$PYTHON_PATH" -c "import $package" 2>/dev/null; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        show_error "缺少Python包: ${missing_packages[*]}"
        show_info "请运行: pip install ${missing_packages[*]}"
        return 1
    fi
    return 0
} 