#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

show_version() {
    show_version_template
}

show_help() {
    show_help_header "$0" "DOCX转PDF工具 - 使用 LibreOffice/Pandoc 转换"
    echo "    -r, --recursive  递归处理子目录"
    show_help_footer
    echo "依赖: soffice (LibreOffice) 或 pandoc"
}

check_dependencies() {
    show_info "检查依赖项..."
    if ! check_command_exists soffice && ! check_command_exists pandoc; then
        fatal_error "必须安装 LibreOffice (soffice) 或 pandoc"
    fi
    show_success "依赖检查完成"
}

convert_single_file() {
    local file="$1"
    
    validate_input_file "$file" || return 1
    
    if ! check_file_extension "$file" "docx"; then
        show_warning "跳过非DOCX文件: $(basename "$file")"
        return 1
    fi
    
    local output_file="${file%.docx}.pdf"
    if [ -f "$output_file" ]; then
        show_warning "输出文件已存在，跳过: $(basename "$output_file")"
        return 1
    fi
    
    show_processing "转换: $(basename "$file")"
    
    # 优先使用 LibreOffice
    if check_command_exists soffice; then
        local outdir=$(dirname "$file")
        if retry_command soffice --headless --convert-to pdf --outdir "$outdir" "$file"; then
            show_success "已转换 (soffice): $(basename "$file") -> $(basename "$output_file")"
            return 0
        fi
    fi

    # LibreOffice失败或未安装时，尝试Pandoc
    if check_command_exists pandoc; then
        if retry_command pandoc "$file" -o "$output_file"; then
            show_success "已转换 (pandoc): $(basename "$file") -> $(basename "$output_file")"
            return 0
        fi
    fi
    
    show_error "转换失败: $(basename "$file")"
    return 1
}

process_directory() {
    local target_dir="${1:-.}"
    local recursive="$2"
    
    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi
    
    show_info "处理目录: $target_dir"
    
    local success_count=0
    local failed_count=0
    local total_count=0
    
    local find_cmd="find '$target_dir' -maxdepth 1"
    [ "$recursive" = true ] && find_cmd="find '$target_dir'"
    
    while IFS= read -r -d '' file; do
        ((total_count++))
        if convert_single_file "$file"; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    done < <(eval "$find_cmd -name '*.docx' -type f -print0" 2>/dev/null)
    
    echo
    show_info "批量转换完成"
    echo "✅ 成功转换: $success_count 个文件"
    [ $failed_count -gt 0 ] && echo "❌ 转换失败: $failed_count 个文件"
    echo "📊 总计处理: $total_count 个文件"
    
    [ $total_count -eq 0 ] && show_warning "未找到 DOCX 文件"
}

main() {
    local recursive=false
    local target="."

    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) recursive=true; shift ;;
            --version) show_version; exit 0 ;;
            -h|--help) show_help; exit 0 ;;
            -*) show_error "未知选项: $1"; show_help; exit 1 ;;
            *) target="$1"; shift ;;
        esac
    done

    check_dependencies || exit 1
    
    if [ -f "$target" ]; then
        convert_single_file "$target"
    elif [ -d "$target" ]; then
        process_directory "$target" "$recursive"
    else
        fatal_error "无效的路径: $target"
    fi
}

main "$@"

