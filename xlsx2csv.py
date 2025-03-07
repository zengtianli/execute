#!/usr/bin/env python3
import sys
import csv
from openpyxl import load_workbook


def convert_xlsx_to_csv(input_file, output_file=None):
    """
    将xlsx文件转换为csv格式
    :param input_file: 输入的xlsx文件路径
    :param output_file: 输出的csv文件路径，如果不指定则自动生成
    """
    if output_file is None:
        output_file = input_file.rsplit('.', 1)[0] + '.csv'

    wb = load_workbook(input_file, read_only=True, data_only=True)
    ws = wb.active

    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for row in ws.iter_rows(values_only=True):
            # 将None转换为空字符串，并转换所有非None的单元格值为字符串
            writer.writerow(['' if cell is None else str(cell) for cell in row])

    return output_file


def main():
    if len(sys.argv) < 2:
        print("使用方法: python xlsx2csv.py <输入文件.xlsx> [输出文件.csv]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        result = convert_xlsx_to_csv(input_file, output_file)
        print(f"转换完成！输出文件：{result}")
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
