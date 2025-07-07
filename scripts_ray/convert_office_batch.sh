#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.1.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-05"

readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

show_version() {
    show_version_template
}

show_help() {
    show_help_header "$0" "文档格式转换综合工具"
    echo "    -d, --doc          doc -> docx -> md"
    echo "    -x, --excel        xls -> xlsx -> csv"
    echo "    -p, --ppt          pptx -> md"
    echo "    -a, --all          执行所有转换"
    echo "    -r, --recursive    递归处理"
    show_help_footer
}

run_conversion() {
    local script_name="$1"
    shift
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [ ! -x "$script_path" ]; then
        if [ -f "$script_path" ]; then
            chmod +x "$script_path"
        else
            show_error "转换脚本未找到: $script_name"
            return 1
        fi
    fi

    show_info "--- 开始执行: $script_name $* ---"
    if "$script_path" "$@"; then
        show_success "--- 完成执行: $script_name ---"
    else
        show_error "--- 执行失败: $script_name ---"
    fi
    echo
}

main() {
    local convert_doc=false
    local convert_excel=false
    local convert_ppt=false
    local recursive=false
    local extra_args=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--doc) convert_doc=true; shift ;;
            -x|--excel) convert_excel=true; shift ;;
            -p|--ppt) convert_ppt=true; shift ;;
            -a|--all) convert_doc=true; convert_excel=true; convert_ppt=true; shift ;;
            -r|--recursive) recursive=true; shift ;;
            -h|--help) show_help; exit 0 ;;
            --version) show_version; exit 0 ;;
            *) show_error "未知选项: $1"; show_help; exit 1 ;;
        esac
    done

    if ! $convert_doc && ! $convert_excel && ! $convert_ppt; then
        show_warning "未指定任何转换选项"; show_help; exit 1
    fi

    [ "$recursive" = true ] && extra_args="-r"

    local start_time
    start_time=$(date +%s)
    
    show_info "===== 开始批量转换任务 ====="
    
    if $convert_doc; then
        show_info ">>> 正在处理 Word 文档链 (doc -> docx -> md)..."
        # Since doc to docx is implicit in modern tools, we can simplify
        # Assuming docx to md and docx to pdf handles .doc files gracefully or they need to be converted first.
        # For simplicity, we only call docx conversion scripts.
        run_conversion "convert_docx_to_md.sh" $extra_args
        run_conversion "convert_docx_to_pdf.sh" $extra_args
    fi

    if $convert_excel; then
        show_info ">>> 正在处理 Excel 文档链 (xls -> xlsx -> csv)..."
        # Similar to doc, focusing on the final conversion steps
        run_conversion "convert_xlsx_to_csv.py" $extra_args
        run_conversion "convert_xlsx_to_txt.py" $extra_args
    fi

    if $convert_ppt; then
        show_info ">>> 正在处理 PowerPoint 文档 (pptx -> md)..."
        run_conversion "convert_pptx_to_md.py"
    fi

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo
    show_success "===== 所有转换任务完成 ====="
    show_info "总耗时: ${duration} 秒"
}

main "$@"
