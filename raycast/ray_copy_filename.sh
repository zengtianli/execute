#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Copy filename
# @raycast.mode silent
# @raycast.icon 📋
# @raycast.packageName Custom
# @raycast.description Copy selected file's filename to clipboard

# 获取Finder中选中的所有文件
SELECTED_FILES=$(osascript <<'EOF'
set fileList to ""
tell application "Finder"
    set selectedItems to selection as list
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set currentFile to POSIX path of (item i of selectedItems as alias)
            set fileList to fileList & currentFile & "\n"
        end repeat
    end if
end tell
return fileList
EOF
)

if [ -z "$SELECTED_FILES" ]; then
    echo "❌ 在Finder中未选择文件"
    exit 1
fi

# 临时文件用于存储所有文件名
TEMP_FILE=$(mktemp)

# 计数器
FILE_COUNT=0

# 处理每个选中的文件 - 使用循环而非管道，避免子shell问题
while read -r FILE_PATH; do
    # 跳过空行
    if [ -z "$FILE_PATH" ]; then
        continue
    fi

    # 获取文件名（不含路径）
    FILENAME=$(basename "$FILE_PATH")
    
    # 将文件名添加到临时文件
    echo "$FILENAME" >> "$TEMP_FILE"
    
    FILE_COUNT=$((FILE_COUNT+1))
done <<< "$(echo -e "$SELECTED_FILES")"

# 将临时文件内容复制到粘贴板
cat "$TEMP_FILE" | pbcopy

# 删除临时文件
rm -f "$TEMP_FILE"

# 显示通知
if [ $FILE_COUNT -eq 1 ]; then
    echo "✅ 已复制 1 个文件的名称到粘贴板"
else
    echo "✅ 已复制 $FILE_COUNT 个文件的名称到粘贴板"
fi
