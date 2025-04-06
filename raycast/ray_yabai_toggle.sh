#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Toggle
# @raycast.mode silent
# @raycast.icon 🪟
# @raycast.packageName Custom
# @raycast.description Toggle Yabai window management service

# 执行 toggle-yabai.sh 脚本
/Users/tianli/useful_scripts/execute/yabai/toggle-yabai.sh

# 检查当前状态并显示反馈
if pgrep -x "yabai" > /dev/null; then
  echo "✅ Yabai 服务已启动"
else
  echo "❌ Yabai 服务已停止"
fi
