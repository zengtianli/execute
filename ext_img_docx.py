#!/usr/bin/env python3
from docx import Document
import os
from pathlib import Path

def extract_images_from_docx(docx_path, output_dir):
    """从 DOCX 文件中提取所有图片"""
    try:
        doc = Document(docx_path)
        
        # 创建输出目录
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        # 获取文件名（不含扩展名）
        base_name = os.path.splitext(os.path.basename(docx_path))[0]
        
        # 提取图片
        img_count = 0
        for i, rel in enumerate(doc.part.rels.values()):
            if "image" in rel.target_ref:
                img = rel.target_part.blob
                img_count += 1
                
                # 获取图片扩展名
                ext = rel.target_ref.split('.')[-1]
                if ext not in ['png', 'jpg', 'jpeg', 'gif', 'bmp']:
                    ext = 'png'  # 默认使用 png
                
                img_name = f"{base_name}_img_{img_count}.{ext}"
                img_path = os.path.join(output_dir, img_name)
                
                with open(img_path, "wb") as f:
                    f.write(img)
                
                print(f"  已保存: {img_path}")
        
        if img_count == 0:
            print(f"  未找到图片")
            # 如果没有图片，删除空文件夹
            if os.path.exists(output_dir) and not os.listdir(output_dir):
                os.rmdir(output_dir)
        else:
            print(f"  共提取 {img_count} 张图片")
                
    except Exception as e:
        print(f"  处理出错: {e}")

def main():
    """主函数：处理当前目录下所有的 DOCX 文件"""
    current_dir = Path.cwd()
    docx_files = list(current_dir.glob("*.docx"))
    
    if not docx_files:
        print("当前目录未找到 DOCX 文件")
        return
    
    print(f"找到 {len(docx_files)} 个 DOCX 文件\n")
    
    for docx_file in docx_files:
        # 跳过临时文件（以~$开头的）
        if docx_file.name.startswith('~$'):
            continue
            
        print(f"处理: {docx_file.name}")
        
        # 创建对应的输出目录名（文件名_img）
        output_dir = current_dir / f"{docx_file.stem}_img"
        
        # 提取图片
        extract_images_from_docx(str(docx_file), str(output_dir))
        print()

if __name__ == "__main__":
    main()

