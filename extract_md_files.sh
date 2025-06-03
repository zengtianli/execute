#!/bin/bash

# Target directory
TD="mded"

mkdir -p "$TD"

s_count=0 # success count
f_count=0 # fail count

while read -r file_path; do
    fname=$(basename "$file_path")
    rel_path="${file_path#./}"
    target_path="$TD/$fname"

    # Handle filename collisions
    if [ -f "$target_path" ]; then
        dir_prefix=$(dirname "$rel_path" | tr '/' '_')
        collided=true # Assume collision until a unique name is found or generated

        if [ "$dir_prefix" != "." ]; then
            candidate_path="$TD/${dir_prefix}_${fname}"
            if [ ! -f "$candidate_path" ]; then
                target_path="$candidate_path"
                collided=false
            fi
            # If candidate_path also exists, 'collided' remains true, falls through to counter
        fi

        if [ "$collided" = true ]; then
            base_name="${fname%.md}"
            counter=1
            # Loop to find a unique name with a numeric suffix
            while [ -f "$TD/${base_name}_${counter}.md" ]; do
                ((counter++))
            done
            target_path="$TD/${base_name}_${counter}.md"
        fi
    fi
    
    if cp "$file_path" "$target_path" 2>/dev/null; then
        ((s_count++))
    else
        echo "Error copying: $rel_path" >&2
        ((f_count++))
    fi
done < <(find . -type f -name "*.md" -not -path "./$TD/*")

echo "Copied: $s_count, Failed: $f_count. Output in $TD/"
