#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title 切换 Yabai 服务
# @raycast.mode silent
# @raycast.icon 🪟
# @raycast.packageName Yabai
# @raycast.description 开启或关闭 Yabai 窗口管理服务

# 执行 toggle-yabai.sh 脚本
/Users/tianli/useful_scripts/execute/yabai/toggle-yabai.sh

# 检查当前状态并显示反馈
if pgrep -x "yabai" > /dev/null; then
  echo "✅ Yabai 服务已启动"
else
  echo "❌ Yabai 服务已停止"
fi
