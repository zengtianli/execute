#!/bin/bash

# 转换当前目录下所有 WMF 文件
for file in *.wmf; do
    if [ -f "$file" ]; then
        echo "正在转换: $file"
        /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to png "$file"
    fi
done

echo "转换完成！"

