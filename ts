#!/bin/bash

# This script assumes a file with the following naming structure: <yyyy><mm><dd>_<HH><MM><SS>.jpg
# e.g.: 20160426_152304.jpg (note the times are expressed in 24-hour format)
# It changes the file's last modification time to mimic the information extracted from the file name.

file=$1;
fileNameWithoutExtension="${file%.*}"

# Translate from file's name format to the one accepted by "touch"
timestamp=`date -j -f "%Y%m%d_%H%M%S" $fileNameWithoutExtension "+%Y%m%d%H%M.%S"`;

# Touch file's last modified date to reflect the actual date/time the video was taken
touch -t "$timestamp" "$file"
