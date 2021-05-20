#!/bin/bash

# This function assumes a file with the following naming structure: <yyyy><mm><dd>_<HH><MM><SS>.jpg
# e.g.: 20160426_152304.jpg (note the times are expressed in 24-hour format)
# It translates that timestamp to a format accepted by the "touch" command. This format is useful for changing the
# file's last modification time to mimic the information extracted from the file name.
#
# @returns the timestamp from the file, in the format accepted by "touch"
function extractDateTimeInTouchFormatFromFilename {
    filePath=$1;
    fileNameWithoutExtension="${filePath%.*}";

    # Translate from file's name format to the one accepted by "touch"
    tsInTouchFormat=`date -j -f "%Y%m%d_%H%M%S" "${fileNameWithoutExtension}" "+%Y%m%d%H%M.%S"`;

    # Our way to return values in Bash, do not echo anything else on this function or you'll break everything
    echo "$tsInTouchFormat";
}

function fixExifUsingFilename {
  tsInTouchFormat=$1
  filePath="$2"
  tz="$3"

  if [ -z "$tz" ];
  then
      tz="America/Argentina/Buenos_Aires"
  fi

  # Translate from the format accepted by touch (e.g. 201005022118.39)
  # to ISO-8601, used on XMP metadata tags and many others (e.g. 2010-05-02T21:18:39-0300)
  # Some valid examples:
  # America/Phoenix
  # America/Los_Angeles
  # America/New_York
  # America/Argentina/Buenos_Aires
  # for other timezones, use "sudo systemsetup -listtimezones"
  isoFormat=`TZ=$tz date -jf "%Y%m%d%H%M.%S" "$tsInTouchFormat" "+%Y-%m-%dT%H:%M:%S%z"`;

  echo "Processing "$filePath" using $tsInTouchFormat ($isoFormat)"

  # Touch file's last modified date to reflect the actual date/time the video was taken
  touch -t "$tsInTouchFormat" "$filePath";

  # -dsft = sets file's last modification time to EXIF (if it doesn't exist, we don't create one for avoiding JHead's destructive override of pre-existing EXIFs)
  # -dx = deletes XMP section which is usually set by Photoshop and causes Google Photos to use the digitalization date rather than the file's last modification date.
  # jhead -dsft -dx "$2"

  exiftool -P \
           -overwrite_original_in_place \
           -api QuickTimeUTC \
           -mwg:CreateDate="$isoFormat" \
           -mwg:ModifyDate="$isoFormat" \
           -mwg:DateTimeOriginal="$isoFormat" \
           -CreateDate="$isoFormat" \
           -ModifyDate="$isoFormat" \
           -DateTimeOriginal="$isoFormat" \
           -MediaCreateDate="$isoFormat" \
           -MediaModifyDate="$isoFormat" \
           -TrackCreateDate="$isoFormat" \
           -TrackModifyDate="$isoFormat" \
           "$filePath"
}
function extensionInLowerCase {
  # crude way of returning a value in Bash
  echo "${1##*.}" | tr '[:upper:]' '[:lower:]';
}

function secureRename {
  source=$1
  dest=$2
  dest_basename=${dest%.*}
  dest_ext=${dest##*.}

  if [[ ! -e "$dest_basename.$dest_ext" ]]; then
      # file does not exist in the destination directory
      mv -v -- "$source" "$dest"
  else
      # Look for a unique name
      num=2
      while [[ -e "$dest_basename$num.$dest_ext" ]]; do
          (( num++ ))
      done
      mv -v -- "$source" "$dest_basename-$num.$dest_ext"
  fi
}

function renameFileToLastModifiedTs {
  timestamp=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "${1}"`;
  extInLowerCase=`echo "${1##*.}" | tr '[:upper:]' '[:lower:]'`;
  secureRename "$1" "$timestamp".${extInLowerCase}
}
