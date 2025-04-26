#!/bin/bash
# 定义源文件路径
DEFAULT_VIMRC="/Users/tianli/obs_default/.obsidian.vimrc"
DEFAULT_OBSIDIAN_DIR="/Users/tianli/obs_default/.obsidian"

# 获取当前目录路径
CURRENT_DIR=$(pwd)

echo "正在将默认Obsidian配置加载到: $CURRENT_DIR"

# 检查源文件是否存在
if [ ! -f "$DEFAULT_VIMRC" ]; then
  echo "错误: 默认vimrc文件不存在: $DEFAULT_VIMRC"
  exit 1
fi

if [ ! -d "$DEFAULT_OBSIDIAN_DIR" ]; then
  echo "错误: 默认obsidian目录不存在: $DEFAULT_OBSIDIAN_DIR"
  exit 1
fi

# 复制vimrc文件
echo "复制 .obsidian.vimrc..."
cp "$DEFAULT_VIMRC" "$CURRENT_DIR/"

# 复制.obsidian目录
echo "复制 .obsidian 目录..."
if [ -d "$CURRENT_DIR/.obsidian" ]; then
  echo "警告: 目标.obsidian目录已存在，将被覆盖"
  rm -rf "$CURRENT_DIR/.obsidian"
fi
cp -r "$DEFAULT_OBSIDIAN_DIR" "$CURRENT_DIR/"

echo "完成! Obsidian默认配置已成功加载到当前目录。"
