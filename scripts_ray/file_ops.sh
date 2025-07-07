#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

show_help() {
    show_help_header "$0" "文件操作工具集"
    echo "    compress           压缩文件/文件夹"
    echo "    merge_md           合并Markdown文件"
    echo "    merge_csv          合并CSV文件"
    echo "    split_excel        拆分Excel工作表"
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
        compress) script_to_run="compress_select.sh" ;;
        merge_md) script_to_run="merge_markdown_files.sh" ;;
        merge_csv) script_to_run="merge_csv_files.sh" ;;
        split_excel) script_to_run="splitsheets.py" ;;
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