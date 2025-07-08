#!/bin/bash
# flatten_directory_keep_folders.sh
#
# 功能:
# 将所有文件从直接子目录移动到目标目录，但保留（现在可能为空的）子目录。
# 此脚本不会递归处理更深层的目录。
# 默认情况下，脚本会忽略隐藏目录。
#
# 用法: ./flatten_directory_keep_folders.sh [-a] [目标目录]
#   -a: 处理隐藏目录
#
# 从 manager_list.sh 的 'move_files_keep_folders' 功能中提取。

INCLUDE_ALL=0
while getopts "a" opt; do
  case $opt in
    a) INCLUDE_ALL=1 ;;
    \?) echo "无效选项: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

TARGET_DIR="."
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    TARGET_DIR="$1"
  else
    echo "错误: 目录 '$1' 未找到。" >&2
    exit 1
  fi
fi

echo "正在将文件移动到 '$TARGET_DIR' (保留空文件夹)..."

# 构建find命令查找目录
find_args=("$TARGET_DIR" -maxdepth 1 -mindepth 1 -type d)
if [ "$INCLUDE_ALL" -eq 0 ]; then
  find_args+=(-not -name ".*")
fi

# 查找目标目录下的所有直接子目录
find "${find_args[@]}" | while IFS=read -r dir_path; do
    echo "正在处理文件夹: '$dir_path'"
    # 查找此子目录中的所有文件并将其移动到目标目录。
    # 'mv' 的 '-t' 选项用于指定目标目录。
    find "$dir_path" -maxdepth 1 -type f -exec mv -t "$TARGET_DIR" {} +
done

echo "文件移动完成。" 