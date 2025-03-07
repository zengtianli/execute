#!/bin/bash
# 获取当前目录下的所有文件
files=$(find . -type f -not -path '*/\.*')
# 遍历所有文件
for file in $files
do
    # 获取文件的扩展名
    extension="${file##*.}"
    # 如果文件扩展名为 txt 或 md，则跳过
    if [[ "$extension" == "txt" || "$extension" == "md" ]]; then
        continue
    fi
    echo "文件名：$file"
    echo "代码:"
    cat "$file"  # 使用cat命令输出文件内容
    echo # 输出一个空行作为文件间的分隔
done
