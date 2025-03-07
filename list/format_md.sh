#!/bin/bash
# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# 输入文件名
input_file="$1"
# 生成输出文件名,添加 "_format" 后缀
output_file="${input_file%.*}_format.md"

# 替换标点符号并处理引号
sed -e 's/:/：/g' \
    -e 's/,/，/g' \
    -e 's/!/！/g' \
    -e 's/?/？/g' \
    -e 's/;/；/g' \
    -e 's/(/（/g' \
    -e 's/)/）/g' \
    -e 's/\[/【/g' \
    -e 's/\]/】/g' \
    -e 's/</《/g' \
    -e 's/>/》/g' \
    -e 's/"\([^"]*\)"/"\1"/g' "$input_file" | sed G > temp_formatted.md

# 使用 awk 添加 h1, h2, h3 的编号
awk '
BEGIN {
    h1 = 0
    h2 = 0
    h3 = 0
}
{
    if ($0 ~ /^# /) {
        h1++
        h2=0
        h3=0
        sub(/^# /, "# " h1 " ", $0)
    } else if ($0 ~ /^## /) {
        h2++
        h3=0
        sub(/^## /, "## " h1 "." h2 " ", $0)
    } else if ($0 ~ /^### /) {
        h3++
        sub(/^### /, "### " h1 "." h2 "." h3 " ", $0)
    }
    print
}' temp_formatted.md > "$output_file"

# 删除临时文件
rm temp_formatted.md

echo "Formatting complete. Output saved to $output_file"



