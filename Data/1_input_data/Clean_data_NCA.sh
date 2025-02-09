#!/bin/bash

# Check if a filename is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 input_filename"
    exit 1
fi

input_file=$1
output_file="${input_file%.*}_cleaned.txt"  # Generating output filename based on input filename

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file $input_file not found"
    exit 1
fi

# Use sed to remove everything after the first tab on each line, and then remove leading and trailing whitespace
# sed -e 's/\t.*//' -e 's/Référence/word, pos, ttpos, rrnpos, ttlemma, rnnlemma, id, s_line, position/' -e 's/,/;/g' "$input_file" > "$output_file"

# sed -e 's/\n[[[:print:]] ]*\t[[[:print:]] ]*\t[[[:print:]] ]*\t[[[:print:]] ]*/blabla/g' -e 's/\t.*//' -e 's/Référence/word, pos, ttpos, rrnpos, ttlemma, rnnlemma, id, s_line, position, word2/' -e 's/,/;/g' "$input_file" > "$output_file"

# sed -e 's/^\([[:print:]]*\)\t[[:print:]]*\t\([[:print:]]* [[:print:]]\)\t[[:print:]]*/\1; \2/g' "$input_file" > "$output_file"

sed -e 's/\t\t/\t/' -e 's/\t/;/' -e 's/, /;/g' -e 's/;[a-z]*_[a-z]*//' -e 's/_/;/' -e 's/ /;/' -e 's/Référence;ContexteGauche\tPivot\tContexteDroit/word;pos;ttpos;rrnpos;ttlemma;rnnlemma;id;s_line;position;word2;word2lemma/' "$input_file" > "$output_file"


echo "Output written to $output_file"
