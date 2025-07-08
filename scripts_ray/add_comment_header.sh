#!/bin/bash
# add_comment_header.sh
#
# 功能:
# 为指定目录中的多种类型文件添加注释头（例如 "# filename.sh"）。
# 脚本能够智能处理 shebang 行和已存在的注释。

TARGET_DIR="."
if [ -n "$1" ]; then
    if [ -d "$1" ]; then
        TARGET_DIR="$1"
    else
        echo "错误：目录 '$1' 未找到。" >&2
        exit 1
    fi
fi

# 使用关联数组定义不同扩展名及其注释符号
declare -A COMMENT_STYLES
COMMENT_STYLES["py"]="#"
COMMENT_STYLES["js"]="//"
COMMENT_STYLES["lua"]="--"
COMMENT_STYLES["sh"]="#"
COMMENT_STYLES["zsh"]="#"
COMMENT_STYLES["vue"]="//"
COMMENT_STYLES["xml"]="<!--"
COMMENT_STYLES["md"]="<!--"
# JSON 和 YAML 文件被跳过，因为它们没有标准的注释语法。

process_file() {
    local file_path="$1"
    local file_name
    file_name=$(basename "$file_path")
    local ext="${file_name##*.}"

    local comment_start=${COMMENT_STYLES[$ext]}
    if [ -z "$comment_start" ]; then
        return
    fi

    local comment_end=""
    if [[ "$ext" == "xml" || "$ext" == "md" ]]; then
        comment_end=" -->"
    fi

    local expected_comment="$comment_start $file_name$comment_end"

    local first_line
    first_line=$(head -n 1 "$file_path")
    local second_line
    second_line=$(head -n 2 "$file_path" | tail -n 1)

    # 情况1: 文件包含shebang
    if [[ "$first_line" == "#!"* ]]; then
        if [[ "$second_line" == "$expected_comment" ]]; then
            echo "文件头已存在于 $file_name (带shebang)，跳过。"
            return
        fi
        echo "为 $file_name (带shebang) 添加文件头。"
        sed -i '' "2i\\
$expected_comment
" "$file_path"
        return
    fi

    # 情况2: 文件不含shebang，检查第一行
    if [[ "$first_line" == "$expected_comment" ]]; then
        echo "文件头已存在于 $file_name，跳过。"
        return
    fi

    if [[ "$first_line" == "$comment_start"* ]]; then
        echo "更新 $file_name 的文件头。"
        sed -i '' "1s|.*|$expected_comment|" "$file_path"
        return
    fi

    # 情况3: 文件既无shebang也无注释，在顶部插入
    echo "为 $file_name 添加文件头。"
    sed -i '' "1i\\
$expected_comment
" "$file_path"
}

# 构建find命令查找所有相关文件
find_args=("$TARGET_DIR" -maxdepth 1 -type f)
find_or_args=()
for ext in "${!COMMENT_STYLES[@]}"; do
    if [ ${#find_or_args[@]} -eq 0 ]; then
        find_or_args+=("-name" "*.$ext")
    else
        find_or_args+=("-o" "-name" "*.$ext")
    fi
done

# 使用括号将OR条件分组
find "${find_args[@]}" \( "${find_or_args[@]}" \) -print0 | while IFS= read -r -d $'\0' file; do
    process_file "$file"
done

echo "文件头注释处理完成。"

