#!/bin/bash

# convert_all.sh - 文档格式转换综合工具
# 功能：
#   - doc -> docx -> md
#   - xls -> xlsx -> csv
#   - pptx -> md

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 使用环境变量定义脚本路径
SCRIPT_DIR="${SCRIPT_DIR:-/Users/tianli/useful_scripts}"
EXECUTE_DIR="${EXECUTE_DIR:-$SCRIPT_DIR/execute}"

# 定义各脚本的路径
DOC2DOCX_SCRIPT="${DOC2DOCX_SCRIPT:-$SCRIPT_DIR/doc2docx.sh}"
DOCX2MD_SCRIPT="${DOCX2MD_SCRIPT:-$EXECUTE_DIR/markitdown_docx2md.sh}"
PPTX2MD_SCRIPT="${PPTX2MD_SCRIPT:-$EXECUTE_DIR/pptx2md.py}"
XLS2XLSX_SCRIPT="${XLS2XLSX_SCRIPT:-$SCRIPT_DIR/xls2xlsx.sh}"
XLSX2CSV_SCRIPT="${XLSX2CSV_SCRIPT:-$EXECUTE_DIR/xlsx2csv.py}"

# 定义输出目录
OUTPUT_DIR="${OUTPUT_DIR:-./converted}"
MD_OUTPUT_DIR="$OUTPUT_DIR/md"
CSV_OUTPUT_DIR="$OUTPUT_DIR/csv"

# 创建输出目录
mkdir -p "$MD_OUTPUT_DIR" "$CSV_OUTPUT_DIR"

# 显示使用帮助
show_help() {
    cat << EOF
文档格式转换综合工具

用法: $0 [选项]

选项:
    -d, --doc      转换所有 .doc 文件为 .docx，然后转为 .md
    -x, --excel    转换所有 .xls 文件为 .xlsx，然后转为 .csv
    -p, --ppt      转换所有 .pptx 文件为 .md
    -a, --all      执行所有转换（doc、excel、ppt）
    -r, --recursive 递归处理子目录
    -v, --verbose   显示详细输出
    -h, --help      显示此帮助信息

单独转换选项:
    --doc-only     仅转换 doc 到 docx
    --docx-only    仅转换 docx 到 md
    --xls-only     仅转换 xls 到 xlsx
    --xlsx-only    仅转换 xlsx 到 csv
    
示例:
    $0 -a          # 转换当前目录下所有支持的文件
    $0 -a -r       # 递归转换所有子目录
    $0 -d -r       # 递归转换所有 doc 文件
    $0 -x          # 转换所有 Excel 文件
    
EOF
    exit 0
}

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 检查必要的工具和脚本
check_dependencies() {
    local missing_deps=0
    
    print_info "检查依赖项..."
    
    # 检查 Python
    if ! command -v python3 &> /dev/null; then
        print_error "未找到 python3"
        missing_deps=1
    fi
    
    # 检查 markitdown
    if ! command -v markitdown &> /dev/null; then
        print_warning "未找到 markitdown，请先安装：pip install markitdown"
        missing_deps=1
    fi
    
    # 检查各个转换脚本
    if [ ! -f "$DOC2DOCX_SCRIPT" ]; then
        print_warning "未找到脚本: $DOC2DOCX_SCRIPT"
        missing_deps=1
    else
        chmod +x "$DOC2DOCX_SCRIPT"
    fi
    
    if [ ! -f "$DOCX2MD_SCRIPT" ]; then
        print_warning "未找到脚本: $DOCX2MD_SCRIPT"
        missing_deps=1
    else
        chmod +x "$DOCX2MD_SCRIPT"
    fi
    
    if [ ! -f "$PPTX2MD_SCRIPT" ]; then
        print_warning "未找到脚本: $PPTX2MD_SCRIPT"
        missing_deps=1
    fi
    
    if [ ! -f "$XLS2XLSX_SCRIPT" ]; then
        print_warning "未找到脚本: $XLS2XLSX_SCRIPT"
        missing_deps=1
    else
        chmod +x "$XLS2XLSX_SCRIPT"
    fi
    
    if [ ! -f "$XLSX2CSV_SCRIPT" ]; then
        print_warning "未找到脚本: $XLSX2CSV_SCRIPT"
        missing_deps=1
    fi
    
    # 检查 Microsoft Office 应用
    if ! osascript -e 'tell application "Microsoft Word" to name' &> /dev/null; then
        print_warning "未找到 Microsoft Word，doc 转换功能将不可用"
    fi
    
    if ! osascript -e 'tell application "Microsoft Excel" to name' &> /dev/null; then
        print_warning "未找到 Microsoft Excel，xls 转换功能将不可用"
    fi
    
    if [ $missing_deps -eq 1 ]; then
        print_error "缺少必要的依赖项，请先解决上述问题"
        exit 1
    fi
    
    print_success "依赖检查完成"
}

