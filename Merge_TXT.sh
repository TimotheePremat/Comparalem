#!/bin/bash

# Prompt the user to enter the output file name
echo "Enter the name for the output file (e.g., merged.txt):"
read output_file

# Check if an output file name was provided
if [ -z "$output_file" ]; then
  echo "No output file name provided. Exiting."
  exit 1
fi

# Remove the output file if it already exists
rm -f "$output_file"

# Prompt the user to enter text file names to merge
echo "Enter the text file names you want to merge (separated by spaces):"
read -a txt_files

# Check if at least one file was entered
if [ ${#txt_files[@]} -eq 0 ]; then
  echo "No files entered. Exiting."
  exit 1
fi

# Check if the files exist
for file in "${txt_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "File $file not found. Exiting."
    exit 1
  fi
done

# Add a header to the output file with a semicolon separator
echo "content;source" > "$output_file"

# Loop through the selected text files and add a source column
for file in "${txt_files[@]}"; do
  # Append data with the source column using semicolon as a separator
  awk -v src="$(basename "$file")" '{print $0 ";" src}' "$file" >> "$output_file"
done

# Use portable `sed` to ensure the last column header is "source"
if sed --version >/dev/null 2>&1; then
  # GNU sed
  sed -i '1s/[^;]*$/source/' "$output_file"
else
  # BSD sed (like on macOS)
  sed -i '' '1s/[^;]*$/source/' "$output_file"
fi

echo "Text files merged into $output_file."
