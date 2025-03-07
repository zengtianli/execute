#!/bin/bash

# 如果没有传入文件名，输出帮助信息
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

FILE="$1"

osascript -e "tell application \"Ghostty\" to activate" \
          -e "delay 0.2" \
          -e "tell application \"System Events\" to keystroke \"nvim $FILE\"" \
          -e "tell application \"System Events\" to key code 36"