# 转换 doc 文件
convert_doc_files() {
    print_info "开始处理 Word 文档..."
    
    # 第一步：doc -> docx
    if [ "$DOC_ONLY" = true ] || [ "$DOC_ONLY" != true ] && [ "$DOCX_ONLY" != true ]; then
        print_info "转换 .doc 到 .docx ..."
        if [ "$RECURSIVE" = true ]; then
            "$DOC2DOCX_SCRIPT" -r
            # 根据转换数量估计计数
            found_count=$(find . -name "*.doc" -not -name "*.docx" -type f 2>/dev/null | wc -l)
            CONVERT_COUNT_DOC_TO_DOCX=$((CONVERT_COUNT_DOC_TO_DOCX + found_count))
        else
            "$DOC2DOCX_SCRIPT"
            # 根据转换数量估计计数
            found_count=$(ls -1 *.doc 2>/dev/null | grep -v "\.docx$" | wc -l)
            CONVERT_COUNT_DOC_TO_DOCX=$((CONVERT_COUNT_DOC_TO_DOCX + found_count))
        fi
    fi
    
    # 第二步：docx -> md
    if [ "$DOCX_ONLY" = true ] || [ "$DOC_ONLY" != true ] && [ "$DOCX_ONLY" != true ]; then
        print_info "转换 .docx 到 .md ..."
        # 递归处理所有docx文件
        if [ "$RECURSIVE" = true ]; then
            find . -name "*.docx" -type f | while read -r file; do
                print_info "  处理: $file"
                output_file="$MD_OUTPUT_DIR/$(basename "${file%.*}").md"
                "$DOCX2MD_SCRIPT" "$file" > "$output_file"
                print_success "  已生成: $output_file"
                # 增加转换计数
                ((CONVERT_COUNT_DOCX_TO_MD++))
            done
        else
            for file in *.docx; do
                if [ -f "$file" ]; then
                    print_info "  处理: $file"
                    output_file="$MD_OUTPUT_DIR/$(basename "${file%.*}").md"
                    "$DOCX2MD_SCRIPT" "$file" > "$output_file"
                    print_success "  已生成: $output_file"
                    # 增加转换计数
                    ((CONVERT_COUNT_DOCX_TO_MD++))
                fi
            done
        fi
    fi
    
    print_success "Word 文档处理完成"
}

