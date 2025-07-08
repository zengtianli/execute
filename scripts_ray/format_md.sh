#!/bin/bash
# format_md.sh
#
# 功能:
# 格式化一个Markdown文件，主要执行两个操作:
# 1. 将标准标点符号替换为全角CJK等效符号。
# 2. 为标题添加层级编号 (例如, # -> # 1, ## -> ## 1.1)。
#
# 用法: ./format_md.sh [-i] <输入文件.md>
#   -i: 直接在原文件上修改，而不是创建一个新的格式化文件。

IN_PLACE=0
while getopts "i" opt; do
  case $opt in
    i) IN_PLACE=1 ;;
    \?) echo "无效选项: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    echo "用法: $(basename "$0") [-i] <文件名>"
    exit 1
fi

input_file="$1"
if [ ! -f "$input_file" ]; then
    echo "错误: 文件未找到: $input_file"
    exit 1
fi

# 此函数通过管道连接sed和awk来格式化文件内容。
format_content() {
    # 1. 将ASCII标点替换为全角版本。
    #    'sed G' 在每行后添加一个空行以增加间距，
    #    这在某些markdown渲染器中可以提高可读性。
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
        -e 's/"\([^"]*\)"/"\1"/g' "$1" | sed G | \
    # 2. 为H1, H2, H3标题添加层级编号。
    awk '
    BEGIN {
        h1=0; h2=0; h3=0;
    }
    /^# / {
        h1++; h2=0; h3=0;
        sub(/^# /, "# " h1 " ");
    }
    /^## / {
        h2++; h3=0;
        sub(/^## /, "## " h1 "." h2 " ");
    }
    /^### / {
        h3++;
        sub(/^### /, "### " h1 "." h2 "." h3 " ");
    }
    { print }'
}

if [ "$IN_PLACE" -eq 1 ]; then
    echo "正在原地格式化 $input_file ..."
    # 创建一个临时文件以安全地处理原地编辑
    tmp_file=$(mktemp)
    if [ -z "$tmp_file" ]; then
        echo "错误: 无法创建临时文件。" >&2
        exit 1
    fi
    format_content "$input_file" > "$tmp_file"
    mv "$tmp_file" "$input_file"
    echo "格式化完成。"
else
    output_file="${input_file%.*}_format.md"
    echo "正在格式化 $input_file -> $output_file..."
    format_content "$input_file" > "$output_file"
    echo "格式化完成。输出已保存到 $output_file"
fi



