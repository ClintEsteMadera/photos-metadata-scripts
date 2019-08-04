#!/bin/bash

source common-functions.sh

# This script will recurse over all the files and directories within the current dir, assuming that all files conform to
# this pattern: <yyyy><mm><dd>_<HH><MM><SS>.<extension>. It'll fix/enrich the EXIF metadata (assumed to be) present in
# photos and videos, so that they show up at the right date/time in Google Photos

find . -type file | grep -vF -e '.DS_Store' -e '.picasa.ini' -e '.txt' -e '.zip' | sort -u | while read f
do
  # remove extension
  filePath="${f#./}"

  # strip out everything except for the file name
  filename=`echo "$filePath" | awk -F/ '{printf $NF}'`

  tsInTouchFormat=$(extractDateTimeInTouchFormatFromFilename "$filename")

  if [[ ${#tsInTouchFormat} -ne 15 ]]; then
    echo "Could not infer date/time from $filePath, aborting..."
    exit 1;
  else
    fixExifUsingFilename ${tsInTouchFormat} "${filePath}"
  fi
done
