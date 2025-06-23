#!/bin/bash
# 创建 alias_folder
mkdir -p alias_folder
# 清理现有的符号链接
find alias_folder -type l -delete
# 创建图片链接
echo "创建图片链接..."
for img_folder in *_img; do
    if [ -d "$img_folder" ]; then
        for file in "$img_folder"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                # 添加文件夹前缀避免冲突
                # prefix=${img_folder%_img}
                ln -s "$(pwd)/$file" "alias_folder/${filename}"
            fi
        done
    fi
done
# 创建表格链接
echo "创建表格链接..."
for table_folder in *_tables; do
    if [ -d "$table_folder" ]; then
        for file in "$table_folder"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                # 添加文件夹前缀避免冲突
                # prefix=${table_folder%_tables}
                ln -s "$(pwd)/$file" "alias_folder/${filename}"
            fi
        done
    fi
done
echo "完成！"
ls -la alias_folder | wc -l