# 转换 Excel 文件
convert_excel_files() {
    print_info "开始处理 Excel 文档..."
    
    # 第一步：xls -> xlsx
    if [ "$XLS_ONLY" = true ] || [ "$XLS_ONLY" != true ] && [ "$XLSX_ONLY" != true ]; then
        print_info "转换 .xls 到 .xlsx ..."
        if [ "$RECURSIVE" = true ]; then
            "$XLS2XLSX_SCRIPT" -r
            # 根据转换数量估计计数
            found_count=$(find . -name "*.xls" -not -name "*.xlsx" -type f 2>/dev/null | wc -l)
            CONVERT_COUNT_XLS_TO_XLSX=$((CONVERT_COUNT_XLS_TO_XLSX + found_count))
        else
            "$XLS2XLSX_SCRIPT"
            # 根据转换数量估计计数
            found_count=$(ls -1 *.xls 2>/dev/null | grep -v "\.xlsx$" | wc -l)
            CONVERT_COUNT_XLS_TO_XLSX=$((CONVERT_COUNT_XLS_TO_XLSX + found_count))
        fi
    fi
    
    # 第二步：xlsx -> csv
    if [ "$XLSX_ONLY" = true ] || [ "$XLS_ONLY" != true ] && [ "$XLSX_ONLY" != true ]; then
        print_info "转换 .xlsx 到 .csv ..."
        # 找出所有xlsx文件并转换
        if [ "$RECURSIVE" = true ]; then
            find . -name "*.xlsx" -type f | while read -r file; do
                print_info "  处理: $file"
                base_name=$(basename "${file%.*}")
                # 尝试直接使用-o输出到指定路径
                if python3 "$XLSX2CSV_SCRIPT" -o "$CSV_OUTPUT_DIR/$base_name.csv" "$file"; then
                    print_success "  转换完成：$file [默认工作表] -> $CSV_OUTPUT_DIR/$base_name.csv"
                    # 增加转换计数
                    ((CONVERT_COUNT_XLSX_TO_CSV++))
                else
                    # 如果失败，尝试使用-a参数转换所有工作表
                    python3 "$XLSX2CSV_SCRIPT" -a "$file"
                    
                    # 计数所有生成的csv文件
                    found_csv=false
                    for csv_file in "${file%.*}"_*.csv; do
                        if [ -f "$csv_file" ]; then
                            found_csv=true
                            mv "$csv_file" "$CSV_OUTPUT_DIR/"
                            print_success "  已移动: $(basename "$csv_file") 到 $CSV_OUTPUT_DIR/"
                            # 增加转换计数
                            ((CONVERT_COUNT_XLSX_TO_CSV++))
                        fi
                    done
                    
                    # 如果没有找到csv文件，可能是转换失败
                    if [ "$found_csv" = false ]; then
                        print_warning "  转换失败: $file"
                    fi
                fi
            done
        else
            for file in *.xlsx; do
                if [ -f "$file" ]; then
                    print_info "  处理: $file"
                    base_name=$(basename "${file%.*}")
                    # 尝试直接使用-o输出到指定路径
                    if python3 "$XLSX2CSV_SCRIPT" -o "$CSV_OUTPUT_DIR/$base_name.csv" "$file"; then
                        print_success "  转换完成：$file [默认工作表] -> $CSV_OUTPUT_DIR/$base_name.csv"
                        # 增加转换计数
                        ((CONVERT_COUNT_XLSX_TO_CSV++))
                    else
                        # 如果失败，尝试使用-a参数转换所有工作表
                        python3 "$XLSX2CSV_SCRIPT" -a "$file"
                        
                        # 计数所有生成的csv文件
                        found_csv=false
                        for csv_file in "${file%.*}"_*.csv; do
                            if [ -f "$csv_file" ]; then
                                found_csv=true
                                mv "$csv_file" "$CSV_OUTPUT_DIR/"
                                print_success "  已移动: $(basename "$csv_file") 到 $CSV_OUTPUT_DIR/"
                                # 增加转换计数
                                ((CONVERT_COUNT_XLSX_TO_CSV++))
                            fi
                        done
                        
                        # 如果没有找到csv文件，可能是转换失败
                        if [ "$found_csv" = false ]; then
                            print_warning "  转换失败: $file"
                        fi
                    fi
                fi
            done
        fi
    fi
    
    print_success "Excel 文档处理完成"
}

