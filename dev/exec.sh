#!/bin/bash

# Create a temporary file to store the URLs
temp_file=$(mktemp)

# Extract URLs from the link.txt file
grep -o 'https://apps-assets.fit2cloud.com/dev/1panel/.*' link.txt > "$temp_file"

# Create a directory to store the downloaded files
mkdir -p nextweb

# Change to the downloads directory
cd nextweb

# Read each URL from the temporary file
while IFS= read -r url; do
    # Extract the path after the base URL
    path=$(echo "$url" | sed 's|https://apps-assets.fit2cloud.com/dev/1panel/||')
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$(dirname "$path")" ]; then
        mkdir -p "$(dirname "$path")"
    fi
    
    # Download the file
    filename=$(basename "$url")
    wget -q "$url" -O "$filename"
    
    # Move the file to the appropriate directory
    mv "$filename" "$(dirname "$path")"
done < "$temp_file"

# Remove the temporary file
rm "$temp_file"