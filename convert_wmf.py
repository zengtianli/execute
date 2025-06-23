import subprocess
from pathlib import Path

def convert_wmf_with_libreoffice():
    """使用 LibreOffice 转换 WMF 到 PNG"""
    soffice_path = "/Applications/LibreOffice.app/Contents/MacOS/soffice"
    wmf_files = list(Path.cwd().glob("*.wmf"))
    
    if not wmf_files:
        print("未找到 WMF 文件")
        return
    
    print(f"找到 {len(wmf_files)} 个 WMF 文件")
    
    for wmf_file in wmf_files:
        try:
            cmd = [
                soffice_path,
                "--headless",
                "--convert-to", "png",
                "--outdir", str(Path.cwd()),
                str(wmf_file)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✓ 转换成功: {wmf_file.name} → {wmf_file.stem}.png")
            else:
                print(f"✗ 转换失败: {wmf_file.name}")
                print(f"  错误: {result.stderr}")
                
        except Exception as e:
            print(f"✗ 处理失败: {wmf_file.name} - {e}")

# 运行
if __name__ == "__main__":
    convert_wmf_with_libreoffice()
