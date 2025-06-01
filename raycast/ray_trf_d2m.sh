#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title d2m
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description 将选中的Docx文件或文件夹转换为Markdown

# 设置环境变量，确保能找到markitdown命令
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin"

# 获取脚本的绝对路径
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

# 检查原始转换脚本是否存在
CONVERT_SCRIPT="$SCRIPT_DIR/execute/markitdown_docx2md.sh"
if [ ! -f "$CONVERT_SCRIPT" ]; then
    echo "❌ 找不到原始脚本: $CONVERT_SCRIPT"
    exit 1
fi

# 获取Finder中选中的文件或文件夹
SELECTED_ITEMS=$(osascript <<'EOF'
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
    end if
end tell
EOF
)

if [ -z "$SELECTED_ITEMS" ]; then
    echo "❌ 没有选中文件或文件夹"
    exit 1
fi

# 分割逗号分隔的列表
IFS=',' read -ra ITEM_ARRAY <<< "$SELECTED_ITEMS"

# 计数器
SUCCESS_COUNT=0
FILE_COUNT=0
DIR_COUNT=0

# 处理每个选中的项目
for SELECTED_ITEM in "${ITEM_ARRAY[@]}"; do
    # 检查是文件还是目录
    if [ -d "$SELECTED_ITEM" ]; then
        echo "📂 处理文件夹: $(basename "$SELECTED_ITEM")"
        ((DIR_COUNT++))
        
        # 调用原始脚本处理文件夹
        bash "$CONVERT_SCRIPT" "$SELECTED_ITEM"
        
        # 计算转换文件数
        CONVERTED_FILES=$(find "$SELECTED_ITEM" -type f -name "*.md" -newer "$SELECTED_ITEM")
        CONVERTED_COUNT=$(echo "$CONVERTED_FILES" | grep -c "^")
        SUCCESS_COUNT=$((SUCCESS_COUNT + CONVERTED_COUNT))
        
    elif [ -f "$SELECTED_ITEM" ]; then
        ((FILE_COUNT++))
        
        # 检查是否为docx文件
        if [[ "$SELECTED_ITEM" != *".docx" ]]; then
            echo "⚠️ 跳过: $(basename "$SELECTED_ITEM") - 不是docx文件"
            continue
        fi
        
        # 获取文件目录
        FILE_DIR=$(dirname "$SELECTED_ITEM")
        # 切换到文件目录
        cd "$FILE_DIR"
        
        # 运行转换
        output_file="${SELECTED_ITEM%.docx}.md"
        echo "🔄 正在转换: $(basename "$SELECTED_ITEM") -> $(basename "$output_file")"
        markitdown "$SELECTED_ITEM" > "$output_file"
        
        # 检查转换是否成功
        if [ -f "$output_file" ]; then
            echo "✅ 转换完成: $(basename "$output_file")"
            ((SUCCESS_COUNT++))
        else
            echo "❌ 转换失败: $(basename "$SELECTED_ITEM")"
        fi
    fi
done

# 显示成功通知
if [ $FILE_COUNT -gt 0 ] && [ $DIR_COUNT -gt 0 ]; then
    echo "✅ 成功转换了 $SUCCESS_COUNT 个文件 (来自 $FILE_COUNT 个文件和 $DIR_COUNT 个文件夹)"
elif [ $DIR_COUNT -gt 0 ]; then
    echo "✅ 成功转换了 $SUCCESS_COUNT 个文件 (来自 $DIR_COUNT 个文件夹)"
elif [ $SUCCESS_COUNT -eq 0 ]; then
    echo "⚠️ 没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    echo "✅ 成功转换了 1 个文件"
else
    echo "✅ 成功转换了 $SUCCESS_COUNT 个文件"
fi

