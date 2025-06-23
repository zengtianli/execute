#!/usr/bin/env python3
import sys
import csv
import re

def convert_txt_to_csv(input_file, output_file=None):
    """
    将txt文件转换为csv格式
    :param input_file: 输入的txt文件路径
    :param output_file: 输出的csv文件路径，如果不指定则自动生成
    """
    if output_file is None:
        output_file = input_file.rsplit('.', 1)[0] + '.csv'
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.readlines()
    
    # 处理每一行
    processed_lines = []
    for line in content:
        # 去除首尾空白字符
        line = line.strip()
        if not line:
            continue
            
        # 使用正则表达式替换连续的空白字符为单个逗号
        # 这会处理空格、制表符等
        line = re.sub(r'\s+', ',', line)
        processed_lines.append(line.split(','))
    
    # 写入CSV文件
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(processed_lines)
    
    return output_file

def main():
    if len(sys.argv) < 2:
        print("使用方法: python txt2csv.py <输入文件.txt> [输出文件.csv]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    try:
        output_path = convert_txt_to_csv(input_file, output_file)
        print(f"转换完成！输出文件：{output_path}")
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
