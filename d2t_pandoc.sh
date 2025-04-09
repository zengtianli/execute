find . -name "*.doc" -o -name "*.docx" | while read file; do
  echo "Converting $file to TXT..."
  filename="${file%.*}"
  extension="${file##*.}"
  pandoc -f "$extension" -t plain --wrap=none -o "${filename}.txt" "$file"
done

