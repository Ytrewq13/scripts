#!/bin/sh

LIBDIR="$HOME/Pictures/desktop-backgrounds"
CURRENT_BG_FILE="$HOME/.cache/current-desktop-background"
new=$(find "$LIBDIR" -type f -name "*.png" | awk -F'.' '{for (i=0;i<$(NF-1);i++){print}}' | shuf -n 1)
if [ -f "$CURRENT_BG_FILE" ]; then
    new=$(find "$LIBDIR" -type f -name "*.png" | awk -F'.' '{for (i=0;i<$(NF-1);i++){print}}' | grep -vf "$CURRENT_BG_FILE" | shuf -n 1)
fi

echo "$new"

exit 0

file="$new"
val=0

# TODO: Use EXIF tags to store rating of images
# The "Rating" tag is apparently only used by Windows, and fits perfectly with
# what I want to use it for.
# Usage:
# to read the "Rating" tag for an image:
exiftool -Rating -binary "$file" # '-binary' gives value only with no newline
# to change the "Rating" tag for an image:
exiftool -Rating="$val" -overwrite_original "$file"
