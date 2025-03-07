#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title mdprev
# @raycast.mode fullOutput
# @raycast.icon 📖
# @raycast.packageName Custom
# @raycast.description Preview markdown in current directory
# @raycast.argument1 { "type": "text", "placeholder": "filename", "optional": false }
# 在ray_mdprev.sh中添加pnpm路径到PATH环境变量
export PATH="/Users/tianli/Library/pnpm:$PATH"
CURRENT_DIR=$(osascript -e 'tell application "Finder" to get POSIX path of (insertion location as alias)')
MD_FILE="${CURRENT_DIR}/$1.md"
cd "/Users/tianli/bendownloads/mds_preview"
WORK_FILE="/Users/tianli/bendownloads/mds_preview/main.py"

/Users/tianli/miniforge3/bin/python3 "$WORK_FILE" "$MD_FILE"
echo "✅ Markdown preview started in $(basename \"$CURRENT_DIR\")"
