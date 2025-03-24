#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title 移动文件到上一级
# @raycast.mode silent
# @raycast.icon 📤
# @raycast.packageName Custom
# @raycast.description 将选定目录中的所有文件移动到上一级目录，然后删除该目录

# 获取选定的文件或目录
SELECTED_ITEM=$(osascript -e '
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    end if
end tell
')

# 检查是否选择了文件/目录
if [ -z "$SELECTED_ITEM" ]; then
  osascript -e 'display notification "请在Finder中选择一个目录" with title "错误" sound name "Basso"'
  exit 1
fi

# 检查选择的是否为目录
if [ ! -d "$SELECTED_ITEM" ]; then
  osascript -e 'display notification "请选择一个目录而不是文件" with title "错误" sound name "Basso"'
  exit 1
fi

# 获取目标目录的绝对路径
TARGET_DIR=$(realpath "$SELECTED_ITEM")

# 获取父目录
PARENT_DIR=$(dirname "$TARGET_DIR")

# 进入目标目录
cd "$TARGET_DIR" || { 
  osascript -e "display notification \"无法进入目录: $TARGET_DIR\" with title \"错误\" sound name \"Basso\""
  exit 1
}

# 显示将要移动的文件数量
FILE_COUNT=$(find . -maxdepth 1 -type f | wc -l)

# 移动所有文件到上一级目录
find . -maxdepth 1 -type f -exec mv {} "$PARENT_DIR" \;

# 检查是否还有其他目录或文件
REMAINING=$(find . -mindepth 1 | wc -l)
if [ $REMAINING -gt 0 ]; then
  ITEMS=$(find . -mindepth 1 | sed 's|^\./||' | tr '\n' ' ')
  CONFIRM=$(osascript -e "display dialog \"警告: 目录中还有 $REMAINING 个子目录或隐藏文件未移动:\n$ITEMS\n是否继续删除目录?\" buttons {\"取消\", \"继续\"} default button \"取消\" with icon caution")
  
  if [[ "$CONFIRM" != *"继续"* ]]; then
    osascript -e "display notification \"操作已取消\" with title \"移动文件到上一级\""
    exit 0
  fi
fi

# 返回上一级目录
cd "$PARENT_DIR" || {
  osascript -e "display notification \"无法进入目录: $PARENT_DIR\" with title \"错误\" sound name \"Basso\""
  exit 1
}

# 删除目标目录
if rmdir "$TARGET_DIR" 2>/dev/null; then
  osascript -e "display notification \"已成功将 $FILE_COUNT 个文件从 $(basename "$TARGET_DIR") 移动到上一级，并已删除目录\" with title \"完成\" sound name \"Glass\""
else
  osascript -e "display notification \"已移动文件，但无法删除目录: $TARGET_DIR, 可能不为空\" with title \"部分完成\" sound name \"Basso\""
  exit 1
fi
