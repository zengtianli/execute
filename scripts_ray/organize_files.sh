#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

show_help() {
    show_help_header "$0" "文件组织与维护工具集"
    echo "    list               列出文件内容 (替代 list_contents.sh)"
    echo "    add-header         为文件添加通用注释头 (替代 add_comment_header.sh)"
    echo "    format-md          格式化Markdown文件 (替代 format_md.sh)"
    echo "    move-by-prefix     根据数字前缀移动文件 (替代 move_files_by_prefix.sh)"
    echo "    flatten-destructive 将子目录文件移至上层并删除空目录"
    echo "    flatten-keep       将子目录文件移至上层但保留目录结构"
    show_help_footer
}

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi

    local command="$1"
    shift

    local script_to_run=""
    case "$command" in
        list) script_to_run="list_contents.sh" ;;
        add-header) script_to_run="add_comment_header.sh" ;;
        format-md) script_to_run="format_md.sh" ;;
        move-by-prefix) script_to_run="move_files_by_prefix.sh" ;;
        flatten-destructive) script_to_run="flatten_directory_destructive.sh" ;;
        flatten-keep) script_to_run="flatten_directory_keep_folders.sh" ;;
        *) show_error "未知命令: $command"; show_help; exit 1 ;;
    esac

    local script_path="$SCRIPT_DIR/$script_to_run"
    if [ ! -f "$script_path" ]; then
        fatal_error "脚本不存在: $script_path"
    fi

    show_info "--- 正在执行: $script_to_run $* ---"
    if [[ "$script_to_run" == *.py ]]; then
        python3 "$script_path" "$@"
    else
        bash "$script_path" "$@"
    fi
    show_success "--- 执行完成 ---"
}

main "$@" 