#!/bin/bash

# 使用方法: ./mergecsv.sh [输出文件名] [保留标题:yes/no]
# 默认输出文件名: merged_output.csv
# 默认保留第一个文件的标题行: yes

output_file="${1:-merged_output.csv}"
keep_header="${2:-yes}"

echo "🔄 开始合并CSV文件..."
echo "📄 输出文件: $output_file"
echo "👆 保留标题: $keep_header"

# 检查当前目录是否有CSV文件
csv_count=$(ls *.csv 2>/dev/null | grep -v "$output_file" | wc -l)
if [ "$csv_count" -eq "0" ]; then
    echo "❌ 错误: 当前目录下没有找到CSV文件!"
    exit 1
fi

# 清空或创建输出文件
> "$output_file"

# 记录处理的文件
processed=0
skipped=0

# 添加处理信息作为注释
echo "# 合并的CSV文件" > "$output_file.info.txt"
echo "# 生成时间: $(date)" >> "$output_file.info.txt"
echo "# 包含文件:" >> "$output_file.info.txt"

# 处理第一个文件 - 保留标题
first_file=$(ls *.csv | grep -v "$output_file" | head -1)
if [ "$keep_header" = "yes" ]; then
    cat "$first_file" > "$output_file"
    echo "✅ 已添加(含标题): $first_file"
    echo "1. $first_file (含标题)" >> "$output_file.info.txt"
else
    tail -n +2 "$first_file" > "$output_file"
    echo "✅ 已添加(不含标题): $first_file"
    echo "1. $first_file (不含标题)" >> "$output_file.info.txt"
fi
((processed++))

# 合并其他文件 - 跳过标题行
i=2
for file in *.csv; do
    if [ "$file" != "$output_file" ] && [ "$file" != "$first_file" ] && [ -f "$file" ]; then
        # 跳过标题行(第一行)，只合并数据
        tail -n +2 "$file" >> "$output_file"
        echo "✅ 已添加(跳过标题): $file"
        echo "$i. $file (跳过标题)" >> "$output_file.info.txt"
        ((processed++))
        ((i++))
    fi
done

# 显示结果
echo ""
echo "✨ 完成合并 ✨"
echo "📊 处理了 $processed 个CSV文件"
if [ $skipped -gt 0 ]; then
    echo "⚠️ 跳过了 $skipped 个文件"
fi
echo "📁 输出保存至: $output_file"
echo "📝 文件列表保存至: $output_file.info.txt"

# 显示行数统计
total_lines=$(wc -l < "$output_file")
echo "📈 总行数: $total_lines 行"

# 显示列数
if [ -f "$output_file" ]; then
    header_line=$(head -1 "$output_file")
    column_count=$(echo "$header_line" | awk -F, '{print NF}')
    echo "🔢 总列数: $column_count 列"
fi

# 选项: 是否预览前几行
echo ""
echo "预览前5行内容:"
head -5 "$output_file"
echo "..."
