#!/usr/bin/env python3
import sys
import csv
import pandas as pd


def convert_csv_to_xls(input_file, output_file=None):
    """
    将csv文件转换为xls格式
    :param input_file: 输入的csv文件路径
    :param output_file: 输出的xls文件路径，如果不指定则自动生成
    """
    if output_file is None:
        output_file = input_file.rsplit('.', 1)[0] + '.xlsx'

    # 读取CSV文件
    df = pd.read_csv(input_file, encoding='utf-8')
    
    # 保存为Excel文件
    df.to_excel(output_file, index=False)

    return output_file


def main():
    if len(sys.argv) < 2:
        print("使用方法: python csv2xls.py <输入文件.csv> [输出文件.xlsx]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        result = convert_csv_to_xls(input_file, output_file)
        print(f"转换完成！输出文件：{result}")
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
