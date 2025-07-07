#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

show_version() {
    show_version_template
}

show_help() {
    show_help_header "$0" "文档转文本工具 - 使用 Pandoc 将.doc/.docx转为.txt"
    echo "    -r, --recursive  递归处理子目录"
    show_help_footer
    echo "依赖:"
    echo "    - pandoc"
}

check_dependencies() {
    show_info "检查依赖项..."
    check_command_exists "pandoc" || return 1
    show_success "依赖检查完成"
}

convert_single_file() {
    local file="$1"
    
    validate_input_file "$file" || return 1
    
    local file_ext=$(get_file_extension "$file")
    if [[ "$file_ext" != "doc" && "$file_ext" != "docx" ]]; then
        show_warning "跳过不支持的文件: $(basename "$file")"
        return 1
    fi
    
    local output_file="${file%.*}.txt"
    if [ -f "$output_file" ]; then
        show_warning "输出文件已存在，跳过: $(basename "$output_file")"
        return 1
    fi
    
    show_processing "转换: $(basename "$file")"
    
    if retry_command pandoc -f "$file_ext" -t plain --wrap=none -o "$output_file" "$file"; then
        show_success "已转换: $(basename "$file") -> $(basename "$output_file")"
        return 0
    else
        show_error "转换失败: $(basename "$file")"
        return 1
    fi
}

process_directory() {
    local target_dir="${1:-.}"
    local recursive="$2"
    
    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi
    
    safe_cd "$target_dir" || return 1
    show_info "处理目录: $(pwd)"
    
    local success_count=0
    local failed_count=0
    local total_count=0
    
    local find_cmd="find . -maxdepth 1"
    [ "$recursive" = true ] && find_cmd="find ."
    
    while IFS= read -r -d '' file; do
        ((total_count++))
        if convert_single_file "$file"; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    done < <($find_cmd \( -name "*.doc" -o -name "*.docx" \) -print0 2>/dev/null)
    
    echo
    show_info "处理完成"
    echo "✅ 成功转换: $success_count 个文件"
    [ $failed_count -gt 0 ] && echo "❌ 转换失败: $failed_count 个文件"
    echo "📊 总计处理: $total_count 个文件"
    
    [ $total_count -eq 0 ] && show_warning "未找到支持的文档文件"
}

main() {
    local target_dir="."
    local recursive=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) recursive=true; shift ;;
            --version) show_version; exit 0 ;;
            -h|--help) show_help; exit 0 ;;
            -*) show_error "未知选项: $1"; show_help; exit 1 ;;
            *) target_dir="$1"; shift ;;
        esac
    done
    
    check_dependencies || exit 1
    process_directory "$target_dir" "$recursive"
}

main "$@"

