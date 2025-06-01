#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Doc2Docx
# @raycast.mode silent
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description 将选中的Doc文件转换为Docx格式

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查原始脚本是否存在
ORIGINAL_SCRIPT="$SCRIPTS_DIR/doc2docx.sh"
if [ ! -f "$ORIGINAL_SCRIPT" ]; then
    show_error "找不到原始脚本: $ORIGINAL_SCRIPT"
    exit 1
fi

# 获取Finder中选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 分割逗号分隔的文件列表
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# 计数器
SUCCESS_COUNT=0
SKIPPED_COUNT=0

# 处理每个选中的文件
for FILE in "${FILE_ARRAY[@]}"; do
    # 获取文件名和目录
    FILENAME=$(basename "$FILE")
    DIR=$(dirname "$FILE")
    
    # 检查文件扩展名
    if ! check_file_extension "$FILE" "doc"; then
        show_warning "跳过: $FILENAME - 不是 DOC 文件"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 检查是否已经是docx文件
    if check_file_extension "$FILE" "docx"; then
        show_warning "跳过: $FILENAME - 已经是 DOCX 格式"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    show_processing "正在转换: $FILENAME"
    
    # 切换到文件所在目录
    if ! safe_cd "$DIR"; then
        show_error "无法进入目录: $DIR"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 调用原始脚本进行转换
    if "$ORIGINAL_SCRIPT" "$FILENAME"; then
        # 获取转换后的文件名
        DOCX_FILE="${FILENAME%.*}.docx"
        
        # 检查转换是否成功
        if [ -f "$DOCX_FILE" ]; then
            show_success "转换完成: $DOCX_FILE"
            ((SUCCESS_COUNT++))
        else
            show_error "转换失败: $FILENAME"
            ((SKIPPED_COUNT++))
        fi
    else
        show_error "转换过程中出错: $FILENAME"
        ((SKIPPED_COUNT++))
    fi
done

# 显示成功通知
if [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    show_success "成功转换了 1 个文件"
else
    show_success "成功转换了 $SUCCESS_COUNT 个文件"
fi

if [ $SKIPPED_COUNT -gt 0 ]; then
    show_warning "跳过了 $SKIPPED_COUNT 个文件"
fi
