#!/usr/bin/env python3
import sys
import csv
def convert_csv_to_txt(input_file, output_file=None):
    """将csv文件转换为txt格式"""
    output_file = output_file or input_file.rsplit('.', 1)[0] + '.txt'
    with open(input_file, 'r', encoding='utf-8') as f_in, \
         open(output_file, 'w', encoding='utf-8') as f_out:
        reader = csv.reader(f_in)
        for row in reader:
            f_out.write('\t'.join(row) + '\n')
    return output_file
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("使用方法: python csv2txt.py <输入文件.csv> [输出文件.txt]")
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    try:
        result = convert_csv_to_txt(input_file, output_file)
        print(f"转换完成！输出文件：{result}")
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        sys.exit(1)
