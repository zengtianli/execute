# add_comment_header.sh
# 扩展名列表
extensions="py js lua sh zsh vue json yaml xml md"
for ext in $extensions; do
    # 在当前目录查找指定扩展名的文件
    files=$(ls *.$ext 2> /dev/null)
    if [ -z "$files" ]; then
        echo "No files found with .$ext extension."
        continue
    fi
    for file in $files; do
        # 根据文件扩展名确定注释符号
        case "$ext" in
            py|sh|zsh) comment="#" ;;
            js|vue) comment="//" ;;
            lua) comment="--" ;;
            json|yaml) echo "Skipping json and yaml, as they typically do not support comments." ; continue ;;
            xml|md) comment="<!--" ;;
            *) echo "Unsupported file extension: $ext" ; exit 1 ;;
        esac
        # 准备期望的注释行
        expected_comment_line="$comment $file"
        [ $ext = "xml" ] || [ $ext = "md" ] && expected_comment_line="$expected_comment_line -->"
        # 读取文件的第一行
        first_line=$(head -n 1 "$file")
        # 检查第一行是否为shebang行
        if [[ "$first_line" == "#!"* ]]; then
            # 如果是shebang行，在它下面插入注释
            echo "File $file has a shebang line. Inserting comment line below shebang."
            sed -i '' "2i\\
$expected_comment_line
" "$file"
        else
            # 检查第一行是否为注释
            if [[ "$first_line" == $comment* ]]; then
                # 如果是注释，检查文件名是否正确
                if [[ "$first_line" != "$expected_comment_line" ]]; then
                    echo "First comment line of $file does not match. Updating."
                    # 使用sed命令更新注释
                    sed -i '' "1s|.*|$expected_comment_line|" "$file"
                else
                    echo "First comment line of $file matches. Skipping."
                fi
            else
                # 如果第一行不是注释，插入注释行
                echo "First line of $file is not a comment. Inserting comment line."
                if [ $ext = "xml" ] || [ $ext = "md" ]; then
                    # 对xml和md文件特殊处理，包括关闭的注释标签
                    sed -i '' "1i\\
$expected_comment_line
" "$file"
                else
                    # 对其他类型的文件在开始处插入注释
                    sed -i '' "1i\\
$expected_comment_line
" "$file"
                fi
            fi
        fi
    done
done

