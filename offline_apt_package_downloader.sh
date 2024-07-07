#!/bin/bash

# Check if apt-rdepends is installed
if ! command -v apt-rdepends &> /dev/null; then
    echo "apt-rdepends is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install apt-rdepends
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

package_name=$1
output_file="dependencies.txt"

# Run apt-rdepends to find dependencies
dependencies=$(apt-rdepends -p "$package_name" | grep -E 'Depends|PreDepends|Recommends|Suggests' | awk '{gsub(/\([^)]*\)/,""); print $2}')

# Check if any dependencies are found
if [ -z "$dependencies" ]; then
    echo "No dependencies found for $package_name."
else
    # Save dependencies to the output file
    echo "$dependencies" > "$output_file"
    echo "Dependencies saved to $output_file."

    # Define the file containing dependencies
    DEPENDENCY_FILE="dependencies.txt"

    # Read dependencies from the file and download each package
    while IFS= read -r dependency; do
        # Use apt-get download to download the package
	sudo apt-get download "$package_name"
        sudo apt-get download "$dependency" 
    done < "$DEPENDENCY_FILE"

    # Display a message indicating that the download is complete
    echo "Download complete."
fi

