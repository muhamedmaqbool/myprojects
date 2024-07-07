#!/bin/bash
SOURCE=/home/maqbool/test123
DEST=/home/maqbool/test1234

for i in $(find $SOURCE -mindepth 2 -maxdepth 2 -mtime +1 -type d)
do
  if [ -d "$i" ]; then
    # Extract the parent directory name from the full directory path
    parentdir1="$(dirname "$i")"
    parentdir="$(basename "$parentdir1")"
    # Extract the last directory name from the full directory path
    subdir="$(basename "$i")"
    # Compress the directory with its parent directory name as part of the filename
    tar -czaf "${parentdir}_${subdir}.tar.gz" "$i"
    # Move the compressed file to the destination directory
    mv *.tar.gz $DEST
    # Remove the original directory
    # rm -rf "$i"
  fi
done
