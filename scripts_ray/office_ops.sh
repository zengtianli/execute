#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/convert_ops.sh"

convert_doc_to_docx() {
    local input="$1"
    local output="$2"
    convert_with_soffice "$input" "$output" "docx"
}

convert_xls_to_xlsx() {
    local input="$1"
    local output="$2"
    convert_with_soffice "$input" "$output" "xlsx"
}

convert_to_pdf() {
    local input="$1"
    local output="$2"
    convert_with_soffice "$input" "$output" "pdf"
}

convert_docx_to_md() {
    local input="$1"
    local output="$2"
    convert_with_pandoc "$input" "$output" "docx" "markdown"
}

convert_pptx_to_md() {
    local input="$1"
    local output="$2"
    
    if ! check_python_package "python-pptx"; then
        return 1
    fi
    
    if retry_command "$PYTHON_PATH" -c "
import sys
from pptx import Presentation
from pathlib import Path

def convert_pptx_to_md(pptx_path, md_path):
    prs = Presentation(pptx_path)
    with open(md_path, 'w') as f:
        for i, slide in enumerate(prs.slides, 1):
            f.write(f'# Slide {i}\\n\\n')
            for shape in slide.shapes:
                if hasattr(shape, 'text') and shape.text:
                    f.write(f'{shape.text}\\n\\n')
            f.write('---\\n\\n')

convert_pptx_to_md('$input', '$output')
"; then
        echo "✅ 已转换: $(basename "$input") -> $(basename "$output")"
        return 0
    else
        echo "❌ 转换失败: $(basename "$input")"
        return 1
    fi
}

extract_tables_from_docx() {
    local input="$1"
    local output_dir="$2"
    
    if ! check_python_package "python-docx"; then
        return 1
    fi
    
    ensure_dir "$output_dir"
    
    if retry_command "$PYTHON_PATH" -c "
import sys
from docx import Document
from pathlib import Path

def extract_tables(docx_path, output_dir):
    doc = Document(docx_path)
    for i, table in enumerate(doc.tables, 1):
        output_file = Path(output_dir) / f'table_{i}.csv'
        with open(output_file, 'w') as f:
            for row in table.rows:
                f.write(','.join(cell.text for cell in row.cells) + '\\n')

extract_tables('$input', '$output_dir')
"; then
        echo "✅ 已提取表格: $(basename "$input")"
        return 0
    else
        echo "❌ 提取失败: $(basename "$input")"
        return 1
    fi
}

extract_tables_from_xlsx() {
    local input="$1"
    local output_dir="$2"
    
    if ! check_python_package "openpyxl"; then
        return 1
    fi
    
    ensure_dir "$output_dir"
    
    if retry_command "$PYTHON_PATH" -c "
import sys
import openpyxl
from pathlib import Path

def extract_sheets(xlsx_path, output_dir):
    wb = openpyxl.load_workbook(xlsx_path, data_only=True)
    for sheet in wb:
        output_file = Path(output_dir) / f'{sheet.title}.csv'
        with open(output_file, 'w') as f:
            for row in sheet.rows:
                f.write(','.join(str(cell.value or '') for cell in row) + '\\n')

extract_sheets('$input', '$output_dir')
"; then
        echo "✅ 已提取工作表: $(basename "$input")"
        return 0
    else
        echo "❌ 提取失败: $(basename "$input")"
        return 1
    fi
} 