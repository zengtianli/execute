#!/usr/bin/env python3
import os
import pandas as pd
import sys

def xlsx_to_txt(xlsx_file, txt_file):
    try:
        # 读取 Excel 文件中的所有工作表
        excel_file = pd.ExcelFile(xlsx_file)
        sheet_names = excel_file.sheet_names
        
        for sheet_name in sheet_names:
            # 读取当前工作表
            df = pd.read_excel(xlsx_file, sheet_name=sheet_name)
            
            # 为每个工作表创建单独的文本文件名
            base_name, ext = os.path.splitext(txt_file)
            if len(sheet_names) > 1:
                current_txt_file = f"{base_name}_{sheet_name}{ext}"
            else:
                current_txt_file = txt_file
            
            # 将数据框转换为制表符分隔的字符串
            text = df.to_csv(sep='\t', index=False)
            
            # 写入文本文件
            with open(current_txt_file, 'w', encoding='utf-8') as f:
                f.write(text)
            print(f"✓ 已转换: {xlsx_file} → {current_txt_file}")
        return True
    except Exception as e:
        print(f"✗ 转换失败 {xlsx_file}: {str(e)}", file=sys.stderr)
        return False

def convert_xlsx_in_directory(directory):
    success_count = 0
    fail_count = 0
    
    for root, dirs, files in os.walk(directory):
        xlsx_files = [f for f in files if f.endswith('.xlsx')]
        if not xlsx_files:
            continue
            
        print(f"📁 处理目录: {root}")
        for file in xlsx_files:
            xlsx_path = os.path.join(root, file)
            txt_path = os.path.join(root, file[:-5] + '.txt')
            
            if xlsx_to_txt(xlsx_path, txt_path):
                success_count += 1
            else:
                fail_count += 1
    
    if success_count > 0 or fail_count > 0:
        print(f"\n📊 统计:\n成功: {success_count} 个文件\n失败: {fail_count} 个文件")
    else:
        print("⚠️ 未找到任何 .xlsx 文件")

def main():
    if len(sys.argv) < 2:
        print("用法:")
        print("单个文件: python script.py file.xlsx")
        print("目录处理: python script.py -d directory_path")
        sys.exit(1)

    if sys.argv[1] == "-d":
        if len(sys.argv) < 3:
            directory = "."
        else:
            directory = sys.argv[2]
        convert_xlsx_in_directory(directory)
    else:
        xlsx_file = sys.argv[1]
        if not xlsx_file.endswith('.xlsx'):
            print("✗ 错误: 输入文件必须是 .xlsx 格式", file=sys.stderr)
            sys.exit(1)
        txt_file = xlsx_file[:-5] + '.txt'
        xlsx_to_txt(xlsx_file, txt_file)

if __name__ == "__main__":
    main()
