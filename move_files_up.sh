#!/bin/bash

# 这个脚本将指定目录的所有文件移动到上一级目录，然后删除该目录

# 检查是否提供了目录参数
if [ $# -eq 0 ]; then
  echo "用法: $0 <目录路径>"
  exit 1
fi

# 获取目标目录的绝对路径
TARGET_DIR=$(realpath "$1")

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
  echo "错误: '$TARGET_DIR' 不是一个有效的目录"
  exit 1
fi

# 获取父目录
PARENT_DIR=$(dirname "$TARGET_DIR")

# 进入目标目录
cd "$TARGET_DIR" || { echo "无法进入目录: $TARGET_DIR"; exit 1; }

# 显示将要移动的文件数量
FILE_COUNT=$(find . -maxdepth 1 -type f | wc -l)
echo "将 $FILE_COUNT 个文件从 '$TARGET_DIR' 移动到 '$PARENT_DIR'"

# 移动所有文件到上一级目录
find . -maxdepth 1 -type f -exec mv {} "$PARENT_DIR" \;

# 检查是否还有其他目录或文件
REMAINING=$(find . -mindepth 1 | wc -l)
if [ $REMAINING -gt 0 ]; then
  echo "警告: 目录中还有 $REMAINING 个子目录或隐藏文件未移动"
  echo "查看剩余内容:"
  find . -mindepth 1 -ls
  echo "是否继续删除目录? [y/N]"
  read -r CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
  fi
fi

# 返回上一级目录
cd "$PARENT_DIR" || { echo "无法进入目录: $PARENT_DIR"; exit 1; }

# 删除目标目录
rmdir "$TARGET_DIR" 2>/dev/null || { echo "无法删除目录: $TARGET_DIR, 可能不为空"; exit 1; }

echo "完成! 目录 '$TARGET_DIR' 已删除，其中的文件已移动到 '$PARENT_DIR'"
