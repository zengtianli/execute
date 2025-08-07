#!/bin/bash

# 通用多文件双向同步脚本
# 支持配置文件驱动的多位置文件同步

# 配置文件路径
SCRIPT_DIR="/Users/tianli/useful_scripts/execute/sync"
CONFIG_FILE="$SCRIPT_DIR/sync-config.yaml"
OBS_ROOT="/Users/tianli/obs"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

log_sync() {
    echo -e "${CYAN}[SYNC]${NC} $1"
}

# 检查依赖
check_dependencies() {
    # 检查yq是否安装（用于解析YAML）
    if ! command -v yq >/dev/null 2>&1; then
        log_warn "yq未安装，将使用内置YAML解析器"
        USE_BUILTIN_PARSER=true
    else
        USE_BUILTIN_PARSER=false
    fi
    
    # 检查配置文件
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        return 1
    fi
    
    # 检查fswatch（用于文件监控）
    if ! command -v fswatch >/dev/null 2>&1; then
        log_warn "fswatch未安装，监控模式将不可用"
        log_warn "请使用 brew install fswatch 安装"
    fi
}

# 简单的YAML解析器（当yq不可用时）
parse_yaml() {
    local file="$1"
    
    # 简单解析YAML文件，提取sync_mappings部分
    awk '
    /^sync_mappings:/ { in_mappings = 1; next }
    /^[a-zA-Z]/ && !/^  / && in_mappings { in_mappings = 0 }
    in_mappings && /^  [a-zA-Z_]+:/ { 
        # 获取配置名（去掉前面的空格和后面的冒号）
        gsub(/^  /, "", $1)
        gsub(/:$/, "", $1)
        current_config = $1
        next
    }
    in_mappings && /^    source:/ { 
        # 提取source值，去掉引号
        gsub(/^    source: */, "")
        gsub(/^"/, "")
        gsub(/"$/, "")
        print current_config "_source=" $0
    }
    in_mappings && /^    target:/ { 
        # 提取target值，去掉引号
        gsub(/^    target: */, "")
        gsub(/^"/, "")
        gsub(/"$/, "")
        print current_config "_target=" $0
    }
    in_mappings && /^    description:/ { 
        # 提取description值，去掉引号
        gsub(/^    description: */, "")
        gsub(/^"/, "")
        gsub(/"$/, "")
        print current_config "_description=" $0
    }
    ' "$file"
}

# 获取配置映射
get_sync_mappings() {
    if [[ "$USE_BUILTIN_PARSER" == "true" ]]; then
        parse_yaml "$CONFIG_FILE"
    else
        # 使用yq提取每个配置项的键、源、目标和描述
        yq eval '.sync_mappings | keys | .[]' "$CONFIG_FILE" | while read -r key; do
            echo "${key}_source=$(yq eval ".sync_mappings.${key}.source" "$CONFIG_FILE")"
            echo "${key}_target=$(yq eval ".sync_mappings.${key}.target" "$CONFIG_FILE")"
            echo "${key}_description=$(yq eval ".sync_mappings.${key}.description" "$CONFIG_FILE")"
        done
    fi
}

# 加载配置
load_config() {
    # 使用普通变量而不是关联数组来提高兼容性
    local mappings
    mappings=$(get_sync_mappings)
    
    if [[ -z "$mappings" ]]; then
        log_error "无法解析配置文件"
        return 1
    fi
    
    # 创建临时文件存储配置
    SYNC_CONFIG_FILE="/tmp/sync_configs_$$"
    CONFIG_DESC_FILE="/tmp/config_descs_$$"
    
    # 清空临时文件
    > "$SYNC_CONFIG_FILE"
    > "$CONFIG_DESC_FILE"
    
    # 使用while循环而不是管道，避免子shell问题
    while IFS= read -r line; do
        if echo "$line" | grep -q "_source="; then
            # 提取完整的配置名而不是截断
            local config_name=$(echo "$line" | sed 's/_source=.*//')
            local source_path=$(echo "$line" | cut -d'=' -f2-)
            echo "${config_name}_source=${source_path}" >> "$SYNC_CONFIG_FILE"
        elif echo "$line" | grep -q "_target="; then
            local config_name=$(echo "$line" | sed 's/_target=.*//')
            local target_path=$(echo "$line" | cut -d'=' -f2-)
            echo "${config_name}_target=${target_path}" >> "$SYNC_CONFIG_FILE"
        elif echo "$line" | grep -q "_description="; then
            local config_name=$(echo "$line" | sed 's/_description=.*//')
            local description=$(echo "$line" | cut -d'=' -f2-)
            echo "${config_name}=${description}" >> "$CONFIG_DESC_FILE"
        fi
    done <<< "$mappings"
}

# 获取配置值
get_config_value() {
    local key="$1"
    grep "^${key}=" "$SYNC_CONFIG_FILE" 2>/dev/null | cut -d'=' -f2-
}

# 获取配置描述
get_config_description() {
    local config_name="$1"
    grep "^${config_name}=" "$CONFIG_DESC_FILE" 2>/dev/null | cut -d'=' -f2-
}

# 获取配置列表
get_config_list() {
    if [[ -f "$SYNC_CONFIG_FILE" ]]; then
        grep "_source=" "$SYNC_CONFIG_FILE" | cut -d'=' -f1 | sed 's/_source$//' | sort -u
    fi
}

# 确保目标目录存在
ensure_target_dir() {
    local target_file="$1"
    local target_dir
    target_dir="$(dirname "$target_file")"
    
    if [[ ! -d "$target_dir" ]]; then
        log_info "创建目标目录: $target_dir"
        mkdir -p "$target_dir"
    fi
}

# 验证文件存在
verify_file_exists() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        return 0
    else
        # 检查路径是否包含通配符，可能是多个文件
        if [[ "$file_path" == *"*"* ]]; then
            local expanded_files=$(ls $file_path 2>/dev/null)
            if [[ -n "$expanded_files" ]]; then
                return 0
            fi
        fi
        return 1
    fi
}

# 同步单个配置
sync_single_config() {
    local config_name="$1"
    local force_direction="${2:-smart}"

    local source_path="$(get_config_value "${config_name}_source")"
    local target_path="$(get_config_value "${config_name}_target")"

    if [[ -z "$source_path" || -z "$target_path" ]]; then
        log_error "配置 '$config_name' 未找到"
        return 1
    fi

    log_sync "同步配置: $config_name"
    log_info "  源文件: $source_path"
    log_info "  目标文件: $target_path"

    # 检查文件是否存在
    local source_exists=false
    local target_exists=false
    verify_file_exists "$source_path" && source_exists=true
    verify_file_exists "$target_path" && target_exists=true

    # 根据强制方向处理
    if [[ "$force_direction" == "force-to-target" ]]; then
        if $source_exists; then
            log_info "强制同步：源 → 目标"
            ensure_target_dir "$target_path"
            cp -a "$source_path" "$target_path"
        else
            log_error "强制同步失败，源文件不存在: $source_path"
        fi
        return
    elif [[ "$force_direction" == "force-to-source" ]]; then
        if $target_exists; then
            log_info "强制同步：目标 → 源"
            ensure_target_dir "$source_path"
            cp -a "$target_path" "$source_path"
        else
            log_error "强制同步失败，目标文件不存在: $target_path"
        fi
        return
    fi

    # 智能双向同步逻辑
    if $source_exists && $target_exists; then
        # 两者都存在，比较时间戳
        local source_mtime target_mtime
        source_mtime=$(stat -f %m "$source_path" 2>/dev/null || stat -c %Y "$source_path" 2>/dev/null)
        target_mtime=$(stat -f %m "$target_path" 2>/dev/null || stat -c %Y "$target_path" 2>/dev/null)

        if [[ $source_mtime -gt $target_mtime ]]; then
            log_info "源文件更新，同步到目标"
            cp -a "$source_path" "$target_path"
        elif [[ $target_mtime -gt $source_mtime ]]; then
            log_info "目标文件更新，同步到源"
            cp -a "$target_path" "$source_path"
        else
            log_info "文件已同步，无需更新"
        fi
    elif $source_exists; then
        # 仅源文件存在
        log_info "目标文件不存在，从源同步"
        ensure_target_dir "$target_path"
        cp -a "$source_path" "$target_path"
    elif $target_exists; then
        # 仅目标文件存在
        log_info "源文件不存在，从目标同步"
        ensure_target_dir "$source_path"
        cp -a "$target_path" "$source_path"
    else
        # 两者都不存在
        log_error "源文件和目标文件都不存在"
        return 1
    fi
}

# 显示单个配置状态
show_config_status() {
    local config_name="$1"
    
    local source_path="$(get_config_value "${config_name}_source")"
    local target_path="$(get_config_value "${config_name}_target")"
    local description="$(get_config_description "$config_name")"
    
    if [[ -z "$source_path" || -z "$target_path" ]]; then
        log_error "配置 '$config_name' 未找到"
        return 1
    fi
    
    echo ""
    log_header "$config_name ($description)"
    
    echo "📁 源文件:"
    if verify_file_exists "$source_path"; then
        echo "   路径: $source_path"
        echo "   大小: $(stat -f %z "$source_path" 2>/dev/null || stat -c %s "$source_path" 2>/dev/null) bytes"
        echo "   修改: $(stat -f %Sm "$source_path" 2>/dev/null || stat -c %y "$source_path" 2>/dev/null)"
        echo "   ✅ 存在"
    else
        echo "   ❌ 不存在: $source_path"
    fi
    
    echo ""
    echo "🎯 目标文件 (Obsidian):"
    if verify_file_exists "$target_path"; then
        echo "   路径: $target_path"
        echo "   大小: $(stat -f %z "$target_path" 2>/dev/null || stat -c %s "$target_path" 2>/dev/null) bytes"
        echo "   修改: $(stat -f %Sm "$target_path" 2>/dev/null || stat -c %y "$target_path" 2>/dev/null)"
        echo "   ✅ 存在"
    else
        echo "   ❌ 不存在: $target_path"
    fi
    
    echo ""
    if verify_file_exists "$source_path" && verify_file_exists "$target_path"; then
        if cmp -s "$source_path" "$target_path"; then
            echo "🟢 两个文件内容相同"
        else
            echo "🟡 两个文件内容不同"
        fi
    fi
}

# 显示所有配置状态
show_all_status() {
    log_header "多文件同步状态总览"
    
    local configs
    configs="$(get_config_list)"
    
    if [[ -n "$configs" ]]; then
        echo "$configs" | while read -r config; do
            if [[ -n "$config" ]]; then
                show_config_status "$config"
            fi
        done
    fi
}

# 同步所有配置
sync_all_configs() {
    local force_direction="${1:-smart}"
    
    log_header "同步所有配置文件"
    
    local configs
    configs="$(get_config_list)"
    
    if [[ -n "$configs" ]]; then
        echo "$configs" | while read -r config; do
            if [[ -n "$config" ]]; then
                echo ""
                sync_single_config "$config" "$force_direction"
            fi
        done
    fi
}

# 监控模式
watch_mode() {
    local watch_configs_str=""
    local all_configs
    
    if [[ $# -eq 0 ]]; then
        # 如果没有指定配置，监控所有配置
        all_configs="$(get_config_list)"
        watch_configs_str="$all_configs"
    else
        # 使用提供的配置列表
        watch_configs_str="$*"
    fi
    
    log_header "启动文件监控模式"
    log_info "监控配置: $watch_configs_str"
    log_info "按 Ctrl+C 退出..."
    
    # 构建监控文件列表
    local watch_files_str=""
    echo "$watch_configs_str" | tr ' ' '\n' | while read -r config; do
        if [[ -n "$config" ]]; then
            local source_path="$(get_config_value "${config}_source")"
            local target_path="$(get_config_value "${config}_target")"
            
            if [[ -n "$source_path" && -n "$target_path" ]]; then
                verify_file_exists "$source_path" && echo "$source_path"
                verify_file_exists "$target_path" && echo "$target_path"
            fi
        fi
    done > "/tmp/watch_files_$$"
    
    if [[ ! -s "/tmp/watch_files_$$" ]]; then
        log_error "没有找到可监控的文件"
        rm -f "/tmp/watch_files_$$"
        return 1
    fi
    
    # 使用fswatch进行监控
    if command -v fswatch >/dev/null 2>&1; then
        fswatch -o $(cat "/tmp/watch_files_$$") | while read num; do
            log_info "检测到文件变化，执行同步..."
            echo "$watch_configs_str" | tr ' ' '\n' | while read -r config; do
                if [[ -n "$config" ]]; then
                    sync_single_config "$config"
                fi
            done
        done
    else
        log_error "需要安装 fswatch 来使用监控模式"
        log_error "请运行: brew install fswatch"
        rm -f "/tmp/watch_files_$$"
        return 1
    fi
    
    rm -f "/tmp/watch_files_$$"
}

# 列出所有可用配置
list_configs() {
    log_header "可用的同步配置"
    
    local configs
    configs="$(get_config_list)"
    
    echo ""
    if [[ -n "$configs" ]]; then
        echo "$configs" | while read -r config; do
            if [[ -n "$config" ]]; then
                local description="$(get_config_description "$config")"
                local source_path="$(get_config_value "${config}_source")"
                local target_path="$(get_config_value "${config}_target")"
                
                echo "📋 $config"
                echo "   描述: $description"
                echo "   源文件: $source_path"
                echo "   目标: $target_path"
                echo ""
            fi
        done
    else
        echo "没有找到配置项"
    fi
}

# 显示帮助
show_help() {
    echo "通用多文件同步工具"
    echo ""
    echo "用法: $0 [命令] [配置名] [选项]"
    echo ""
    echo "命令:"
    echo "  status [配置名]       显示同步状态"
    echo "  sync [配置名]         智能双向同步"
    echo "  watch [配置名...]     监控模式，自动同步"
    echo "  list                  列出所有可用配置"
    echo "  help                  显示帮助信息"
    echo ""
    echo "选项:"
    echo "  --all                 操作所有配置"
    echo "  --force-to-target     强制同步到目标位置"
    echo "  --force-to-source     强制同步到源位置"
    echo ""
    echo "示例:"
    echo "  $0 status                    # 显示所有配置状态"
    echo "  $0 status vim_config         # 显示vim配置状态"
    echo "  $0 sync --all                # 同步所有配置"
    echo "  $0 sync vim_config           # 同步vim配置"
    echo "  $0 watch vim_config zsh_config  # 监控多个配置"
    echo "  $0 sync vim_config --force-to-target  # 强制同步方向"
}

# 主程序
main() {
    local command="${1:-status}"
    local config_name="$2"
    local force_direction="smart"
    local operate_all=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                operate_all=true
                shift
                ;;
            --force-to-target)
                force_direction="force-to-target"
                shift
                ;;
            --force-to-source)
                force_direction="force-to-source"
                shift
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # 检查依赖和加载配置
    if ! check_dependencies; then
        exit 1
    fi
    
    if ! load_config; then
        exit 1
    fi
    
    # Debug模式
    if [[ "$DEBUG" == "true" ]]; then
        echo "调试信息: 配置文件内容"
        cat "$SYNC_CONFIG_FILE"
        echo "调试信息: 描述文件内容"
        cat "$CONFIG_DESC_FILE"
    fi
    
    # 确保临时文件在退出时被清理
    trap 'rm -f "$SYNC_CONFIG_FILE" "$CONFIG_DESC_FILE" /tmp/watch_files_$$ 2>/dev/null' EXIT
    
    # 执行命令
    case "$command" in
        "status")
            if [[ "$operate_all" == "true" || -z "$config_name" ]]; then
                show_all_status
            else
                show_config_status "$config_name"
            fi
            ;;
        "sync")
            if [[ "$operate_all" == "true" ]]; then
                sync_all_configs "$force_direction"
            elif [[ -n "$config_name" ]]; then
                sync_single_config "$config_name" "$force_direction"
            else
                log_error "请指定配置名或使用 --all"
                exit 1
            fi
            ;;
        "watch")
            if [[ "$operate_all" == "true" ]]; then
                watch_mode
            else
                shift  # 移除command参数
                watch_mode "$@"
            fi
            ;;
        "list")
            list_configs
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@" 