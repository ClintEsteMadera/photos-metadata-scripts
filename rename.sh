#!/bin/bash

# This script scans all files within the current directory and renames them all so that they conform to the pattern
# <yyyy><mm><dd>_<HH><MM><SS>.<extension>
#
# It deals with JPGs, PNGs, MOVs and MP4s. For JPEGs, it uses for the rename the date/time from the EXIF metadata, if any.
# It also handles the situation where more than one photo could have been taken at the exact same date/time, avoiding
# accidental overrides due to name collisions.
#
# Usage: rename.sh (no arguments)

source common-functions.sh

EXPECTED_FILENAME_REGEX="[0-9]{8}\_[0-9]{6}\.[A-Za-z0-9]{3}"

# (Only for images) [-ft] = Set file's last modified date. [-n] = rename all files according to what's in the EXIF field
ls -- *.jpg *.JPG *.jpeg *.JPEG 2>/dev/null | sed 's/ /\\ /g' | xargs jhead -q -ft -n%Y%m%d_%H%M%S
# To-Do: change the above with something like
# find . -type file | egrep '.jpg|.JPG|.jpeg|.JPEG' | xargs jhead -q -ft -n%Y%m%d_%H%M%S
# but make it work for sub-directories

# Rename MP4, MOV and PNG files according to their last modified date timestamp
for f in *.mp4 *.MP4 *.mov *.MOV *.png *.PNG; do
  if [[ -f "$f" ]]; then
    if [[ "$f" =~ $EXPECTED_FILENAME_REGEX ]]; then
      tsInTouchFormat=$(extractDateTimeInTouchFormatFromFilename "${f}")
      touch -t "$tsInTouchFormat" "$f"
    else
      renameFileToLastModifiedTs "${f}"
    fi
  fi
done
