#!/bin/bash

# source rename.sh

# The following will recurse over all the files and directories within the current dir, assuming that all files conform to
# this pattern: <yyyy><mm><dd>_<HH><MM><SS>.<extension>. Concurrently, it will fix/enrich the EXIF metadata (assumed to be)
# present in photos and videos, so that they show up at the right date/time in Google Photos

find . -type file | grep -vF -e '.DS_Store' -e '.picasa.ini' -e '.txt' -e '.zip' | sort -u | parallel fix-exif-exact-ts-inference-from-filename.sh {1}