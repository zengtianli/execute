#!/usr/bin/env python3
import os
import pandas as pd
import sys

def txt_to_xlsx(txt_file, xlsx_file):
    try:
        # 读取制表符分隔的文本文件
        df = pd.read_csv(txt_file, sep='\t', encoding='utf-8')
        
        # 将数据框保存为 Excel 文件
        df.to_excel(xlsx_file, index=False)
        print(f"✓ 已转换: {txt_file} → {xlsx_file}")
        return True
    except Exception as e:
        print(f"✗ 转换失败 {txt_file}: {str(e)}", file=sys.stderr)
        return False

def convert_txt_in_directory(directory):
    success_count = 0
    fail_count = 0
    
    for root, dirs, files in os.walk(directory):
        txt_files = [f for f in files if f.endswith('.txt')]
        if not txt_files:
            continue
            
        print(f"📁 处理目录: {root}")
        for file in txt_files:
            txt_path = os.path.join(root, file)
            xlsx_path = os.path.join(root, file[:-4] + '.xlsx')
            
            if txt_to_xlsx(txt_path, xlsx_path):
                success_count += 1
            else:
                fail_count += 1
    
    if success_count > 0 or fail_count > 0:
        print(f"\n📊 统计:\n成功: {success_count} 个文件\n失败: {fail_count} 个文件")
    else:
        print("⚠️ 未找到任何 .txt 文件")

def main():
    if len(sys.argv) < 2:
        print("用法:")
        print("单个文件: python script.py file.txt")
        print("目录处理: python script.py -d directory_path")
        sys.exit(1)

    if sys.argv[1] == "-d":
        if len(sys.argv) < 3:
            directory = "."
        else:
            directory = sys.argv[2]
        convert_txt_in_directory(directory)
    else:
        txt_file = sys.argv[1]
        if not txt_file.endswith('.txt'):
            print("✗ 错误: 输入文件必须是 .txt 格式", file=sys.stderr)
            sys.exit(1)
        xlsx_file = txt_file[:-4] + '.xlsx'
        txt_to_xlsx(txt_file, xlsx_file)

if __name__ == "__main__":
    main()
