#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-05"

show_version() {
    show_version_template
}

show_help() {
    show_help_header "$0" "Python包管理工具"
    echo "    -i, --install <file>   从文件安装包"
    echo "    -u, --update <file>    从文件更新包"
    echo "    -e, --export [file]    导出已安装的包"
    echo "    -c, --check [file]     检查文件中的包"
    echo "    --pip-path <path>      指定pip路径 (默认: pip3)"
    show_help_footer
}

run_pip_command() {
    local pip_cmd="$1"
    shift
    show_processing "执行: $pip_cmd $*"
    if ! "$pip_cmd" "$@"; then
        show_error "pip命令执行失败"
        return 1
    fi
    show_success "pip命令执行成功"
}

install_packages() {
    local req_file="$1"
    local pip_cmd="$2"
    validate_input_file "$req_file" || exit 1
    run_pip_command "$pip_cmd" install -r "$req_file"
}

update_packages() {
    local req_file="$1"
    local pip_cmd="$2"
    validate_input_file "$req_file" || exit 1
    run_pip_command "$pip_cmd" install --upgrade -r "$req_file"
}

export_packages() {
    local output_file="${1:-requirements_export.txt}"
    local pip_cmd="$2"
    run_pip_command "$pip_cmd" freeze > "$output_file"
    show_info "已导出到: $output_file"
}

check_packages() {
    local req_file="$1"
    local pip_cmd="$2"
    validate_input_file "$req_file" || exit 1
    run_pip_command "$pip_cmd" check -r "$req_file"
}

main() {
    local action=""
    local file_arg=""
    local pip_cmd="pip3"

    if [ $# -eq 0 ]; then
        show_help; exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--install) action="install"; file_arg="$2"; shift 2 ;;
            -u|--update) action="update"; file_arg="$2"; shift 2 ;;
            -e|--export) action="export"; file_arg="$2"; shift 2 ;;
            -c|--check) action="check"; file_arg="$2"; shift 2 ;;
            --pip-path) pip_cmd="$2"; shift 2 ;;
            -h|--help) show_help; exit 0 ;;
            --version) show_version; exit 0 ;;
            *) show_error "未知选项: $1"; show_help; exit 1 ;;
        esac
    done

    check_command_exists "$pip_cmd" || fatal_error "未找到pip命令: $pip_cmd"

    case "$action" in
        install) install_packages "$file_arg" "$pip_cmd" ;;
        update) update_packages "$file_arg" "$pip_cmd" ;;
        export) export_packages "$file_arg" "$pip_cmd" ;;
        check) check_packages "$file_arg" "$pip_cmd" ;;
        *) show_error "未指定有效操作"; show_help; exit 1 ;;
    esac
}

main "$@"
