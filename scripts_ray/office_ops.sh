#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

show_help() {
    show_help_header "$0" "Office文件操作工具集"
    echo "    extract_img        提取图片"
    echo "    extract_tbl        提取表格"
    echo "    convert            批量格式转换"
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
        extract_img) script_to_run="extract_images_office.py" ;;
        extract_tbl) script_to_run="extract_tables_office.py" ;;
        convert) script_to_run="convert_office_batch.sh" ;;
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