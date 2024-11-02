#!/bin/bash

# Input file containing URLs and filenames
input_file="docker-compose.txt"
# Output file to save the modified content
output_file="docker-compose-out.txt"

# Read through each line of the input file
while IFS= read -r line; do
  # Replace any filename or URL ending with .tar.gz with docker-compose.yml
  modified_line=$(echo "$line" | sed 's/[a-zA-Z0-9.-]*\.tar\.gz/docker-compose.yml/g')
  # Write the modified line to the output file
  echo "$modified_line" >> "$output_file"
done < "$input_file"

echo "Replacement complete. Check the file $output_file for results."