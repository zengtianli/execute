#!/bin/bash

# extract_md_files.sh - 提取所有 md 文件到 mded 文件夹

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 目标文件夹
TARGET_DIR="mded"

# 创建目标文件夹
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo -e "${GREEN}✓ 创建目录: $TARGET_DIR${NC}"
else
    echo -e "${YELLOW}! 目录已存在: $TARGET_DIR${NC}"
fi

# 统计变量
total_count=0
success_count=0
skip_count=0

echo -e "\n${GREEN}开始查找和复制 .md 文件...${NC}\n"

# 查找所有 .md 文件并复制
while read -r file; do
    # 获取文件名（不含路径）
    filename=$(basename "$file")
    
    # 获取相对路径（去掉开头的 ./）
    relative_path="${file#./}"
    
    # 目标文件路径
    target_file="$TARGET_DIR/$filename"
    
    ((total_count++))
    
    # 检查目标文件是否已存在
    if [ -f "$target_file" ]; then
        # 如果文件名重复，添加目录名作为前缀
        dir_name=$(dirname "$relative_path" | tr '/' '_')
        if [ "$dir_name" != "." ]; then
            new_filename="${dir_name}_${filename}"
            target_file="$TARGET_DIR/$new_filename"
        else
            # 如果还是重复，添加数字后缀
            counter=1
            base_name="${filename%.md}"
            while [ -f "$TARGET_DIR/${base_name}_${counter}.md" ]; do
                ((counter++))
            done
            target_file="$TARGET_DIR/${base_name}_${counter}.md"
        fi
    fi
    
    # 复制文件
    if cp "$file" "$target_file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} 复制: $relative_path -> ${target_file#$TARGET_DIR/}"
        ((success_count++))
    else
        echo -e "${RED}✗${NC} 失败: $relative_path"
        ((skip_count++))
    fi
done < <(find . -type f -name "*.md" -not -path "./$TARGET_DIR/*")

# 显示统计信息
echo -e "\n${GREEN}========== 完成 ==========${NC}"
echo -e "总计找到: ${total_count} 个 .md 文件"
echo -e "成功复制: ${GREEN}${success_count}${NC} 个文件"
if [ $skip_count -gt 0 ]; then
    echo -e "复制失败: ${RED}${skip_count}${NC} 个文件"
fi
echo -e "文件位置: ${TARGET_DIR}/"

# 显示目标文件夹内容
echo -e "\n${GREEN}目标文件夹内容:${NC}"
ls -la "$TARGET_DIR"/*.md 2>/dev/null | head -20
file_count=$(ls -1 "$TARGET_DIR"/*.md 2>/dev/null | wc -l)
if [ $file_count -gt 20 ]; then
    echo "... 还有 $((file_count - 20)) 个文件"
fi
