#!/bin/bash
# 获取当前目录下的所有文件
files=$(ls -p | grep -v /)
# 遍历所有文件
for file in $files
do
    # 获取文件的扩展名
    extension="${file##*.}"
    echo "文件名：$file"
    echo "内容:"
    cat "$file"  # 使用cat命令输出文件内容
    echo # 输出一个空行作为文件间的分隔
done
