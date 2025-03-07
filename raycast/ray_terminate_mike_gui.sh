#!/bin/bash

# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Terminate MIKE GUI Script
# @raycast.mode fullOutput
# @raycast.icon ⏹️
# @raycast.packageName Custom

# Documentation:
# @raycast.description Terminate the running MIKE GUI script if any

# The command to kill the MIKE GUI script process
pkill -f "/Users/tianli/miniforge3/bin/python3 /Users/tianli/bendownloads/ZDWP/浙水设计-Excel至MIKE智能数据转换软件/MIKE_easy_sections/mike_gui.py"
# output error message to the console

# echo "The MIKE GUI script process has been terminated"



