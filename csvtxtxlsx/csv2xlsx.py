#!/usr/bin/env python3
import sys
import csv
from openpyxl import Workbook


def convert_csv_to_xlsx(input_file, output_file=None):
    """
    将csv文件转换为xlsx格式
    :param input_file: 输入的csv文件路径
    :param output_file: 输出的xlsx文件路径，如果不指定则自动生成
    """
    if output_file is None:
        output_file = input_file.rsplit('.', 1)[0] + '.xlsx'
    
    wb = Workbook()
    ws = wb.active
    
    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            ws.append(row)
    
    wb.save(output_file)
    return output_file


def main():
    if len(sys.argv) < 2:
        print("使用方法: python csv2xlsx.py <输入文件.csv> [输出文件.xlsx]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    try:
        result = convert_csv_to_xlsx(input_file, output_file)
        print(f"转换完成！输出文件：{result}")
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
