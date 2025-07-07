#!/bin/bash

# simple_paste.sh - 纯Shell命令的简单粘贴工具
# 版本: 1.0.0
# 作者: tianli

set -e

# 获取Finder当前目录（简化版）
get_current_dir() {
    osascript -e 'tell application "Finder" to POSIX path of (insertion location as alias)' 2>/dev/null || echo "$HOME/Desktop"
}

# 主函数
main() {
    local target_dir="${1:-$(get_current_dir)}"
    
    # 验证目录
    if [ ! -d "$target_dir" ]; then
        echo "❌ 目录不存在: $target_dir"
        exit 1
    fi
    
    # 检查剪贴板
    if ! pbpaste >/dev/null 2>&1; then
        echo "❌ 无法访问剪贴板"
        exit 1
    fi
    
    local clipboard_content=$(pbpaste)
    if [ -z "$clipboard_content" ]; then
        echo "⚠️ 剪贴板为空"
        exit 1
    fi
    
    echo "🔄 正在粘贴到 $(basename "$target_dir")..."
    
    # 检查是否是文件路径
    if echo "$clipboard_content" | head -1 | grep -q "^/"; then
        # 可能是文件路径，尝试复制
        while IFS= read -r line; do
            if [ -e "$line" ]; then
                cp -R "$line" "$target_dir/"
                echo "✅ 已复制: $(basename "$line")"
            fi
        done <<< "$clipboard_content"
    else
        # 文本内容，创建文件
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local text_file="$target_dir/pasted_text_$timestamp.txt"
        echo "$clipboard_content" > "$text_file"
        echo "✅ 已创建文本文件: $(basename "$text_file")"
    fi
}

main "$@" 