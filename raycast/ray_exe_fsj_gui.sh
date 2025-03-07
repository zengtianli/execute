#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Execute fsj GUI Script
# @raycast.mode fullOutput
# @raycast.icon 🚀
# @raycast.packageName Custom
# Documentation:
# Path to Python 3 executable

PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
# Full path to your script
SCRIPT_LOCATION="/Users/tianli/bendownloads/ZDWP/浙水设计-分水江模型软件/gui.py"

export QT_PLUGIN_PATH="/Users/tianli/miniforge3/lib/python3.10/site-packages/PyQt6/Qt6/plugins"

# LOG_FILE in easy_sections.py file
# LOG_FILE="/Users/tianli/bendownloads/省院/02训练与开发/代码开发/fsj/log_file.log"
$PYTHON_PATH $SCRIPT_LOCATION 



