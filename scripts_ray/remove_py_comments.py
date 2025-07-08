#!/usr/bin/env python3
"""
移除Python代码中的注释、文档字符串和空行，并使代码紧凑。
"""
import tokenize
import io
import sys
from pathlib import Path

# 假设 common_utils.py 在同一目录下
from common_utils import (
    show_success, show_error, show_info, show_processing, show_warning,
    find_files_by_extension, fatal_error, ProgressTracker,
    show_version_info, show_help_header, show_help_footer
)

SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-07-25"

def show_version():
    """显示版本信息"""
    show_version_info(SCRIPT_VERSION, SCRIPT_AUTHOR, SCRIPT_UPDATED)

def show_help():
    """显示帮助信息"""
    show_help_header(sys.argv[0], "移除Python代码中的注释、文档字符串和空行")
    print("    <file_or_dir>    要处理的Python文件或目录")
    print("    -r, --recursive  递归处理子目录中的Python文件")
    show_help_footer()

def remove_comments_and_docstrings(source: str) -> str:
    """
    返回移除了注释、文档字符串和空行的代码，尽量保留原始格式并减少代码行数。
    """
    io_obj = io.StringIO(source)
    out = ''
    prev_toktype = tokenize.INDENT
    last_col = 0
    last_lineno = -1
    try:
        tokgen = tokenize.generate_tokens(io_obj.readline)
        for tok in tokgen:
            token_type, token_string, (start_line, start_col), (end_line, end_col), ltext = tok
            if start_line > last_lineno:
                last_col = 0
            if start_col > last_col:
                out += ' ' * (start_col - last_col)
            if token_type == tokenize.COMMENT:
                pass
            elif token_type == tokenize.STRING:
                if prev_toktype != tokenize.INDENT and prev_toktype != tokenize.NEWLINE and prev_toktype != tokenize.DEDENT:
                    out += token_string
            else:
                out += token_string
            prev_toktype = token_type
            last_col = end_col
            last_lineno = end_line
    except tokenize.TokenError as e:
        show_warning(f"处理文件时发生TokenError: {e}")
        return source # 返回原始内容

    lines = out.split('\\n')
    non_empty_lines = [line.rstrip() for line in lines if line.strip()]
    return '\\n'.join(non_empty_lines)

def process_file(file_path: Path, tracker: ProgressTracker):
    """处理单个Python文件"""
    show_processing(f"处理: {file_path.name}")
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            source = f.read()
        
        cleaned_source = remove_comments_and_docstrings(source)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(cleaned_source)
        
        show_success(f"已清理: {file_path.name}")
        tracker.add_success()
    except Exception as e:
        show_error(f"处理文件失败 {file_path.name}: {e}")
        tracker.add_failure()

def main():
    """主函数"""
    recursive = False
    targets = []
    
    args = sys.argv[1:]
    if not args:
        targets.append(".")
    
    for arg in args:
        if arg in ("-h", "--help"):
            show_help()
            sys.exit(0)
        if arg == "--version":
            show_version()
            sys.exit(0)
        if arg in ("-r", "-R", "--recursive"):
            recursive = True
        elif arg.startswith("-"):
            show_error(f"未知选项: {arg}")
            show_help()
            sys.exit(1)
        else:
            targets.append(arg)

    if not targets:
        targets.append(".")
            
    files_to_process = []
    for target in targets:
        path = Path(target)
        if not path.exists():
            show_warning(f"路径不存在，跳过: {path}")
            continue
        if path.is_file() and path.suffix == '.py':
            files_to_process.append(path)
        elif path.is_dir():
            files_to_process.extend(find_files_by_extension(path, "py", recursive))
    
    if not files_to_process:
        show_info("未找到要处理的Python文件。")
        return

    tracker = ProgressTracker()
    show_info(f"找到 {len(files_to_process)} 个Python文件进行处理...")

    for file_path in files_to_process:
        process_file(file_path, tracker)
    
    tracker.show_summary("Python文件清理")

if __name__ == "__main__":
    main() 