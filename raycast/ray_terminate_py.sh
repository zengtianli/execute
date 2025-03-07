#!/bin/bash

# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Terminate All Python
# @raycast.mode fullOutput
# @raycast.icon ⏹️
# @raycast.packageName Custom

# Documentation:
# @raycast.description Terminate all running Python processes

# Kill all Python processes
pkill -f python

# 或者使用更严格的方式:
# pkill -9 -f python

# echo "All Python processes have been terminated"

