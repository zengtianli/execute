#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title split markdown
# @raycast.mode fullOutput
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description split markdown
# @raycast.argument1 { "type": "text", "placeholder": "each file lines", "optional": false }

# 获取命令行参数
LINES_PER_FILE=$1

# 检查参数是否为数字
if ! [[ "$LINES_PER_FILE" =~ ^[0-9]+$ ]]; then
    echo "❌ 请输入有效的数字作为每个文件的行数"
    exit 1
fi

# 获取在Finder中选中的文件
SELECTED_FILE=$(osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    if (count of selectedItems) = 1 then
        set currentItem to item 1 of selectedItems
        set currentPath to POSIX path of (currentItem as alias)
        return currentPath
    else
        return ""
    end if
end tell
EOF
)

# 检查是否有且只有一个文件被选中
if [ -z "$SELECTED_FILE" ]; then
    echo "❌ 请在Finder中选择一个Markdown文件"
    exit 1
fi

# 检查选中的文件是否为Markdown文件
if [[ ! "$SELECTED_FILE" =~ \.(md|markdown)$ ]]; then
    echo "❌ 请选择一个Markdown文件 (.md 或 .markdown)"
    exit 1
fi

# 获取文件名和目录
FILE_NAME=$(basename "$SELECTED_FILE")
FILE_DIR=$(dirname "$SELECTED_FILE")
FILE_BASE="${FILE_NAME%.*}"
FILE_EXT="${FILE_NAME##*.}"

# 创建临时文件夹存放分割后的文件
TEMP_DIR="${FILE_DIR}/${FILE_BASE}_split"
mkdir -p "$TEMP_DIR"

# 分割文件
echo "🔄 正在分割文件: $FILE_NAME..."

# 统计文件总行数
TOTAL_LINES=$(wc -l < "$SELECTED_FILE")
TOTAL_FILES=$(( (TOTAL_LINES + LINES_PER_FILE - 1) / LINES_PER_FILE ))

# 创建一个循环来手动分割文件并使用数字命名
CURRENT_LINE=1
for ((i=1; i<=TOTAL_FILES; i++)); do
    # 计算当前文件应读取的行数
    LINES_TO_READ=$LINES_PER_FILE
    REMAINING_LINES=$((TOTAL_LINES - CURRENT_LINE + 1))
    if [ $REMAINING_LINES -lt $LINES_PER_FILE ]; then
        LINES_TO_READ=$REMAINING_LINES
    fi
    
    # 生成带有序号的文件名（使用前导零确保排序正确）
    PADDED_NUM=$(printf "%03d" $i)
    OUTPUT_FILE="${TEMP_DIR}/${FILE_BASE}_${PADDED_NUM}.${FILE_EXT}"
    
    # 提取指定范围的行并写入到新文件
    sed -n "${CURRENT_LINE},$((CURRENT_LINE + LINES_TO_READ - 1))p" "$SELECTED_FILE" > "$OUTPUT_FILE"
    
    # 更新当前行号
    CURRENT_LINE=$((CURRENT_LINE + LINES_TO_READ))
done

echo "✅ 分割完成！"
echo "📊 总行数: $TOTAL_LINES"
echo "📊 每个文件行数: $LINES_PER_FILE"
echo "📊 共分割为: $TOTAL_FILES 个文件"
echo "📂 文件保存在: $TEMP_DIR"
echo ""
echo "分割后的文件列表:"
ls -1 "$TEMP_DIR"
