#!/bin/bash
# flatten_directory_destructive.sh
#
# 功能:
# 将所有文件从直接子目录移动到目标目录，然后删除已变为空的子目录。
# 这是一个破坏性操作，因为它会移除原有的目录结构。
# 默认情况下，脚本会忽略隐藏目录。
#
# 用法: ./flatten_directory_destructive.sh [-a] [目标目录]
#   -a: 处理隐藏目录
#
# 此脚本是旧'move_files.sh'的重构版本。

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

echo "正在平铺目录 '$TARGET_DIR' (破坏性操作)..."

# 构建find命令查找目录
find_args=("$TARGET_DIR" -maxdepth 1 -mindepth 1 -type d)
if [ "$INCLUDE_ALL" -eq 0 ]; then
  find_args+=(-not -name ".*")
fi

# 查找目标目录下的所有直接子目录
find "${find_args[@]}" | while IFS=read -r dir_path; do
    echo "正在处理目录: '$dir_path'"
    # 将此子目录中的所有文件移动到目标目录
    # 使用find命令可以稳健地处理所有文件，包括隐藏文件
    find "$dir_path" -maxdepth 1 -type f -exec mv -t "$TARGET_DIR" {} +

    # 尝试删除目录。rmdir只能成功删除空目录
    if ! rmdir "$dir_path" 2>/dev/null; then
        echo "警告: 目录 '$dir_path' 非空，未被删除。"
    fi
done

echo "目录平铺操作完成。" 