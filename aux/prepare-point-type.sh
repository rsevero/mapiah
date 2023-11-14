#!/bin/bash

# Text to add before and after each line
# before_text="'"
# after_text="',"
before_text="stringIgnoreCase('"
after_text="') |"

# Input file (modify this as needed)
input_file="area-types.txt"

# Output file (modify this as needed)
output_file="area-grammar.txt"

# Use sed to add text before and after each line
sed "s/.*/${before_text}&${after_text}/" "$input_file" > "$output_file"

echo "Text has been modified and saved to $output_file"
