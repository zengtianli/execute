#!/usr/bin/env python3
import sys
import csv
import os
import glob
from openpyxl import load_workbook


def convert_xlsx_to_csv(input_file, output_file=None):
    """
    将xlsx文件转换为csv格式
    :param input_file: 输入的xlsx文件路径
    :param output_file: 输出的csv文件路径，如果不指定则自动生成
    """
    if output_file is None:
        output_file = input_file.rsplit('.', 1)[0] + '.csv'

    try:
        wb = load_workbook(input_file, read_only=True, data_only=True)
        ws = wb.active

        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            for row in ws.iter_rows(values_only=True):
                # 将None转换为空字符串，并转换所有非None的单元格值为字符串
                writer.writerow(['' if cell is None else str(cell) for cell in row])

        print(f"转换完成：{input_file} -> {output_file}")
        return output_file
    except Exception as e:
        print(f"转换 {input_file} 时出错：{str(e)}")
        return None


def convert_all_xlsx_to_csv(directory=".", recursive=False):
    """
    转换指定目录下的所有xlsx文件为csv
    :param directory: 要处理的目录
    :param recursive: 是否递归处理子目录
    """
    # 确保目录路径以斜杠结尾
    if not directory.endswith(os.sep):
        directory += os.sep

    # 搜索模式
    pattern = "**/*.xlsx" if recursive else "*.xlsx"
    success_count = 0
    total_count = 0
    
    # 查找所有xlsx文件
    for xlsx_file in glob.glob(directory + pattern, recursive=recursive):
        total_count += 1
        if convert_xlsx_to_csv(xlsx_file) is not None:
            success_count += 1
    
    # 输出统计信息
    if total_count == 0:
        print(f"在 {directory} {'及其子目录' if recursive else ''} 中未找到xlsx文件")
    else:
        print(f"共处理 {total_count} 个文件，成功转换 {success_count} 个")


def main():
    import argparse
    
    # 创建命令行参数解析器
    parser = argparse.ArgumentParser(description="将xlsx文件转换为csv格式")
    parser.add_argument("path", nargs="?", default=".", help="要处理的文件或目录路径，默认为当前目录")
    parser.add_argument("-r", "--recursive", action="store_true", help="递归处理子目录")
    parser.add_argument("-o", "--output", help="指定输出文件名（仅对单个文件有效）")
    
    args = parser.parse_args()
    
    # 检查路径是文件还是目录
    if os.path.isfile(args.path):
        # 如果是单个文件
        if not args.path.lower().endswith('.xlsx'):
            print("错误：输入文件必须是xlsx格式")
            sys.exit(1)
        try:
            convert_xlsx_to_csv(args.path, args.output)
        except Exception as e:
            print(f"转换过程中出错：{str(e)}")
            sys.exit(1)
    else:
        # 如果是目录
        convert_all_xlsx_to_csv(args.path, args.recursive)


if __name__ == "__main__":
    main()