# 转换 PowerPoint 文件
convert_ppt_files() {
    print_info "开始处理 PowerPoint 文档..."
    
    # 查找所有 pptx 文件
    if [ "$RECURSIVE" = true ]; then
        find . -name "*.pptx" -type f | while read -r file; do
            print_info "转换: $file"
            base_name=$(basename "${file%.*}")
            file_dir=$(dirname "$file")
            
            # 先用pptx2md脚本转换文件
            if [ "$VERBOSE" = true ]; then
                python3 "$PPTX2MD_SCRIPT" "$file" -v
            else
                python3 "$PPTX2MD_SCRIPT" "$file"
            fi
            
            # 增加转换计数
            ((CONVERT_COUNT_PPTX_TO_MD++))
            
            # 检查是否生成了同名文件夹
            gen_folder="$file_dir/$base_name"
            if [ -d "$gen_folder" ]; then
                # 移动生成的文件夹到目标位置
                mkdir -p "$MD_OUTPUT_DIR"
                if [ -d "$MD_OUTPUT_DIR/$base_name" ]; then
                    # 如果目标位置已存在同名文件夹，先删除
                    rm -rf "$MD_OUTPUT_DIR/$base_name"
                fi
                mv "$gen_folder" "$MD_OUTPUT_DIR/"
                print_success "  已移动文件夹: $base_name 到 $MD_OUTPUT_DIR/"
            else
                print_warning "  未找到生成的文件夹: $gen_folder"
            fi
        done
    else
        for file in *.pptx; do
            if [ -f "$file" ]; then
                print_info "转换: $file"
                base_name=$(basename "${file%.*}")
                
                # 先用pptx2md脚本转换文件
                if [ "$VERBOSE" = true ]; then
                    python3 "$PPTX2MD_SCRIPT" "$file" -v
                else
                    python3 "$PPTX2MD_SCRIPT" "$file"
                fi
                
                # 增加转换计数
                ((CONVERT_COUNT_PPTX_TO_MD++))
                
                # 检查是否生成了同名文件夹
                if [ -d "$base_name" ]; then
                    # 移动生成的文件夹到目标位置
                    mkdir -p "$MD_OUTPUT_DIR"
                    if [ -d "$MD_OUTPUT_DIR/$base_name" ]; then
                        # 如果目标位置已存在同名文件夹，先删除
                        rm -rf "$MD_OUTPUT_DIR/$base_name"
                    fi
                    mv "$base_name" "$MD_OUTPUT_DIR/"
                    print_success "  已移动文件夹: $base_name 到 $MD_OUTPUT_DIR/"
                else
                    print_warning "  未找到生成的文件夹: $base_name"
                fi
            fi
        done
    fi
    
    print_success "PowerPoint 文档处理完成"
}

# 统计文件数量
count_files() {
    local doc_count=0
    local docx_count=0
    local xls_count=0
    local xlsx_count=0
    local pptx_count=0
    
    if [ "$RECURSIVE" = true ]; then
        doc_count=$(find . -name "*.doc" -not -name "*.docx" -type f 2>/dev/null | wc -l)
        docx_count=$(find . -name "*.docx" -type f 2>/dev/null | wc -l)
        xls_count=$(find . -name "*.xls" -not -name "*.xlsx" -type f 2>/dev/null | wc -l)
        xlsx_count=$(find . -name "*.xlsx" -type f 2>/dev/null | wc -l)
        pptx_count=$(find . -name "*.pptx" -type f 2>/dev/null | wc -l)
    else
        doc_count=$(ls *.doc 2>/dev/null | grep -v "\.docx$" | wc -l)
        docx_count=$(ls *.docx 2>/dev/null | wc -l)
        xls_count=$(ls *.xls 2>/dev/null | grep -v "\.xlsx$" | wc -l)
        xlsx_count=$(ls *.xlsx 2>/dev/null | wc -l)
        pptx_count=$(ls *.pptx 2>/dev/null | wc -l)
    fi
    
    echo -e "\n${BLUE}文件统计:${NC}"
    echo "  .doc 文件:  $doc_count"
    echo "  .docx 文件: $docx_count"
    echo "  .xls 文件:  $xls_count"
    echo "  .xlsx 文件: $xlsx_count"
    echo "  .pptx 文件: $pptx_count"
    local total_count=$((doc_count + docx_count + xls_count + xlsx_count + pptx_count))
    echo "  需要转换的文件总数: $total_count"
    echo ""
}

