#!/usr/bin/env bash
# If no arguments provided, process all docx files in current directory
if [ $# -eq 0 ]; then
    # Find all .docx files in current directory
    for docx_file in *.docx; do
        # Check if there are any .docx files
        if [ -e "$docx_file" ]; then
            # Process each docx file
            /Users/tianli/miniforge3/bin/python3 /Users/tianli/bendownloads/mark_docx/src/docxmark.py "$docx_file"
            # Get the input file name without extension
            input_file="${docx_file%.*}"
            # Cat the generated markdown file if it exists
            if [ -f "${input_file}_temp.md" ]; then
                echo "=== Content of ${input_file}_temp.md ==="
                cat "${input_file}_temp.md"
                echo "=== End of ${input_file}_temp.md ==="
                echo
            fi
        else
            echo "No .docx files found in current directory"
            exit 1
        fi
    done
else
    # Process the specified file
    /Users/tianli/miniforge3/bin/python3 /Users/tianli/bendownloads/mark_docx/src/docxmark.py "$@"
    # Get the input file name without extension
    input_file="${1%.*}"
    # Cat the generated markdown file if it exists
    if [ -f "${input_file}.md" ]; then
        cat "${input_file}.md"
    fi
fi
