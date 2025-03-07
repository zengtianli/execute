#!/bin/bash
# manager_list.sh

# 显示主菜单
show_main_menu() {
    echo "=== 文件列表管理器 ==="
    echo "1. 列出当前目录文件内容"
    echo "2. 列出子目录文件内容"
    echo "3. 列出包括隐藏文件的内容"
    echo "4. 列出 Markdown 文件内容"
    echo "5. 添加注释头"
    echo "6. 格式化 Markdown 文件"
    echo "7. 移动所有文件到根目录（删除文件夹）"
    echo "8. 根据文件名前缀移动文件"
    echo "9. 移动所有文件到根目录（保留文件夹）"
    echo "10. 帮助"
    echo "0. 退出"
    echo "请输入您的选择 (0-10): "
}
# 列出当前目录文件内容
list_current_dir() {
    echo "列出当前目录文件内容："
    files=$(ls -p | grep -v /)
    for file in $files
    do
        extension="${file##*.}"
        if [[ "$extension" == "txt" || "$extension" == "md" ]]; then
            continue
        fi
        echo "文件名：$file"
        echo "代码:"
        cat "$file"
        echo
    done
}
# 列出子目录文件内容
list_subdirs() {
    echo "列出子目录文件内容："
    files=$(find . -type f -not -path '*/\.*')
    for file in $files
    do
        extension="${file##*.}"
        if [[ "$extension" == "txt" || "$extension" == "md" ]]; then
            continue
        fi
        echo "文件名：$file"
        echo "代码:"
        cat "$file"
        echo
    done
}
# 列出包括隐藏文件的内容
list_hidden_files() {
    echo "列出包括隐藏文件的内容："
    files=$(ls -ap | grep -v /$ | grep -v '^\.$' | grep -v '^\.\.$')
    for file in $files
    do
        extension="${file##*.}"
        if [[ "$extension" == "txt" || "$extension" == "md" ]]; then
            continue
        fi
        echo "文件名：$file"
        echo "代码:"
        cat "$file"
        echo
    done
}
# 列出 Markdown 文件内容
list_markdown_files() {
    echo "列出 Markdown 文件内容："
    files=$(ls -p | grep -v /)
    for file in $files
    do
        extension="${file##*.}"
        if [[ "$extension" == "md" ]]; then
            echo "文件名：$file"
            echo "内容:"
            cat "$file"
            echo
        fi
    done
}
# 添加注释头
add_comment_header() {
    echo "添加注释头："
    extensions="py js lua sh zsh vue json yaml xml md"
    for ext in $extensions; do
        files=$(ls *.$ext 2> /dev/null)
        if [ -z "$files" ]; then
            echo "没有找到扩展名为 .$ext 的文件。"
            continue
        fi
        for file in $files; do
            case "$ext" in
                py|sh|zsh) comment="#" ;;
                js|vue) comment="//" ;;
                lua) comment="--" ;;
                json|yaml) echo "跳过 json 和 yaml，因为它们通常不支持注释。" ; continue ;;
                xml|md) comment="<!--" ;;
                *) echo "不支持的文件扩展名：$ext" ; continue ;;
            esac
            expected_comment_line="$comment $file"
            [ $ext = "xml" ] || [ $ext = "md" ] && expected_comment_line="$expected_comment_line -->"
            first_line=$(head -n 1 "$file")
            if [[ "$first_line" == "#!"* ]]; then
                echo "文件 $file 有一个 shebang 行。在其下方插入注释行。"
                sed -i '' "2i\\
$expected_comment_line
" "$file"
            else
                if [[ "$first_line" == $comment* ]]; then
                    if [[ "$first_line" != "$expected_comment_line" ]]; then
                        echo "更新 $file 的第一行注释。"
                        sed -i '' "1s|.*|$expected_comment_line|" "$file"
                    else
                        echo "$file 的第一行注释已匹配。跳过。"
                    fi
                else
                    echo "在 $file 的第一行插入注释行。"
                    sed -i '' "1i\\
$expected_comment_line
" "$file"
                fi
            fi
        done
    done
    echo "注释头添加完成。"
}

