#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

show_version() {
    show_version_template
}

show_help() {
    show_help_header "$0" "Markdown文件合并工具"
    echo "    -o, --output <文件名>  指定输出文件名 (默认: merged.md)"
    echo "    -d, --dir <目录>      指定Markdown文件所在目录 (默认: 当前目录)"
    echo "    -s, --sort <type>    排序方式: name(默认), mtime"
    echo "    -r, --recursive      递归查找文件"
    echo "    -n, --no-title       不添加文件名作为标题"
    show_help_footer
}

main() {
    local output_file="merged.md"
    local target_dir="."
    local sort_by="name"
    local recursive=false
    local add_title=true

    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output) output_file="$2"; shift 2 ;;
            -d|--dir) target_dir="$2"; shift 2 ;;
            -s|--sort) sort_by="$2"; shift 2 ;;
            -r|--recursive) recursive=true; shift ;;
            -n|--no-title) add_title=false; shift ;;
            -h|--help) show_help; exit 0 ;;
            --version) show_version; exit 0 ;;
            *) show_error "未知选项: $1"; show_help; exit 1 ;;
        esac
    done

    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi

    local find_cmd="find '$target_dir' -name '*.md' -type f"
    [ "$recursive" = false ] && find_cmd="find '$target_dir' -maxdepth 1 -name '*.md' -type f"

    local files
    if [ "$sort_by" = "mtime" ]; then
        files=$(eval "$find_cmd" -print0 | xargs -0 ls -t)
    else
        files=$(eval "$find_cmd" | sort)
    fi

    if [ -z "$files" ]; then
        show_warning "在 '$target_dir' 中未找到Markdown文件"
        exit 0
    fi
    
    local file_count
    file_count=$(echo "$files" | wc -l | tr -d ' ')
    show_info "找到 $file_count 个Markdown文件，将合并到 $output_file"

    > "$output_file"

    local current_file=0
    while IFS= read -r file; do
        ((current_file++))
        show_processing "进度 ($current_file/$file_count): 正在合并 $(basename "$file")"
        
        if [ "$add_title" = true ]; then
            echo -e "\n\n# $(basename "${file%.md}")\n\n" >> "$output_file"
        fi
        
        cat "$file" >> "$output_file"
        echo -e "\n" >> "$output_file"
    done <<< "$files"

    show_success "所有文件已成功合并到 $output_file"
}

main "$@"

