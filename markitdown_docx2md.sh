#!/bin/bash
# 将所有docx文件转换为markdown
convert_all_docx_to_md() {
    local dir="${1:-.}"      # 默认为当前目录，或使用提供的参数
    local output_dir="$2"   # 输出目录，如果为空，则输出到原目录
    
    find "$dir" -type f -name "*.docx" | while read -r file; do
        local base_name=$(basename "${file%.docx}")
        
        if [ -n "$output_dir" ]; then
            # 如果指定了输出目录，则输出到该目录
            mkdir -p "$output_dir"
            local output_file="$output_dir/$base_name.md"
        else
            # 否则输出到原位置
            local output_file="${file%.docx}.md"
        fi
        
        echo "Converting $file to $output_file"
        markitdown "$file" > "$output_file"
    done
}

# 直接转换单个文件
if [ "$#" -ge 1 ] && [[ "$1" == *.docx ]]; then
    base_name=$(basename "${1%.docx}")  # 去掉 local
    
    # 检查是否提供了输出目录参数
    if [ -n "$2" ]; then
        # 如果指定了输出目录，则输出到该目录
        mkdir -p "$2"
        output_file="$2/$base_name.md"
        markitdown "$1" > "$output_file"
    elif [ -t 1 ]; then
        # 标准输出是终端，创建文件在原位置
        markitdown "$1" > "${1%.docx}.md"
    else
        # 标准输出已被重定向，直接输出
        markitdown "$1"
    fi
else
    # 执行转换函数
    convert_all_docx_to_md "$1" "$2"
fi
