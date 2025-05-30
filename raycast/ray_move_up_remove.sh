#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title move_up_remove
# @raycast.mode silent
# @raycast.icon 🗂️
# @raycast.packageName Custom
# @raycast.description 将选中文件夹内容移到上一级并删除空文件夹

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
    
    # 获取父目录
    PARENT_DIR=$(dirname "$FOLDER")
    FOLDER_NAME=$(basename "$FOLDER")
    
    echo "📂 处理文件夹: $FOLDER_NAME"
    
    # 检查文件夹是否为空
    if [ -z "$(ls -A "$FOLDER")" ]; then
        echo "  ➡️ 文件夹已经为空，直接删除"
        rmdir "$FOLDER"
        ((SUCCESS_COUNT++))
        continue
    fi
    
    # 先移除 .DS_Store 文件
    if [ -e "$FOLDER/.DS_Store" ]; then
        rm -f "$FOLDER/.DS_Store"
        echo "  🧹 已删除 .DS_Store 文件"
    fi
    
    # 移动所有内容到上一级目录 - 使用原始的循环方法
    FILES_LIST=$(ls -A "$FOLDER")
    ALL_MOVED=true
    
    # 如果仍有文件
    if [ ! -z "$FILES_LIST" ]; then
        for FILE in $FILES_LIST; do
            # 构建源和目标路径
            SOURCE="$FOLDER/$FILE"
            TARGET="$PARENT_DIR/$FILE"
            
            # 检查目标路径是否已存在
            if [ -e "$TARGET" ]; then
                echo "  ⚠️ 无法移动 $FILE: 目标路径已存在"
                ALL_MOVED=false
                continue
            fi
            
            # 移动文件/文件夹
            mv "$SOURCE" "$PARENT_DIR/"
            if [ $? -eq 0 ]; then
                echo "  ✓ 已移动: $FILE"
            else
                echo "  ❌ 移动失败: $FILE"
                ALL_MOVED=false
            fi
        done
    fi
    
    # 再次检查文件夹是否为空
    if [ -z "$(ls -A "$FOLDER")" ]; then
        # 先尝试 rmdir，如果失败再尝试 rm -rf
        rmdir "$FOLDER" 2>/dev/null || rm -rf "$FOLDER"
        
        if [ ! -d "$FOLDER" ]; then
            echo "  🗑️ 已删除文件夹: $FOLDER_NAME"
            ((SUCCESS_COUNT++))
        else
            echo "  ❌ 删除文件夹失败: $FOLDER_NAME"
        fi
    else
        echo "  ⚠️ 文件夹 $FOLDER_NAME 仍然不为空，无法删除"
    fi
done

# 显示成功通知
if [ $SUCCESS_COUNT -eq 1 ]; then
    echo "✅ 成功处理了 $SUCCESS_COUNT 个文件夹"
else
    echo "✅ 成功处理了 $SUCCESS_COUNT 个文件夹"
fi

if [ $SKIPPED_COUNT -gt 0 ]; then
    echo "⚠️ 跳过了 $SKIPPED_COUNT 个项目"
fi
