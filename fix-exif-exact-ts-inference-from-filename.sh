#!/bin/bash

source common-functions.sh

for f in $1
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
