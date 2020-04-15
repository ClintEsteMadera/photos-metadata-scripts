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

# (Only for images) [-ft] = Set file's last modified date. [-n] = rename all files according to what's in the EXIF field
ls -- *.jpg *.JPG *.jpeg *.JPEG 2>/dev/null | sed 's/ /\\ /g' | xargs jhead -q -ft -n%Y%m%d_%H%M%S

# Rename MOV and PNG files according to their last modified date timestamp
for f in `ls *.mov *.MOV *.png *.PNG 2>/dev/null`; do
  if [[ -f "$f" ]]
    then
      renameFileToLastModifiedTs "${f}"
  fi
done

# Touch last modified timestamps in all MP4 files
for f in `ls *.mp4 *.MP4 2>/dev/null` ; do
  if [[ -f "$f" ]]
    then
      if [[ ${f} == P* ]] || [[ ${f} == IMG_* ]]
        then
          # Deal with photos created by Panasonic cameras (P*) or MP4s converted from iPhone's MOVs (IMG_*.MOV)
          renameFileToLastModifiedTs "${f}"
        else
          extractDateTimeInTouchFormatFromFilename "${f}"
      fi
  fi
done
