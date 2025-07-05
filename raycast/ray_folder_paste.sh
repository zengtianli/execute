#!/bin/bash
# Raycast Script
# @raycast.schemaVersion 1
# @raycast.title folder_paste
# @raycast.mode silent
# @raycast.icon 📋
# @raycast.packageName Custom

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 调用独立的粘贴脚本
exec "$PASTE_TO_FINDER_SCRIPT" 