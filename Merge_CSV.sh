#!/bin/bash

# Define the output file name
output_file="merged.csv"

# Remove the output file if it already exists
rm -f "$output_file"

# Prompt the user to enter CSV file names to merge
echo "Enter the CSV file names you want to merge (separated by spaces):"
read -a csv_files

# Check if at least one file was entered
if [ ${#csv_files[@]} -eq 0 ]; then
  echo "No files entered. Exiting."
  exit 1
fi

# Check if the files exist
for file in "${csv_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "File $file not found. Exiting."
    exit 1
  fi
done

# Add the header to the output file with an additional "source" column
{
  head -n 1 "${csv_files[0]}" | sed 's/$/,source/'
} > "$output_file"

# Loop through the selected CSV files and add a source column
for file in "${csv_files[@]}"; do
  # Append data with the source column, skipping the header row
  tail -n +2 "$file" | awk -v src="$(basename "$file")" '{print $0 "," src}' >> "$output_file"
done

echo "CSV files merged into $output_file with a source column"
