#!/bin/bash

# Raycast Script - 简化版粘贴工具
# @raycast.schemaVersion 1
# @raycast.title folder_paste_simple
# @raycast.mode fullOutput
# @raycast.icon 📋
# @raycast.packageName Custom

# 获取目标目录
TARGET_DIR=$(osascript -e 'tell application "Finder" to POSIX path of (insertion location as alias)' 2>/dev/null)

if [ -z "$TARGET_DIR" ]; then
    echo "❌ 无法获取Finder当前目录"
    exit 1
fi

# 检查剪贴板
CLIPBOARD_CONTENT=$(pbpaste 2>/dev/null)
if [ -z "$CLIPBOARD_CONTENT" ]; then
    echo "⚠️ 剪贴板为空"
    exit 1
fi

echo "🔄 正在粘贴到 $(basename "$TARGET_DIR")..."

# 简单的文本粘贴：创建文件
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEXT_FILE="$TARGET_DIR/pasted_$TIMESTAMP.txt"

echo "$CLIPBOARD_CONTENT" > "$TEXT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ 已创建文件: $(basename "$TEXT_FILE")"
    # 在Finder中选中新文件
    osascript -e "tell application \"Finder\" to reveal POSIX file \"$TEXT_FILE\"" 2>/dev/null
else
    echo "❌ 创建文件失败"
    exit 1
fi 