# 转换统计
CONVERT_COUNT_DOC_TO_DOCX=0
CONVERT_COUNT_XLS_TO_XLSX=0
CONVERT_COUNT_DOCX_TO_MD=0
CONVERT_COUNT_XLSX_TO_CSV=0
CONVERT_COUNT_PPTX_TO_MD=0

# 显示转换统计
show_conversion_stats() {
    echo -e "\n${BLUE}转换统计:${NC}"
    echo "  doc -> docx: $CONVERT_COUNT_DOC_TO_DOCX"
    echo "  xls -> xlsx: $CONVERT_COUNT_XLS_TO_XLSX"
    echo "  docx -> md:  $CONVERT_COUNT_DOCX_TO_MD"
    echo "  xlsx -> csv: $CONVERT_COUNT_XLSX_TO_CSV"
    echo "  pptx -> md:  $CONVERT_COUNT_PPTX_TO_MD"
    # 计算md和csv转换总数
    local total_md_csv=$((CONVERT_COUNT_DOCX_TO_MD + CONVERT_COUNT_XLSX_TO_CSV + CONVERT_COUNT_PPTX_TO_MD))
    echo "  converted md and csv: $total_md_csv"
    echo ""
}

# 主程序
main() {
    # 默认值
    CONVERT_DOC=false
    CONVERT_EXCEL=false
    CONVERT_PPT=false
    CONVERT_ALL=false
    RECURSIVE=false
    VERBOSE=false
    DOC_ONLY=false
    DOCX_ONLY=false
    XLS_ONLY=false
    XLSX_ONLY=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--doc)
                CONVERT_DOC=true
                shift
                ;;
            -x|--excel)
                CONVERT_EXCEL=true
                shift
                ;;
            -p|--ppt)
                CONVERT_PPT=true
                shift
                ;;
            -a|--all)
                CONVERT_ALL=true
                shift
                ;;
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --doc-only)
                DOC_ONLY=true
                CONVERT_DOC=true
                shift
                ;;
            --docx-only)
                DOCX_ONLY=true
                CONVERT_DOC=true
                shift
                ;;
            --xls-only)
                XLS_ONLY=true
                CONVERT_EXCEL=true
                shift
                ;;
            --xlsx-only)
                XLSX_ONLY=true
                CONVERT_EXCEL=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "未知选项: $1"
                show_help
                ;;
        esac
    done
    
    # 如果没有指定任何转换选项，显示帮助
    if [ "$CONVERT_DOC" = false ] && [ "$CONVERT_EXCEL" = false ] && [ "$CONVERT_PPT" = false ] && [ "$CONVERT_ALL" = false ]; then
        print_warning "未指定任何转换选项"
        show_help
    fi
    
    # 检查依赖
    check_dependencies
    
    # 显示文件统计
    count_files
    
    # 如果选择了全部转换
    if [ "$CONVERT_ALL" = true ]; then
        CONVERT_DOC=true
        CONVERT_EXCEL=true
        CONVERT_PPT=true
    fi
    
    # 记录开始时间
    start_time=$(date +%s)
    
    # 执行转换
    if [ "$CONVERT_DOC" = true ]; then
        convert_doc_files
    fi
    
    if [ "$CONVERT_EXCEL" = true ]; then
        convert_excel_files
    fi
    
    if [ "$CONVERT_PPT" = true ]; then
        convert_ppt_files
    fi
    
    # 计算耗时
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo -e "\n${GREEN}=== 转换完成 ===${NC}"
    echo "总耗时: ${duration} 秒"
    
    # 再次显示文件统计，查看转换结果
    if [ "$VERBOSE" = true ]; then
        count_files
    fi
    
    show_conversion_stats
}

# 运行主程序
main "$@"
