#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Launch MIS
# @raycast.mode silent
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description 根据桌面上的essential_apps.txt列表启动必要的应用程序

# 调用launch_mis.sh脚本
SCRIPT_PATH="$HOME/useful_scripts/execute/launch_mis.sh"

# 检查脚本是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
  osascript -e 'display notification "脚本文件不存在: '"$SCRIPT_PATH"'" with title "错误" sound name "Basso"'
  exit 1
fi

# 执行脚本
OUTPUT=$("$SCRIPT_PATH" 2>&1)
EXIT_STATUS=$?

# 检查执行结果
if [ $EXIT_STATUS -eq 0 ]; then
  # 成功执行
  APP_COUNT=$(echo "$OUTPUT" | grep "启动:" | wc -l | tr -d ' ')
  if [ "$APP_COUNT" -gt 0 ]; then
    osascript -e 'display notification "已成功启动 '"$APP_COUNT"' 个应用程序" with title "完成" sound name "Glass"'
  else
    osascript -e 'display notification "所有必要应用程序已经在运行" with title "完成" sound name "Glass"'
  fi
else
  # 执行失败
  ERROR_MSG=$(echo "$OUTPUT" | grep "错误:" | head -1)
  if [ -z "$ERROR_MSG" ]; then
    ERROR_MSG="未知错误"
  fi
  osascript -e 'display notification "'"$ERROR_MSG"'" with title "错误" sound name "Basso"'
  exit 1
fi
