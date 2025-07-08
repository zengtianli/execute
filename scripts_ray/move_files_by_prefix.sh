#!/bin/bash
# move_files_by_prefix.sh
#
# 功能:
# 根据文件名中的数字前缀，将文件移动到对应的编号目录中。
# 例如，对于名为 "01-introduction.md" 的文件，脚本会提取 "01"，
# 然后查找一个以 "01 " 开头的目录（例如 "01 Chapter 1"）并将文件移入。
#
# 用法:
# ./move_files_by_prefix.sh [目标目录]
#
# 从 manager_list.sh 中提取。

TARGET_DIR="."
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    TARGET_DIR="$1"
  else
    echo "错误: 目录 '$1' 未找到。" >&2
    exit 1
  fi
fi

# 使用 find 来稳健地处理文件，特别是那些文件名中包含空格的文件。
# 我们只处理目标目录顶层的文件。
find "$TARGET_DIR" -maxdepth 1 -type f | while IFS=read -r file_path; do
    file_name=$(basename "$file_path")

    # 提取数字前缀 (例如 "1-1", "1", "01", "1.1")。
    prefix=$(echo "$file_name" | grep -o '^[0-9]\+\(-[0-9]\+\|\.[0-9]\+\)\?' | head -n 1)

    if [ -z "$prefix" ]; then
        continue
    fi

    # 提取主数字 (例如从 "1-1" 或 "01" 中提取 "1") 并移除前导零。
    main_number=$(echo "$prefix" | grep -o '^[0-9]\+' | sed 's/^0*//')
    if [ -z "$main_number" ]; then main_number=0; fi

    # 将文件夹编号格式化为两位数 (例如 "01")。
    folder_number=$(printf "%02d" "$main_number")

    # 查找第一个匹配的目录 (例如 "01 Introduction")。
    # 目录名必须以两位数字和一个空格开头。
    target_dir_path=$(find "$TARGET_DIR" -maxdepth 1 -type d -name "${folder_number} *" -print -quit)

    if [ -n "$target_dir_path" ]; then
        echo "移动 '$file_name' -> '$target_dir_path'"
        mv "$file_path" "$target_dir_path/"
    fi
done

echo "文件按前缀移动完成。" 