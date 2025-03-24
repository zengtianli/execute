#!/bin/bash

# 输出文件
OUTPUT_FILE=~/Desktop/running_apps.txt

# 添加标题
echo "== 正在运行的应用程序 ==" > $OUTPUT_FILE
echo "--------------------------------" >> $OUTPUT_FILE

# 使用pgrep查找应用程序，过滤并保留应用程序名称，然后排序去重
pgrep -fla "." | grep -i "/Applications\|/System/Applications" | grep -v "Helper\|plugin-container\|framework" | sed 's/.*\/\([^\/]*\)\.app.*/\1.app/g' | sort | uniq >> $OUTPUT_FILE

echo "应用程序列表已保存到 $OUTPUT_FILE"

