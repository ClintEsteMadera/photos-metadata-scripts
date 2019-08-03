#!/bin/bash

source common-functions.sh

# This script will recurse over all the files and directories within the current dir, assuming that all files conform to
# this pattern: <yyyy><mm><dd>_<HH><MM><SS>.<extension>. It'll fix/enrich the EXIF metadata (assumed to be) present in
# photos and videos, so that they show up at the right date/time in Google Photos

find . -type file | grep -vF -e '.DS_Store' -e '.picasa.ini' | sort -u | while read f
do
  file="${f#./}"

  tsInTouchFormat=$(extractDateTimeInTouchFormatFromFilename "$file")

  fixExifUsingFilename ${tsInTouchFormat} ${file}
done