# 格式化 Markdown 文件
format_markdown() {
    echo "格式化 Markdown 文件："
    read -p "请输入要格式化的 Markdown 文件名：" input_file
    if [ ! -f "$input_file" ]; then
        echo "文件不存在。"
        return
    fi
    output_file="${input_file%.*}_format.md"
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
    rm temp_formatted.md
    echo "格式化完成。输出已保存到 $output_file"
}
# 移动所有文件到根目录
move_files_to_root() {
    echo "移动所有文件到根目录："
    
    # 检查是否在 git 仓库中，如果不是则初始化 git 仓库
    # if [ ! -d .git ]; then
    #     git init
    # fi

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
    echo "所有文件已被移动到根目录，空文件夹已被删除。"
}
# 根据文件名前缀数字移动文件到对应文件夹
move_files_by_prefix() {
    echo "根据文件名前缀数字移动文件到对应文件夹："
    
    # 遍历当前目录下的所有文件
    for file in *; do
        # 跳过目录
        if [ -d "$file" ]; then
            continue
        fi
        
        # 提取文件名前面的数字（支持格式如: "1-1", "1", "01", "1.1"等）
        prefix=$(echo "$file" | grep -o '^[0-9]\+\(-[0-9]\+\|\.[0-9]\+\)\?' | head -n 1)
        
        if [ -n "$prefix" ]; then
            # 提取主要数字（例如从"1-1"或"01"中提取"1"）
            main_number=$(echo "$prefix" | grep -o '^[0-9]\+' | sed 's/^0*//')
            
            # 构建目标文件夹名（补零到两位数）
            folder_number=$(printf "%02d" "$main_number")
            
            # 检查对应的文件夹是否存在
            for dir in *; do
                if [ -d "$dir" ] && [[ "$dir" =~ ^${folder_number}[[:space:]] ]]; then
                    echo "移动 '$file' 到文件夹 '$dir'"
                    mv "$file" "$dir/"
                    break
                fi
            done
        fi
    done
    
    echo "文件移动完成。"
}
# 移动所有文件到根目录但保留文件夹
move_files_keep_folders() {
    echo "移动所有文件到根目录（保留文件夹）："
    
    # 遍历当前目录下的所有文件夹
    for dir in */; do
        # 如果当前项是目录并且不是以 '.' 开头的隐藏目录
        if [ -d "$dir" ] && [[ "$dir" != .* ]]; then
            # 将目录中的所有文件复制到当前目录
            echo "从 $dir 移动文件..."
            # 使用 cp 命令先复制，确保成功后再删除原文件
            for file in "$dir"*; do
                if [ -f "$file" ]; then
                    cp "$file" ./ && rm "$file"
                    echo "已移动: $file"
                fi
            done
        fi
    done

    echo "所有文件已被移动到根目录，原始文件夹已保留。"
}
# 显示帮助信息
show_help() {
    echo "=== 帮助 ==="
    echo "这是一个文件列表管理器，可以帮助您查看不同类型的文件内容，添加注释头，格式化 Markdown 文件，以及移动文件。"
    echo "1. 列出当前目录文件内容：显示当前目录下的非文本文件内容。"
    echo "2. 列出子目录文件内容：显示当前目录及其子目录下的非文本文件内容。"
    echo "3. 列出包括隐藏文件的内容：显示当前目录下所有文件（包括隐藏文件）的内容。"
    echo "4. 列出 Markdown 文件内容：显示当前目录下所有 Markdown 文件的内容。"
    echo "5. 添加注释头：为指定类型的文件添加注释头。"
    echo "6. 格式化 Markdown 文件：格式化指定的 Markdown 文件，包括标点符号替换和标题编号。"
    echo "7. 移动所有文件到根目录（删除文件夹）：将所有子目录中的文件移动到当前目录，并删除空文件夹。"
    echo "8. 根据文件名前缀移动文件：根据文件名前缀数字将文件移动到对应编号的文件夹中。"
    echo "9. 移动所有文件到根目录（保留文件夹）：将所有子目录中的文件移动到当前目录，并保留原始文件夹。"
    echo "10. 帮助：显示此帮助信息。"
    echo "0. 退出：退出程序。"
}
# 主循环
while true; do
    show_main_menu
    read choice
    case $choice in
        1) list_current_dir ;;
        2) list_subdirs ;;
        3) list_hidden_files ;;
        4) list_markdown_files ;;
        5) add_comment_header ;;
        6) format_markdown ;;
        7) move_files_to_root ;;
        8) move_files_by_prefix ;;
        9) move_files_keep_folders ;;
        10) show_help ;;
        0) echo "感谢使用，再见！"; exit 0 ;;
        *) echo "无效选择，请重试。" ;;
    esac
    echo
done
