#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Execute MIKE GUI Script
# @raycast.mode silent
# @raycast.icon 🌊
# @raycast.packageName Custom
# Documentation:
# @raycast.description Run the MIKE GUI script located in the directory
# Path to Python 3 executable
PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
# Full path to your script
SCRIPT_LOCATION="/Users/tianli/bendownloads/ZDWP/浙水设计-Excel至MIKE智能数据转换软件/MIKE_easy_sections/mike_gui.py"
export QT_PLUGIN_PATH="/Users/tianli/miniforge3/lib/python3.10/site-packages/PyQt6/Qt6/plugins"
# LOG_FILE in easy_sections.py file
LOG_FILE="/Users/tianli/Downloads/MIKE_easy_sections/log_file.log"
# Run the Python script and capture its output
$PYTHON_PATH $SCRIPT_LOCATION 
