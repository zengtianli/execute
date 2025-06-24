#!/bin/bash

# wmf2png.sh - 使用 LibreOffice 将 WMF 文件转换为 PNG
# 功能: 将当前目录的所有 .wmf 文件转换为 .png 格式
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# LibreOffice 路径
readonly SOFFICE_PATH="/Applications/LibreOffice.app/Contents/MacOS/soffice"

# 显示版本信息
show_version() {
    echo "WMF转PNG工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
WMF转PNG工具 - 使用 LibreOffice 将 WMF 文件转换为 PNG

用法: $0 [选项] [目录]

选项:
    -r, --recursive  递归处理子目录
    -v, --verbose    显示详细输出
    -h, --help       显示此帮助信息
    --version        显示版本信息

参数:
    目录            要处理的目录（默认：当前目录）

示例:
    $0                  # 转换当前目录的所有 WMF 文件
    $0 -r               # 递归转换所有子目录
    $0 ./images         # 转换指定目录的 WMF 文件
    $0 -r ./images      # 递归转换指定目录

依赖:
    - LibreOffice (macOS Application)
EOF
    exit 0
}

# 检查依赖
check_dependencies() {
    show_info "检查依赖项..."
    
    if [ ! -f "$SOFFICE_PATH" ]; then
        show_error "未找到 LibreOffice"
        show_info "请安装 LibreOffice: https://www.libreoffice.org/download/"
        return 1
    fi
    
    show_success "依赖检查完成"
    return 0
}

# 转换单个 WMF 文件
# 参数: $1 = 文件路径
convert_single_wmf() {
    local file="$1"
    
    # 验证输入文件
    validate_input_file "$file" || return 1
    
    # 检查文件类型
    if ! check_file_extension "$file" "wmf"; then
        show_warning "跳过非WMF文件: $(basename "$file")"
        return 1
    fi
    
    local base_name=$(get_file_basename "$file")
    local file_dir=$(dirname "$file")
    local output_file="$file_dir/$base_name.png"
    
    # 检查输出文件是否已存在
    if [ -f "$output_file" ]; then
        show_warning "输出文件已存在，跳过: $(basename "$output_file")"
        return 1
    fi
    
    show_processing "转换: $(basename "$file")"
    
    # 构建转换命令
    local cmd=(
        "$SOFFICE_PATH"
        "--headless"
        "--convert-to" "png"
        "--outdir" "$file_dir"
        "$file"
    )
    
    # 执行转换（带超时）
    if timeout 30 retry_command "${cmd[@]}" &>/dev/null; then
        # 检查输出文件是否实际生成
        if [ -f "$output_file" ]; then
            show_success "已转换: $(basename "$file") -> $(basename "$output_file")"
            return 0
        else
            show_warning "转换完成但未找到输出文件: $(basename "$file")"
            return 1
        fi
    else
        show_error "转换失败或超时: $(basename "$file")"
        return 1
    fi
}

# 查找并转换 WMF 文件
# 参数: $1 = 目录路径, $2 = 是否递归
process_directory() {
    local target_dir="${1:-.}"
    local recursive="$2"
    
    # 验证目录
    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi
    
    show_info "处理目录: $target_dir"
    
    # 统计变量
    local success_count=0
    local skipped_count=0
    local total_count=0
    
    # 查找文件
    local find_cmd="find '$target_dir' -maxdepth 1"
    if [ "$recursive" = true ]; then
        find_cmd="find '$target_dir'"
    fi
    
    # 处理所有 WMF 文件（包括大写扩展名）
    while IFS= read -r -d '' file; do
        ((total_count++))
        show_progress "$total_count" "?" "$(basename "$file")"
        
        if convert_single_wmf "$file"; then
            ((success_count++))
        else
            ((skipped_count++))
        fi
    done < <(eval "$find_cmd \\( -iname '*.wmf' \\) -type f -print0" 2>/dev/null)
    
    # 显示处理统计
    echo ""
    show_info "转换完成"
    echo "✅ 成功转换: $success_count 个文件"
    if [ $skipped_count -gt 0 ]; then
        echo "⚠️ 跳过文件: $skipped_count 个"
    fi
    echo "📊 总计处理: $total_count 个文件"
    
    if [ $total_count -eq 0 ]; then
        show_warning "未找到 WMF 文件"
    else
        local success_rate=$((success_count * 100 / total_count))
        echo "📊 成功率: ${success_rate}%"
    fi
}

# 主程序
main() {
    # 默认值
    local target_dir="."
    local recursive=false
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive)
                recursive=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            -h|--help)
                show_help
                ;;
            -*)
                show_error "未知选项: $1"
                show_help
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # 检查依赖
    check_dependencies || exit 1
    
    # 处理目录
    process_directory "$target_dir" "$recursive"
}

# 设置清理陷阱
cleanup() {
    local exit_code=$?
    # 清理临时文件等
    exit $exit_code
}
trap cleanup EXIT

# 运行主程序
main "$@"

