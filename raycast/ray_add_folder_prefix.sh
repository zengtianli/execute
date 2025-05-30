#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title add_folder_prefix
# @raycast.mode silent
# @raycast.icon 📝
# @raycast.packageName Custom
# @raycast.description 将文件夹名称作为前缀添加到文件名

# 获取Finder中选中的文件夹
SELECTED_FOLDERS=$(osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            if kind of thisItem is "文件夹" or kind of thisItem is "Folder" then
                set end of posixPaths to POSIX path of (thisItem as alias)
            end if
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    end if
end tell
EOF
)

if [ -z "$SELECTED_FOLDERS" ]; then
    echo "❌ 没有选中文件夹"
    exit 1
fi

# 分割逗号分隔的文件夹列表
IFS=',' read -ra FOLDER_ARRAY <<< "$SELECTED_FOLDERS"

# 计数器
SUCCESS_COUNT=0
SKIPPED_COUNT=0

# 处理每个文件夹
for FOLDER in "${FOLDER_ARRAY[@]}"; do
    # 移除末尾的斜杠（如果有）
    FOLDER=${FOLDER%/}
    
    # 检查是否为文件夹
    if [ ! -d "$FOLDER" ]; then
        echo "⚠️ 跳过 $(basename "$FOLDER") - 不是文件夹"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 获取文件夹名
    FOLDER_NAME=$(basename "$FOLDER")
    
    echo "📂 处理文件夹: $FOLDER_NAME"
    
    # 检查文件夹是否为空
    if [ -z "$(ls -A "$FOLDER")" ]; then
        echo "  ⚠️ 文件夹为空，跳过"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 重命名文件夹内的所有文件
    FILES_COUNT=0
    for FILE in "$FOLDER"/*; do
        # 如果不是常规文件，跳过
        if [ ! -f "$FILE" ]; then
            continue
        fi
        
        # 获取文件名和扩展名
        FILENAME=$(basename "$FILE")
        
        # 检查文件名是否已经包含前缀
        if [[ "$FILENAME" == "$FOLDER_NAME"* ]]; then
            echo "  ⚠️ 跳过 $FILENAME - 已有前缀"
            continue
        fi
        
        # 新文件名
        NEW_FILENAME="${FOLDER_NAME}_${FILENAME}"
        NEW_PATH="$FOLDER/$NEW_FILENAME"
        
        # 重命名文件
        mv "$FILE" "$NEW_PATH"
        if [ $? -eq 0 ]; then
            echo "  ✓ 已重命名: $FILENAME → $NEW_FILENAME"
            ((FILES_COUNT++))
        else
            echo "  ❌ 重命名失败: $FILENAME"
        fi
    done
    
    if [ $FILES_COUNT -gt 0 ]; then
        echo "  ✅ 共重命名了 $FILES_COUNT 个文件"
        ((SUCCESS_COUNT++))
    else
        echo "  ⚠️ 没有重命名任何文件"
        ((SKIPPED_COUNT++))
    fi
done

# 显示成功通知
if [ $SUCCESS_COUNT -eq 1 ]; then
    echo "✅ 成功处理了 $SUCCESS_COUNT 个文件夹"
else
    echo "✅ 成功处理了 $SUCCESS_COUNT 个文件夹"
fi

if [ $SKIPPED_COUNT -gt 0 ]; then
    echo "⚠️ 跳过了 $SKIPPED_COUNT 个文件夹或空文件夹"
fi
