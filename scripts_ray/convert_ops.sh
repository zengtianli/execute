#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/file_ops.sh"

PYTHON_PATH="${PYTHON_PATH:-python3}"

check_python_env() {
    if ! check_command "$PYTHON_PATH"; then
        return 1
    fi
    return 0
}

check_python_package() {
    local package="$1"
    if ! "$PYTHON_PATH" -c "import $package" 2>/dev/null; then
        echo "❌ 缺少Python包: $package" >&2
        echo "ℹ️ 请运行: pip install $package" >&2
        return 1
    fi
    return 0
}

convert_with_pandoc() {
    local input="$1"
    local output="$2"
    local from_format="$3"
    local to_format="$4"
    
    if ! check_command pandoc; then
        return 1
    fi
    
    if retry_command pandoc -f "$from_format" -t "$to_format" -o "$output" "$input"; then
        echo "✅ 已转换: $(basename "$input") -> $(basename "$output")"
        return 0
    else
        echo "❌ 转换失败: $(basename "$input")"
        return 1
    fi
}

convert_with_soffice() {
    local input="$1"
    local output="$2"
    local format="$3"
    local temp_dir=$(create_temp_dir)
    
    if ! check_command soffice; then
        cleanup_temp "$temp_dir"
        return 1
    fi
    
    if retry_command soffice --headless --convert-to "$format" --outdir "$temp_dir" "$input"; then
        local temp_file="$temp_dir/$(basename "${input%.*}").$format"
        if [ -f "$temp_file" ]; then
            mv "$temp_file" "$output"
            echo "✅ 已转换: $(basename "$input") -> $(basename "$output")"
            cleanup_temp "$temp_dir"
            return 0
        fi
    fi
    
    echo "❌ 转换失败: $(basename "$input")"
    cleanup_temp "$temp_dir"
    return 1
}

batch_convert() {
    local input_dir="$1"
    local output_dir="$2"
    local input_ext="$3"
    local output_ext="$4"
    local converter_func="$5"
    local recursive="$6"
    
    ensure_dir "$output_dir" || return 1
    
    local success_count=0
    local failed_count=0
    local skipped_count=0
    
    local find_cmd="find '$input_dir'"
    if [ "$recursive" != "true" ]; then
        find_cmd="$find_cmd -maxdepth 1"
    fi
    
    while IFS= read -r -d '' file; do
        local rel_path="${file#$input_dir/}"
        local output_file="$output_dir/${rel_path%.*}.$output_ext"
        local output_dir_path="$(dirname "$output_file")"
        
        ensure_dir "$output_dir_path"
        
        if [ -f "$output_file" ]; then
            ((skipped_count++))
            continue
        fi
        
        if "$converter_func" "$file" "$output_file"; then
            ((success_count++))
        else
            ((failed_count++))
        fi
        
    done < <(eval "$find_cmd -type f -name '*.$input_ext' -print0")
    
    echo ""
    echo "📊 转换统计:"
    echo "✅ 成功: $success_count"
    echo "❌ 失败: $failed_count"
    echo "⏭️ 跳过: $skipped_count"
    echo "📝 总计: $((success_count + failed_count + skipped_count))"
} 