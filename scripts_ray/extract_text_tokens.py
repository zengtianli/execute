#!/usr/bin/env python3

"""
文本文件词元分析工具 - 提取、计数并分析文本文件中的词元
版本: 2.0.0
作者: tianli
"""

import sys
import argparse
import re
from pathlib import Path
from collections import Counter

from common_utils import (
    show_success, show_error, show_warning, show_info,
    validate_input_file, ensure_directory, ProgressTracker,
    fatal_error, find_files_by_extension
)

SCRIPT_VERSION = "2.0.0"
TOKEN_PATTERN = re.compile(r"[\w'-]+")

def analyze_file(file_path: Path, min_len: int, min_freq: int) -> list:
    if not validate_input_file(file_path):
        return []

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            text = f.read().lower()
        
        tokens = TOKEN_PATTERN.findall(text)
        
        token_counts = Counter(
            token for token in tokens
            if len(token) >= min_len
        )
        
        return [
            (token, count) for token, count in token_counts.items()
            if count >= min_freq
        ]
    except Exception as e:
        show_error(f"处理文件失败 {file_path.name}: {e}")
        return []

def save_results(results: list, output_file: Path):
    try:
        df = pd.DataFrame(results, columns=['Token', 'Frequency'])
        df.sort_values(by=['Frequency', 'Token'], ascending=[False, True], inplace=True)
        df.to_csv(output_file, index=False)
        show_success(f"结果已保存到: {output_file}")
    except Exception as e:
        fatal_error(f"保存结果失败: {e}")

def main():
    parser = argparse.ArgumentParser(
        description="文本文件词元分析工具",
        epilog="示例: a_script.py docs/ --min-len 3 -o results.csv"
    )
    parser.add_argument("input_paths", nargs='+', help="一个或多个文件/目录路径")
    parser.add_argument("-o", "--output", default="token_analysis.csv", help="输出CSV文件名")
    parser.add_argument("--min-len", type=int, default=1, help="最小词元长度")
    parser.add_argument("--min-freq", type=int, default=1, help="最小词元频率")
    parser.add_argument("-r", "--recursive", action="store_true", help="递归处理目录")
    parser.add_argument('--version', action='version', version=f'%(prog)s {SCRIPT_VERSION}')
    args = parser.parse_args()

    try:
        import pandas as pd
    except ImportError:
        fatal_error("此脚本需要 pandas 库。请运行: pip install pandas")

    files_to_process = find_files_by_extension(
        args.input_paths,
        ['txt', 'md'],
        recursive=args.recursive
    )

    if not files_to_process:
        show_warning("未找到任何支持的文本文件")
        sys.exit(0)
    
    show_info(f"找到 {len(files_to_process)} 个文件进行分析...")
    all_tokens = Counter()
    progress = ProgressTracker(len(files_to_process))

    for file_path in files_to_process:
        progress.show(f"分析 {file_path.name}")
        tokens = analyze_file(file_path, args.min_len, 1) # min_freq=1 for initial collection
        all_tokens.update(dict(tokens))

    final_results = [
        (token, count) for token, count in all_tokens.items()
        if count >= args.min_freq
    ]

    if not final_results:
        show_warning("未找到符合条件的词元")
        sys.exit(0)
        
    save_results(final_results, Path(args.output))

if __name__ == "__main__":
    # Add pandas to global scope for save_results
    try:
        import pandas as pd
    except ImportError:
        pass
    main()

