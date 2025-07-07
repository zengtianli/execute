#!/usr/bin/env python3
"""
文件链接与监控工具 - 将文件链接到中央目录并监控其变化
版本: 2.0.0
作者: tianli
"""

import sys
import argparse
import time
from pathlib import Path

from common_utils import (
    show_success, show_error, show_warning, show_info,
    ensure_directory, fatal_error, check_python_packages
)

SCRIPT_VERSION = "2.0.0"

def check_dependencies():
    show_info("检查依赖项...")
    if not check_python_packages(['watchdog']):
        sys.exit(1)
    show_success("依赖检查完成")

def create_symlink(source_path: Path, link_path: Path):
    try:
        if link_path.exists() or link_path.is_symlink():
            show_warning(f"链接已存在，将重新创建: {link_path}")
            link_path.unlink()
        
        link_path.symlink_to(source_path.resolve())
        show_success(f"已创建链接: {source_path.name} -> {link_path}")
    except Exception as e:
        show_error(f"创建链接失败 {source_path.name}: {e}")

def link_files(source_dir: Path, central_dir: Path, file_ext: list):
    ensure_directory(central_dir)
    show_info(f"将 '{source_dir}' 中的 *.{file_ext} 文件链接到 '{central_dir}'")
    
    for ext in file_ext:
        for source_path in source_dir.rglob(f"*.{ext}"):
            link_path = central_dir / source_path.name
            create_symlink(source_path, link_path)

def watch_directory(source_dir: Path, central_dir: Path, file_ext: list):
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    class LinkerEventHandler(FileSystemEventHandler):
        def on_created(self, event):
            if not event.is_directory:
                source_path = Path(event.src_path)
                if source_path.suffix[1:] in file_ext:
                    link_path = central_dir / source_path.name
                    show_info(f"检测到新文件: {source_path.name}")
                    create_symlink(source_path, link_path)

        def on_deleted(self, event):
            if not event.is_directory:
                source_path = Path(event.src_path)
                link_path = central_dir / source_path.name
                if link_path.is_symlink():
                    show_info(f"源文件已删除，移除链接: {source_path.name}")
                    link_path.unlink()
    
    show_info(f"启动监控: '{source_dir}' (按 Ctrl+C 停止)")
    event_handler = LinkerEventHandler()
    observer = Observer()
    observer.schedule(event_handler, source_dir, recursive=True)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        show_info("监控已停止")
    observer.join()

def main():
    parser = argparse.ArgumentParser(description="文件链接与监控工具")
    parser.add_argument("source_dir", help="源目录")
    parser.add_argument("central_dir", help="中央链接目录")
    parser.add_argument("-e", "--ext", default="md,txt", help="要链接的文件扩展名 (逗号分隔)")
    parser.add_argument("-w", "--watch", action="store_true", help="链接后持续监控源目录")
    parser.add_argument('--version', action='version', version=f'%(prog)s {SCRIPT_VERSION}')
    args = parser.parse_args()

    check_dependencies()

    source_dir = Path(args.source_dir)
    central_dir = Path(args.central_dir)
    file_ext = [e.strip() for e in args.ext.split(',')]

    if not source_dir.is_dir():
        fatal_error(f"源目录不存在: {source_dir}")

    link_files(source_dir, central_dir, file_ext)

    if args.watch:
        watch_directory(source_dir, central_dir, file_ext)

if __name__ == "__main__":
    main()
