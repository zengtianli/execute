#!/bin/bash
# list_contents.sh
#
# 功能:
# 将多个文件列表脚本合并为一个。此脚本可列出文件内容，
# 并提供递归搜索、包含隐藏文件以及排除特定文件扩展名的选项。
#
# 替代以下脚本:
# - list_files_with_content.sh
# - list_files_with_content_ig.sh
# - list_files_with_content_subdir.sh
# - list_md.sh

show_help() {
    echo "用法: $(basename "$0") [-r] [-a] [-e <ext1,ext2...>] [目标目录]"
    echo "  -r, --recursive    递归搜索目录。"
    echo "  -a, --all          包含隐藏文件和目录。"
    echo "  -e, --exclude-exts 要排除的文件扩展名列表（以逗号分隔）。"
    echo "  -h, --help         显示此帮助信息。"
    echo
    echo "示例:"
    echo "  # 列出当前目录中非文本文件 (替代 list_files_with_content.sh)"
    echo "  $(basename "$0") -e txt,md"
    echo
    echo "  # 列出所有文件（包括隐藏文件），忽略txt/md (替代 list_files_with_content_ig.sh)"
    echo "  $(basename "$0") -a -e txt,md"
    echo
    echo "  # 递归列出非文本文件 (替代 list_files_with_content_subdir.sh)"
    echo "  $(basename "$0") -r -e txt,md"
    echo
    echo "  # 列出当前目录中的所有文件 (替代 list_md.sh 的功能)"
    echo "  $(basename "$0")"
}

RECURSIVE=0
ALL_FILES=0
EXCLUDE_EXTS=""
TARGET_DIR="."

# 基础长选项处理
for arg in "$@"; do
  shift
  case "$arg" in
    "--recursive") set -- "$@" "-r" ;;
    "--all")       set -- "$@" "-a" ;;
    "--exclude-exts") set -- "$@" "-e" ;;
    "--help")      set -- "$@" "-h" ;;
    *)             set -- "$@" "$arg" ;;
  esac
done

while getopts "rae:h" opt; do
  case $opt in
    r) RECURSIVE=1 ;;
    a) ALL_FILES=1 ;;
    e) EXCLUDE_EXTS="$OPTARG" ;;
    h) show_help; exit 0 ;;
    \?) show_help; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    TARGET_DIR="$1"
  else
    echo "错误: 目录 '$1' 未找到。" >&2
    exit 1
  fi
fi

find_args=("$TARGET_DIR")

if [ "$RECURSIVE" -eq 0 ]; then
  find_args+=("-maxdepth" "1")
fi

find_args+=("-type" "f")

# 除非指定了 -a，否则排除隐藏文件
if [ "$ALL_FILES" -eq 0 ]; then
  find_args+=("-not" "-path" "*/\.*" "-and" "-not" "-name" ".*")
fi

# 使用 print0 和 read -d 对于包含特殊字符的文件名是健壮的
find "${find_args[@]}" -print0 | while IFS= read -r -d $'\0' file; do
  # 如果扩展名在排除列表中，则跳过
  if [ -n "$EXCLUDE_EXTS" ]; then
    extension="${file##*.}"
    if [[ ",$EXCLUDE_EXTS," == *",$extension,"* ]]; then
      continue
    fi
  fi

  echo "文件名: ${file#./}"
  echo "代码:"
  cat "$file"
  echo
done 