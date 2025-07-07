#!/bin/bash

# compress_select.sh - Finder选中文件压缩工具
# 版本: 1.1.0
# 作者: tianli

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本信息
readonly SCRIPT_VERSION="1.1.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-12"

# 显示版本信息
show_version() {
    echo "智能ZIP压缩工具 v${SCRIPT_VERSION}"
    echo "作者: ${SCRIPT_AUTHOR}"
}

# 显示帮助信息
show_help() {
    show_help_header "$0" "智能ZIP压缩工具 - 压缩指定文件/文件夹或Finder选中项"
    echo "    -o, --output     输出文件名（不含扩展名）"
    echo "    -d, --output-dir 输出目录（默认为当前目录或文件所在目录）"
    echo "    --exclude-ds     排除 .DS_Store 文件"
    show_help_footer
    
    echo "参数:"
    echo "    文件/文件夹      要压缩的文件或文件夹路径（可多个）"
    echo "                    如不提供，则使用Finder选中的文件"
    echo ""
    echo "使用模式:"
    echo "  1. 命令行模式（直接指定文件/文件夹）："
    echo "    $0 file1.txt dir1/                   # 压缩指定文件和目录"
    echo "    $0 file1.txt file2.txt folder/      # 压缩多个文件和文件夹"
    echo "    $0 -o \"backup\" ~/Documents/project/ # 压缩目录，指定输出名"
    echo "    $0 -d ~/Desktop file1.txt           # 压缩文件到桌面"
    echo ""
    echo "  2. Finder集成模式（使用选中文件）："
    echo "    $0                                   # 压缩Finder选中文件"
    echo "    $0 --exclude-ds                     # 排除系统文件"
    echo "    $0 -o \"archive\"                     # 指定输出文件名"
    echo ""
    echo "功能:"
    echo "    - 支持命令行直接指定文件/文件夹"
    echo "    - 自动检测Finder选中文件（无参数时）"
    echo "    - ZIP格式压缩，兼容性最佳"
    echo "    - 使用相对路径，避免深层目录结构"
    echo "    - 智能命名和重复文件处理"
}

