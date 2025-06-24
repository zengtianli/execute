#!/usr/bin/env python3
"""
CSV转Excel工具 - 将CSV文件转换为Excel格式
版本: 2.0.0
作者: tianli
更新: 2024-01-01
"""

import sys
import argparse
from pathlib import Path
from typing import Optional, List

# 引入通用工具模块
from common_utils import (
    show_success, show_error, show_warning, show_info, show_processing,
    validate_input_file, check_file_extension, get_file_basename,
    find_files_by_extension, ProgressTracker, fatal_error,
    check_python_packages, show_version_info, detect_file_encoding
)

# 脚本版本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"

def check_dependencies() -> bool:
    """检查依赖"""
    show_info("检查依赖项...")
    
    if not check_python_packages(['pandas', 'openpyxl']):
        return False
    
    show_success("依赖检查完成")
    return True

def convert_single_csv(input_file: Path, output_file: Optional[Path] = None) -> bool:
    """转换单个CSV文件"""
    try:
        import pandas as pd
        
        # 验证输入文件
        if not validate_input_file(input_file):
            return False
        
        # 检查文件扩展名
        if not check_file_extension(input_file, 'csv'):
            show_warning(f"跳过非CSV文件: {input_file.name}")
            return False
        
        # 确定输出文件
        if output_file is None:
            output_file = input_file.parent / f"{get_file_basename(input_file)}.xlsx"
        
        # 检查输出文件是否已存在
        if output_file.exists():
            show_warning(f"输出文件已存在，跳过: {output_file.name}")
            return False
        
        show_processing(f"转换: {input_file.name}")
        
        # 检测文件编码
        encoding = detect_file_encoding(input_file)
        
        # 读取CSV文件
        try:
            df = pd.read_csv(input_file, encoding=encoding)
        except UnicodeDecodeError:
            # 尝试其他编码
            for fallback_encoding in ['utf-8', 'gbk', 'gb2312']:
                try:
                    df = pd.read_csv(input_file, encoding=fallback_encoding)
                    show_warning(f"使用 {fallback_encoding} 编码读取: {input_file.name}")
                    break
                except UnicodeDecodeError:
                    continue
            else:
                show_error(f"无法读取CSV文件，编码问题: {input_file.name}")
                return False
        
        # 保存为Excel文件
        df.to_excel(output_file, index=False, engine='openpyxl')
        
        show_success(f"已转换: {input_file.name} -> {output_file.name}")
        return True
        
    except Exception as e:
        show_error(f"转换失败: {input_file.name} - {e}")
        return False

def convert_all_csv_files(directory: Path, recursive: bool = False) -> None:
    """批量转换目录中的所有CSV文件"""
    show_info(f"搜索CSV文件: {directory}")
    
    # 查找所有CSV文件
    csv_files = find_files_by_extension(directory, 'csv', recursive)
    
    if not csv_files:
        show_warning("未找到CSV文件")
        return
    
    show_info(f"找到 {len(csv_files)} 个CSV文件")
    
    # 初始化进度跟踪器
    tracker = ProgressTracker()
    
    # 转换每个文件
    for i, csv_file in enumerate(csv_files, 1):
        show_processing(f"处理 ({i}/{len(csv_files)}): {csv_file.name}")
        
        if convert_single_csv(csv_file):
            tracker.add_success()
        else:
            tracker.add_skip()
    
    # 显示转换统计
    tracker.show_summary("CSV转换")

def show_version() -> None:
    """显示版本信息"""
    show_version_info(SCRIPT_VERSION, SCRIPT_AUTHOR, SCRIPT_UPDATED)

def show_help() -> None:
    """显示帮助信息"""
    print("""
CSV转Excel工具 - 将CSV文件转换为Excel格式

用法:
    python3 csv2xls.py [选项] [输入文件] [输出文件]
    python3 csv2xls.py [选项] [目录]

参数:
    输入文件        要转换的CSV文件
    输出文件        输出的Excel文件名（可选）
    目录           要处理的目录（批量转换）

选项:
    -r, --recursive  递归处理子目录
    -h, --help       显示此帮助信息
    --version        显示版本信息

示例:
    python3 csv2xls.py data.csv              # 转换单个文件
    python3 csv2xls.py data.csv output.xlsx  # 指定输出文件名
    python3 csv2xls.py ./data_dir             # 批量转换目录
    python3 csv2xls.py -r ./data_dir          # 递归转换目录

依赖:
    - pandas
    - openpyxl
    """)

def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description='CSV转Excel工具 - 将CSV文件转换为Excel格式',
        add_help=False
    )
    
    parser.add_argument('input', nargs='?', help='输入CSV文件或目录')
    parser.add_argument('output', nargs='?', help='输出Excel文件（可选）')
    parser.add_argument('-r', '--recursive', action='store_true', help='递归处理子目录')
    parser.add_argument('-h', '--help', action='store_true', help='显示帮助信息')
    parser.add_argument('--version', action='store_true', help='显示版本信息')
    
    args = parser.parse_args()
    
    if args.help:
        show_help()
        return
    
    if args.version:
        show_version()
        return
    
    # 检查依赖
    if not check_dependencies():
        sys.exit(1)
    
    # 处理参数
    if not args.input:
        # 如果没有参数，处理当前目录
        convert_all_csv_files(Path.cwd())
    else:
        input_path = Path(args.input)
        
        if input_path.is_file():
            # 单文件转换
            output_path = None
            if args.output:
                output_path = Path(args.output)
            
            if convert_single_csv(input_path, output_path):
                show_success("转换完成")
            else:
                sys.exit(1)
        
        elif input_path.is_dir():
            # 目录转换
            if args.output:
                show_warning("目录转换模式下忽略输出文件参数")
            
            convert_all_csv_files(input_path, args.recursive)
        
        else:
            fatal_error(f"输入路径不存在: {input_path}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        show_warning("用户中断操作")
        sys.exit(1)
    except Exception as e:
        show_error(f"程序执行失败: {e}")
        sys.exit(1)
