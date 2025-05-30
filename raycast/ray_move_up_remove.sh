#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title move_up_remove
# @raycast.mode silent
# @raycast.icon 🗂️
# @raycast.packageName Custom
# @raycast.description 将选中文件夹内容(包括子文件夹)移到上一级并删除空文件夹

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

# 递归处理文件夹函数
process_folder() {
    local FOLDER="$1"
    local PARENT_DIR="$2"
    local PREFIX="$3"
    local DEPTH="$4"
    local ALL_MOVED=true
    local SUB_SUCCESS=0
    
    # 获取文件夹名
    local FOLDER_NAME=$(basename "$FOLDER")
    
    echo "${PREFIX}📂 处理文件夹: $FOLDER_NAME (深度: $DEPTH)"
    
    # 先移除 .DS_Store 文件
    if [ -e "$FOLDER/.DS_Store" ]; then
        rm -f "$FOLDER/.DS_Store"
        echo "${PREFIX}  🧹 已删除 .DS_Store 文件"
    fi
    
    # 获取所有子文件夹，先递归处理它们
    find "$FOLDER" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' SUB_FOLDER_PATH; do
        # 递归处理子文件夹，深度加1
        process_folder "$SUB_FOLDER_PATH" "$PARENT_DIR" "${PREFIX}  " $((DEPTH+1))
        SUB_SUCCESS=$((SUB_SUCCESS+$?))
    done
    
    # 处理当前文件夹中的文件
    if [ -n "$(ls -A "$FOLDER" 2>/dev/null)" ]; then
        # 使用find命令安全地处理所有文件，包括名称中带空格的文件
        find "$FOLDER" -mindepth 1 -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' FILE_PATH; do
            # 获取文件名（不包含路径）
            local FILE=$(basename "$FILE_PATH")
            # 为了避免文件名冲突，添加文件夹名作为前缀（如果不在顶层）
            local TARGET_FILE="$FILE"
            if [ "$DEPTH" -gt 0 ]; then
                # 给文件名添加前缀，以防止名称冲突
                TARGET_FILE="${FOLDER_NAME}_$FILE"
            fi
            # 构建源和目标路径
            local SOURCE="$FOLDER/$FILE"
            local TARGET="$PARENT_DIR/$TARGET_FILE"
            
            # 检查目标路径是否已存在
            if [ -e "$TARGET" ]; then
                echo "${PREFIX}  ⚠️ 无法移动 $FILE: 目标路径已存在"
                ALL_MOVED=false
                continue
            fi
            
            # 移动文件
            mv "$SOURCE" "$TARGET"
            if [ $? -eq 0 ]; then
                echo "${PREFIX}  ✓ 已移动: $FILE -> $TARGET_FILE"
            else
                echo "${PREFIX}  ❌ 移动失败: $FILE"
                ALL_MOVED=false
            fi
        done
    fi
    
    # 检查文件夹是否为空
    if [ -z "$(ls -A "$FOLDER" 2>/dev/null)" ]; then
        # 先尝试 rmdir，如果失败再尝试 rm -rf
        rmdir "$FOLDER" 2>/dev/null || rm -rf "$FOLDER"
        
        if [ ! -d "$FOLDER" ]; then
            echo "${PREFIX}  🗑️ 已删除文件夹: $FOLDER_NAME"
            return 1 # 表示成功删除
        else
            echo "${PREFIX}  ❌ 删除文件夹失败: $FOLDER_NAME"
        fi
    else
        echo "${PREFIX}  ⚠️ 文件夹 $FOLDER_NAME 仍然不为空，无法删除"
    fi
    
    return 0 # 默认返回
}

# 处理每个选中的文件夹
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
    
    # 检查文件夹是否为空
    if [ -z "$(ls -A "$FOLDER")" ]; then
        echo "  ➡️ 文件夹已经为空，直接删除"
        rmdir "$FOLDER"
        ((SUCCESS_COUNT++))
        continue
    fi
    
    # 递归处理文件夹，从深度0开始
    process_folder "$FOLDER" "$PARENT_DIR" "" 0
    
    # 如果返回值为1，表示文件夹被成功处理和删除
    if [ $? -eq 1 ]; then
        ((SUCCESS_COUNT++))
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