# 验证输入文件列表
validate_input_files() {
    local files_list="$1"
    local validated_files=()
    local invalid_count=0
    local valid_names=()
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # 展开波浪号和相对路径
            local expanded_path=$(eval echo "$line")
            
            if [ -e "$expanded_path" ]; then
                # 获取绝对路径
                local abs_path=$(realpath "$expanded_path" 2>/dev/null || readlink -f "$expanded_path" 2>/dev/null || echo "$expanded_path")
                validated_files+=("$abs_path")
                valid_names+=("$(basename "$abs_path")")
            else
                show_warning "✗ 文件不存在: $line"
                ((invalid_count++))
            fi
        fi
    done <<< "$files_list"
    
    if [ ${#validated_files[@]} -eq 0 ]; then
        show_error "没有找到有效的文件或文件夹"
        return 1
    fi
    
    # 显示验证结果（输出到stderr，不影响函数返回值）
    show_info "有效文件: ${valid_names[*]}" >&2
    if [ $invalid_count -gt 0 ]; then
        show_warning "跳过了 $invalid_count 个无效路径" >&2
    fi
    
    printf '%s\n' "${validated_files[@]}"
    return 0
}

# 智能确定输出目录
determine_output_directory() {
    local files_list="$1"
    local specified_dir="$2"
    
    # 如果指定了输出目录，优先使用
    if [ -n "$specified_dir" ]; then
        local expanded_dir=$(eval echo "$specified_dir")
        if [ -d "$expanded_dir" ]; then
            realpath "$expanded_dir" 2>/dev/null || echo "$expanded_dir"
            return 0
        else
            show_error "指定的输出目录不存在: $specified_dir"
            return 1
        fi
    fi
    
    # 如果没有文件列表，使用当前目录
    if [ -z "$files_list" ]; then
        pwd
        return 0
    fi
    
    # 使用第一个文件的目录作为输出目录
    local first_file=$(echo "$files_list" | head -1)
    if [ -d "$first_file" ]; then
        # 如果第一个是目录，使用其父目录
        dirname "$(realpath "$first_file" 2>/dev/null || echo "$first_file")"
    else
        # 如果第一个是文件，使用其所在目录
        dirname "$(realpath "$first_file" 2>/dev/null || echo "$first_file")"
    fi
}

# 生成压缩文件名
generate_archive_name() {
    local base_name="$1"
    local output_dir="$2"
    
    if [ -z "$base_name" ]; then
        base_name="archive_$(date +%Y%m%d_%H%M%S)"
    fi
    
    generate_unique_filename "$base_name" ".zip" "$output_dir"
}

# 将绝对路径转换为相对路径
convert_to_relative_paths() {
    local files_list="$1"
    local base_dir="$2"
    local relative_paths=()
    
    # 确保 base_dir 以 / 结尾，方便字符串操作
    if [[ "$base_dir" != */ ]]; then
        base_dir="$base_dir/"
    fi
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # 使用 Python 计算相对路径（最可靠的方法）
            local rel_path=$(python3 -c "import os; print(os.path.relpath('$line', '${base_dir%/}'))" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$rel_path" ]; then
                if [ "$rel_path" = "." ]; then
                    # 如果是当前目录，使用目录名
                    relative_paths+=("$(basename "$line")")
                elif [[ "$rel_path" == ../* ]]; then
                    # 如果路径包含上级目录，只使用文件名
                    relative_paths+=("$(basename "$line")")
                else
                    relative_paths+=("$rel_path")
                fi
            else
                # 备用方案：手动字符串处理
                if [[ "$line" == "$base_dir"* ]]; then
                    # 文件在基础目录内
                    local rel_path="${line#$base_dir}"
                    if [ -z "$rel_path" ] || [ "$rel_path" = "/" ]; then
                        # 如果是同一个目录
                        relative_paths+=("$(basename "$line")")
                    else
                        relative_paths+=("$rel_path")
                    fi
                else
                    # 文件在基础目录外，只使用文件名
                    relative_paths+=("$(basename "$line")")
                fi
            fi
        fi
    done <<< "$files_list"
    
    printf '%s\n' "${relative_paths[@]}"
}

# 执行ZIP压缩操作
compress_files() {
    local files_list="$1"
    local output_file="$2"
    local exclude_ds="$3"
    local output_dir="$4"
    
    if [ -z "$files_list" ]; then
        show_error "没有选中任何文件"
        return 1
    fi
    
    show_processing "正在压缩文件为 ZIP 格式"
    
    # 保存当前目录
    local original_dir=$(pwd)
    
    # 切换到输出目录，使用相对路径
    if ! safe_cd "$output_dir"; then
        return 1
    fi
    
    # 转换为相对路径
    local relative_files=$(convert_to_relative_paths "$files_list" "$output_dir")
    
    # 处理特殊情况：用户选中了当前目录
    # 检查是否所有文件都是当前目录，如果是，则压缩目录内容
    local has_current_dir=false
    local current_dir_name=""
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # 检查原始路径是否与输出目录相同
            local original_file=""
            while IFS= read -r orig_line; do
                if [ -n "$orig_line" ] && [ "$(basename "$orig_line")" = "$line" ]; then
                    original_file="$orig_line"
                    break
                fi
            done <<< "$files_list"
            
            if [ "$original_file" = "$output_dir" ] || [ "$original_file" = "${output_dir%/}" ]; then
                has_current_dir=true
                current_dir_name="$line"
                break
            fi
        fi
    done <<< "$relative_files"
    
    # 准备文件列表数组
    local files_array=()
    
    # 如果选中了当前目录，修改为压缩目录内容
    if [ "$has_current_dir" = true ]; then
        show_info "检测到选中当前目录，将压缩目录内容"
        # 获取当前目录中的所有可见文件和目录
        for item in *; do
            if [ -e "$item" ] && [ "$item" != "$(basename "$output_file")" ]; then
                files_array+=("$item")
            fi
        done
        
        if [ ${#files_array[@]} -eq 0 ]; then
            show_error "当前目录为空或只包含输出文件"
            safe_cd "$original_dir"
            return 1
        fi
    else
        # 正常模式：使用相对路径
        while IFS= read -r line; do
            if [ -n "$line" ] && [ "$line" != "" ]; then
                files_array+=("$line")
            fi
        done <<< "$relative_files"
    fi
    
    if [ ${#files_array[@]} -eq 0 ]; then
        show_error "没有有效的文件"
        safe_cd "$original_dir"
        return 1
    fi
    
    show_info "项目数量: ${#files_array[@]}"
    
    # 获取输出文件的基本名（因为我们在输出目录中）
    local archive_name=$(basename "$output_file")
    
    # 执行ZIP压缩
    local zip_options=""
    if [ "$exclude_ds" = true ]; then
        zip_options="-x *.DS_Store"
    fi
    
    if zip -r $zip_options "$archive_name" "${files_array[@]}" >/dev/null 2>&1; then
        show_success "ZIP压缩完成: $archive_name"
        # 切换回原目录
        safe_cd "$original_dir"
        return 0
    else
        show_error "ZIP压缩失败"
        # 切换回原目录
        safe_cd "$original_dir"
        return 1
    fi
}

# 主函数
main() {
    local output_name=""
    local output_dir_specified=""
    local exclude_ds=false
    local input_files=()
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            -o|--output)
                if [ -n "$2" ]; then
                    output_name="$2"
                    shift 2
                else
                    show_error "选项 $1 需要一个参数"
                    exit 1
                fi
                ;;
            -d|--output-dir)
                if [ -n "$2" ]; then
                    output_dir_specified="$2"
                    shift 2
                else
                    show_error "选项 $1 需要一个参数"
                    exit 1
                fi
                ;;
            --exclude-ds)
                exclude_ds=true
                shift
                ;;
            -*)
                show_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                # 收集输入文件/目录
                input_files+=("$1")
                shift
                ;;
        esac
    done
    
    local selected_files=""
    local use_finder_mode=false
    
    # 确定文件来源
    if [ ${#input_files[@]} -gt 0 ]; then
        # 命令行模式：使用指定的文件/目录
        show_info "命令行模式：处理 ${#input_files[@]} 个输入项"
        
        # 将输入文件数组转换为换行分隔的字符串
        printf -v input_files_str '%s\n' "${input_files[@]}"
        
        # 验证输入文件
        selected_files=$(validate_input_files "$input_files_str")
        if [ $? -ne 0 ]; then
            exit 1
        fi
    else
        # Finder模式：使用Finder选中的文件
        show_info "Finder模式：获取选中文件"
        use_finder_mode=true
        
        selected_files=$(get_finder_selection)
        if [ -z "$selected_files" ]; then
            show_error "没有在命令行指定文件，且Finder中没有选中任何文件"
            show_info "使用方式："
            show_info "  1. 在命令行指定文件/文件夹：$0 file1.txt dir1/"
            show_info "  2. 在Finder中选中文件后运行：$0"
            exit 1
        fi
        

    fi
    
    # 确定输出目录
    local output_dir
    if [ "$use_finder_mode" = true ]; then
        # Finder模式：特殊处理选中单个文件夹的情况
        local finder_current_dir=$(get_finder_directory)
        validate_finder_directory "$finder_current_dir"
        
        # 检查是否只选中了一个项目，且该项目是当前目录
        local selection_count=$(echo "$selected_files" | wc -l | tr -d ' ')
        local selected_item=$(echo "$selected_files" | head -1)
        
        if [ "$selection_count" = "1" ] && [ -d "$selected_item" ] && 
           { [ "$selected_item" = "$finder_current_dir" ] || [ "$selected_item" = "${finder_current_dir%/}" ]; }; then
            # 用户选中了一个文件夹，且当前就在该文件夹内
            # 输出目录应该是该文件夹的父目录
            output_dir=$(dirname "$selected_item")
            show_info "检测到选中单个文件夹，将压缩到父目录"
        else
            # 正常情况：使用Finder当前目录
            output_dir="$finder_current_dir"
        fi
    else
        # 命令行模式：智能确定输出目录
        output_dir=$(determine_output_directory "$selected_files" "$output_dir_specified")
        if [ $? -ne 0 ]; then
            exit 1
        fi
        
        # 确保输出目录存在且可写
        ensure_directory "$output_dir"
        if [ ! -w "$output_dir" ]; then
            show_error "输出目录不可写: $output_dir"
            exit 1
        fi
    fi
    
    show_info "输出目录: $output_dir"
    
    # 生成输出文件名
    local output_file=$(generate_archive_name "$output_name" "$output_dir")
    show_info "输出文件: $(basename "$output_file")"
    
    # 执行压缩
    if compress_files "$selected_files" "$output_file" "$exclude_ds" "$output_dir"; then
        if [ "$use_finder_mode" = true ]; then
            reveal_file_in_finder "$output_file"
            show_success "压缩完成，文件已在Finder中选中"
        else
            show_success "压缩完成: $output_file"
            show_info "可以在 Finder 中查看: $(dirname "$output_file")"
        fi
    fi
}

# 运行主程序
main "$@" 