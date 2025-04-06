#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title txt2xls
# @raycast.mode silent
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description Convert txt files to xlsx in current Finder directory

# Get selected files in Finder
SELECTED_FILES=$(osascript <<'EOF'
set fileList to ""
tell application "Finder"
    set selectedItems to selection as list
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set currentItem to item i of selectedItems as alias
            set itemPath to POSIX path of currentItem
            set fileList to fileList & itemPath & "|"
        end repeat
    end if
end tell
return fileList
EOF
)

if [ -z "$SELECTED_FILES" ]; then
    echo "❌ 没有在Finder中选择文件"
    exit 1
fi

# 将所选文件拆分为数组
IFS='|' read -r -a FILES_ARRAY <<< "$SELECTED_FILES"

# 计数器初始化
SUCCESS_COUNT=0
TOTAL_COUNT=0

# 处理每个选中的文件
for FILE_PATH in "${FILES_ARRAY[@]}"
do
    # 跳过空条目（可能是因为分隔符在末尾）
    if [ -z "$FILE_PATH" ]; then
        continue
    fi

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    
    # 检查文件是否为txt文件
    if [[ "$FILE_PATH" != *.txt ]]; then
        echo "⚠️ 跳过非txt文件: $(basename "$FILE_PATH")"
        continue
    fi
    
    # 获取文件所在目录
    FILE_DIR=$(dirname "$FILE_PATH")
    
    # 运行Python脚本处理单个文件
    if /Users/tianli/miniforge3/bin/python3 /Users/tianli/useful_scripts/execute/xls_txt/txt2xls.py "$FILE_PATH"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
done

# 显示处理统计
if [ $TOTAL_COUNT -eq 0 ]; then
    echo "❌ 没有找到有效文件"
else
    if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
        echo "✅ 已成功转换所有 $SUCCESS_COUNT 个txt文件到xlsx格式"
    else
        echo "⚠️ 已转换 $SUCCESS_COUNT/$TOTAL_COUNT 个txt文件到xlsx格式"
    fi
fi
