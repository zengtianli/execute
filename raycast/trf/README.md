# Raycast 文件格式转换工具集

这是一个用于Raycast的文件格式转换工具集，可以在Finder中选择文件并快速转换为不同的格式。

## 功能概览

### 📊 表格文件转换
- **csv2txt**: CSV → TXT
- **csv2xlsx**: CSV → XLSX  
- **txt2csv**: TXT → CSV
- **txt2xlsx**: TXT → XLSX
- **xlsx2csv**: XLSX → CSV (转换所有工作表)
- **xlsx2txt**: XLSX/XLS → TXT
- **xls2xlsx**: XLS → XLSX

### 📄 文档转换
- **doc2docx**: DOC → DOCX
- **d2m**: DOCX → Markdown
- **m2d**: Markdown → DOCX
- **pdf2md**: PDF → Markdown

## 使用方法

### 基本操作
1. 在Finder中选择要转换的文件
2. 启动Raycast (⌘ + Space)
3. 输入对应的转换命令
4. 转换完成后文件将保存在原文件同目录下

### 具体说明

#### 表格文件转换
- **csv2txt** / **csv2xlsx**: 选择单个CSV文件进行转换
- **txt2csv** / **txt2xlsx**: 选择单个或多个TXT文件进行转换
- **xlsx2csv**: 选择单个XLSX文件，将所有工作表转换为CSV
- **xlsx2txt**: 支持XLS和XLSX格式，选择单个文件转换
- **xls2xlsx**: 选择单个或多个XLS文件转换为XLSX格式

#### 文档转换
- **doc2docx**: 
  - 如果选择了文件：转换选中的DOC文件
  - 如果未选择：转换当前目录下所有DOC文件
  - 使用Microsoft Word进行转换
  
- **d2m**: 
  - 支持单个DOCX文件或整个文件夹
  - 使用markitdown工具进行转换
  - 可批量处理文件夹中的所有DOCX文件
  
- **m2d**: 
  - 选择单个Markdown文件
  - 使用docx_styler进行转换
  
- **pdf2md**: 
  - 支持选择多个PDF文件
  - 使用marker_single工具进行转换

## 依赖要求

### 系统工具
- **Microsoft Word**: doc2docx转换需要
- **Microsoft Excel**: xls2xlsx转换需要

### Python工具
- **markitdown**: 用于DOCX到Markdown转换
- **marker_single**: 用于PDF到Markdown转换
- **docx_styler**: 用于Markdown到DOCX转换

### Python脚本
所有表格转换功能依赖于以下Python脚本：
- `csvtxtxlsx/csv2txt.py`
- `csvtxtxlsx/csv2xlsx.py`
- `csvtxtxlsx/txt2csv.py`
- `csvtxtxlsx/txt2xlsx.py`
- `csvtxtxlsx/xlsx2csv.py`
- `csvtxtxlsx/xlsx2txt.py`

## 安装配置

1. 确保所有依赖的Python脚本已放置在正确位置
2. 安装必要的命令行工具：
   ```bash
   # 安装markitdown
   pip install markitdown
   
   # 安装marker
   pip install marker-pdf
   ```
3. 将脚本文件复制到Raycast扩展目录
4. 在Raycast中刷新扩展列表

## 特性

- ✅ 支持批量转换（部分工具）
- ✅ 自动检测文件类型
- ✅ 友好的错误提示
- ✅ 进度显示
- ✅ 转换结果统计
- ✅ 在原文件目录保存结果

## 注意事项

1. **权限要求**: 某些转换可能需要相应应用程序的访问权限
2. **文件大小**: 大文件转换可能需要较长时间
3. **格式支持**: 确保源文件格式正确且未损坏
4. **路径要求**: 脚本路径需要根据实际安装位置调整

## 错误排查

如果转换失败，请检查：
- [ ] 文件格式是否正确
- [ ] 相关应用程序是否已安装
- [ ] Python环境和依赖包是否正常
- [ ] 文件是否被其他程序占用
- [ ] 磁盘空间是否充足

## 更新日志

- 初始版本：支持11种常见文件格式转换
- 添加批量处理支持
- 优化错误处理和用户反馈 