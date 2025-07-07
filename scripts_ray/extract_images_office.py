#!/usr/bin/env python3

"""
Office文件图片提取工具 - 从.docx, .pptx, .xlsx文件中提取所有图片
版本: 2.0.0
作者: tianli
"""

import sys
import zipfile
import argparse
from pathlib import Path

from common_utils import (
    show_success, show_error, show_warning, show_info,
    validate_input_file, ensure_directory, ProgressTracker,
    fatal_error, show_version_info, find_files_by_extension
)

SCRIPT_VERSION = "2.0.0"

def extract_images_from_file(file_path: Path, output_dir: Path) -> int:
    if not validate_input_file(file_path):
        return 0

    supported_extensions = ['.docx', '.pptx', '.xlsx']
    if file_path.suffix not in supported_extensions:
        show_warning(f"跳过不支持的文件类型: {file_path.name}")
        return 0

    try:
        with zipfile.ZipFile(file_path, 'r') as archive:
            image_files = [
                f for f in archive.namelist()
                if f.startswith('word/media/') or f.startswith('ppt/media/') or f.startswith('xl/media/')
            ]
            
            if not image_files:
                show_info(f"在 {file_path.name} 中未找到图片")
                return 0

            file_output_dir = output_dir / file_path.stem
            ensure_directory(file_output_dir)
            
            show_processing(f"从 {file_path.name} 提取 {len(image_files)} 张图片...")
            
            count = 0
            for image_file in image_files:
                archive.extract(image_file, file_output_dir)
                count += 1
            
            show_success(f"成功提取 {count} 张图片到 {file_output_dir}")
            return count

    except zipfile.BadZipFile:
        show_error(f"文件损坏或格式不正确: {file_path.name}")
        return 0
    except Exception as e:
        show_error(f"处理 {file_path.name} 时发生错误: {e}")
        return 0

def main():
    parser = argparse.ArgumentParser(
        description="Office文件图片提取工具",
        epilog="示例: a_script.py file.docx -o ./output --recursive"
    )
    parser.add_argument("input_paths", nargs='+', help="一个或多个文件/目录路径")
    parser.add_argument("-o", "--output", help="输出目录 (默认: ./extracted_images)")
    parser.add_argument("-r", "--recursive", action="store_true", help="递归处理目录")
    parser.add_argument('--version', action='version', version=f'%(prog)s {SCRIPT_VERSION}')
    
    args = parser.parse_args()

    if args.output:
        output_dir = Path(args.output)
    else:
        # 如果处理的是单个文件，则在文件同级目录创建文件夹
        first_path = Path(args.input_paths[0])
        if len(args.input_paths) == 1 and first_path.is_file():
            output_dir = first_path.parent
        else:
            output_dir = Path("./extracted_images")

    ensure_directory(output_dir)
    show_info(f"输出目录: {output_dir.resolve()}")
    
    files_to_process = find_files_by_extension(
        args.input_paths,
        ['docx', 'pptx', 'xlsx'],
        recursive=args.recursive
    )

    if not files_to_process:
        show_warning("未找到任何支持的Office文件")
        sys.exit(0)

    total_extracted = 0
    progress = ProgressTracker(len(files_to_process))
    
    for file_path in files_to_process:
        progress.show(f"处理 {file_path.name}")
        count = extract_images_from_file(file_path, output_dir)
        total_extracted += count

    show_info("\n处理完成")
    show_success(f"总共提取了 {total_extracted} 张图片")

if __name__ == "__main__":
    main()
