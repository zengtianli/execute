#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Compare Data
# @raycast.mode fullOutput
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description Compare two selected Excel files using compare_data.py script.

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)

# 检查是否选择了恰好两个文件
if [ -z "$SELECTED_FILES" ]; then
    show_error "请在Finder中选择恰好两个Excel文件"
    exit 1
fi

# 将选中的文件分割为数组
IFS=',' read -ra FILES_ARRAY <<< "$SELECTED_FILES"

# 检查文件数量
if [ ${#FILES_ARRAY[@]} -ne 2 ]; then
    show_error "请选择恰好两个Excel文件"
    exit 1
fi

# 运行Python脚本
"$PYTHON_PATH" "$SCRIPTS_DIR/execute/compare/compare_data.py" "${FILES_ARRAY[0]}" "${FILES_ARRAY[1]}"

# 显示成功通知
show_success "数据比较完成："
echo "1. $(basename "${FILES_ARRAY[0]}")"
echo "2. $(basename "${FILES_ARRAY[1]}")"
