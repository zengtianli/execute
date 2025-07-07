#!/bin/bash

safe_cd() {
    local target_dir="$1"
    if cd "$target_dir" 2>/dev/null; then
        return 0
    else
        echo "❌ 无法进入目录: $target_dir" >&2
        return 1
    fi
}

ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            echo "❌ 无法创建目录: $dir" >&2
            return 1
        }
    fi
    return 0
}

get_extension() {
    local file="$1"
    echo "${file##*.}" | tr '[:upper:]' '[:lower:]'
}

get_basename() {
    local file="$1"
    basename "${file%.*}"
}

validate_path() {
    local path="$1"
    if [[ "$path" =~ \.\./|\\\||\; ]]; then
        echo "❌ 不安全的路径: $path" >&2
        return 1
    fi
    return 0
}

validate_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "❌ 文件不存在: $file" >&2
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo "❌ 文件不可读: $file" >&2
        return 1
    fi
    
    validate_path "$file"
}

check_file_size() {
    local file="$1"
    local max_size_mb=${2:-100}
    local size_mb=$(du -m "$file" 2>/dev/null | cut -f1)
    
    if [ -z "$size_mb" ]; then
        echo "❌ 无法获取文件大小: $file" >&2
        return 1
    fi
    
    if [ $size_mb -gt $max_size_mb ]; then
        echo "⚠️ 文件较大 (${size_mb}MB)" >&2
        return 1
    fi
    return 0
}

generate_unique_name() {
    local base_name="$1"
    local extension="$2"
    local output_dir="$3"
    
    if [ -z "$base_name" ]; then
        base_name="file_$(date +%Y%m%d_%H%M%S)"
    fi
    
    local file_path="$output_dir/${base_name}${extension}"
    local counter=1
    
    while [ -e "$file_path" ]; do
        file_path="$output_dir/${base_name}_${counter}${extension}"
        ((counter++))
    done
    
    echo "$file_path"
}

retry_command() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        echo "⚠️ 第 $attempt 次尝试失败，正在重试..." >&2
        ((attempt++))
        sleep 1
    done
    
    echo "❌ 命令执行失败，已重试 $max_attempts 次" >&2
    return 1
}

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd 未安装" >&2
        return 1
    fi
    return 0
}

create_temp_dir() {
    mktemp -d
}

cleanup_temp() {
    local temp_dir="$1"
    [ -d "$temp_dir" ] && rm -rf "$temp_dir"
} 