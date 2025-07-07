#!/usr/bin/env python3
"""
Excel工作表分离工具 - 将单个Excel文件按工作表拆分为多个文件
版本: 2.0.0
作者: tianli
更新: 2024-01-05
"""

import sys
import argparse
import pandas as pd
from pathlib import Path

from common_utils import (
    show_success, show_error, show_warning, show_info, show_processing,
    validate_input_file, check_file_extension, get_file_basename,
    fatal_error, check_python_packages, show_version_info
)

SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-05"

def check_dependencies() -> bool:
    show_info("检查依赖项...")
    if not check_python_packages(['pandas', 'openpyxl']):
        return False
    show_success("依赖检查完成")
    return True

def split_excel_file(input_file: Path) -> bool:
    try:
        if not validate_input_file(input_file):
            return False

        if not check_file_extension(input_file, 'xlsx'):
            show_warning(f"跳过非XLSX文件: {input_file.name}")
            return False

        show_processing(f"正在读取Excel文件: {input_file.name}")
        xlsx = pd.ExcelFile(input_file)
        sheet_names = xlsx.sheet_names

        if not sheet_names:
            show_warning(f"文件 '{input_file.name}' 中没有找到工作表。")
            return True

        show_info(f"找到 {len(sheet_names)} 个工作表: {', '.join(sheet_names)}")
        
        base_name = get_file_basename(input_file)
        output_dir = input_file.parent
        
        for i, sheet_name in enumerate(sheet_names, 1):
            show_processing(f"正在处理工作表 ({i}/{len(sheet_names)}): {sheet_name}")
            df = pd.read_excel(xlsx, sheet_name=sheet_name)
            
            output_file = output_dir / f"{base_name}_{sheet_name}.xlsx"
            
            df.to_excel(output_file, index=False)
            show_success(f"已保存工作表 '{sheet_name}' 到 '{output_file.name}'")

        return True

    except Exception as e:
        show_error(f"处理文件 '{input_file.name}' 时发生错误: {e}")
        return False

def show_version() -> None:
    show_version_info(SCRIPT_VERSION, SCRIPT_AUTHOR, SCRIPT_UPDATED)

def show_help() -> None:
    print(f"""
Excel工作表分离工具 - 将单个Excel文件按工作表拆分为多个文件

用法:
    python3 {sys.argv[0]} [选项] <输入文件>

参数:
    输入文件         要拆分的Excel文件 (.xlsx)

选项:
    -h, --help       显示此帮助信息
    --version        显示版本信息

示例:
    python3 {sys.argv[0]} data.xlsx

功能:
    - 将一个包含多个工作表的Excel文件拆分为多个单独的Excel文件
    - 每个新文件以原文件名和工作表名命名

依赖:
    - pandas
    - openpyxl
    """)

def main():
    parser = argparse.ArgumentParser(
        description='Excel工作表分离工具',
        add_help=False
    )
    
    parser.add_argument('input_file', nargs='?', help='要拆分的Excel文件')
    parser.add_argument('-h', '--help', action='store_true', help='显示帮助信息')
    parser.add_argument('--version', action='store_true', help='显示版本信息')
    
    args = parser.parse_args()

    if args.help:
        show_help()
        return
    
    if args.version:
        show_version()
        return

    if not args.input_file:
        show_help()
        fatal_error("错误: 未提供输入文件。")

    if not check_dependencies():
        sys.exit(1)
    
    input_path = Path(args.input_file)
    
    if not split_excel_file(input_path):
        sys.exit(1)

    show_success("所有操作完成。")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        show_warning("用户中断操作")
        sys.exit(1)
    except Exception as e:
        fatal_error(f"程序执行失败: {e}")
