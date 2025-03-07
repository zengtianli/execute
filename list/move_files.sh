#!/bin/bash
# 检查是否在 git 仓库中，如果不是则初始化 git 仓库
if [ ! -d .git ]; then
    git init
fi

# 添加所有文件并进行初次提交
# git add .
# git commit -m "Initial commit before moving files"

# 遍历当前目录下的所有文件夹
for dir in */; do
    # 如果当前项是目录并且不是以 '.' 开头的隐藏目录
    if [ -d "$dir" ] && [[ "$dir" != .* ]]; then
        # 将目录中的所有文件移动到当前目录
        mv "$dir"* .
        # 删除空的目录
        rmdir "$dir"
    fi
done

# 添加变更并提交
# git add .
# git commit -m "Moved files to root directory and removed empty folders"
echo "All files have been moved to the root directory and empty folders have been removed."


