#!/bin/bash

source common-functions.sh

# This script approximates the date/time the photos were taken by making inferences on the filenames (which can contain
# wildcards like "2019-10-XX") and also considering the directories they belong to.

# Usage 1: (single file) will set the timestamp to 1958-01-01 00:00:00 to the single file passed in
# fix-exif-smart-ts-inference.sh "195801010000.00" file

# Usage 2: (multiple files) will recurse over all the files and directories within the current dir, trying to infer a
# date/time format from filenames. If it can't, it will use the default format provided
# fix-exif-smart-ts-inference.sh "195801010000.00"

# Usage 3: (multiple files) #will recurse over all the files and directories within the current dir, trying to infer a
# date/time format from filenames. If it can't, it will try to infer a format from the current working directory (e.g. "1984").
# fix-exif-smart-ts-inference.sh

DEFAULT_DAY="01"
DEFAULT_MONTH="01"

# 08:00:00 in the morning. To avoid time zone issues (i.e. if we set 00:00:00, they can show up later under the day before)
DEFAULT_TIME_FOR_INFERRED_FORMATS="0800.00"

TWO_DIGIT_REGEX="[0-9]{2}"
FOUR_DIGIT_REGEX="[0-9]{4}"

# global variables, nice, huh?
DEFAULT_FORMAT=""
FORMAT_FOR_CURRENT_FILE=""

deriveFormat() {
	filePath=$1
	possibleDate=`echo "$filePath" | awk '{printf "%s\n", $1}' | sed -e 's/\.\///g'`

	year=`echo ${possibleDate} | awk -F- '{printf $1}'`
	month=`echo ${possibleDate} | awk -F- '{printf $2}'`
	day=`echo ${possibleDate} | awk -F- '{printf $3}'`

	if [[ "$month" = "XX" ]]; then
		month=${DEFAULT_MONTH};
	fi
	if [[ "$day" = "XX" || "$day" = "0X" ]]; then
		day=${DEFAULT_DAY};
	fi
	if [[ "$day" = "1X" ]]; then
		day="13";
	fi
	if [[ "$day" = "2X" ]]; then
		day="23";
	fi

	# echo "Year: $year"
	# echo "Month: $month"
	# echo "Day: $day"

	if [[ ! "$year" =~ $FOUR_DIGIT_REGEX ]] || [[ ! "$month" =~ $TWO_DIGIT_REGEX ]] || [[ ! "$day" =~ $TWO_DIGIT_REGEX ]]; then
		if [[ ${#DEFAULT_FORMAT} -ne 15 ]]; then
			echo "Could not infer format from directory name and default format is absent or incorrect, bailing..."
			exit 1;
		fi
		FORMAT_FOR_CURRENT_FILE=${DEFAULT_FORMAT}
		#echo "Using default format: $DEFAULT_FORMAT"
	else
		FORMAT_FOR_CURRENT_FILE="${year}${month}${day}${DEFAULT_TIME_FOR_INFERRED_FORMATS}"
		#echo "Using inferred format: $FORMAT_FOR_CURRENT_FILE"
	fi
}

main() {
	if [[ $# -lt 1 ]]; then
		# Usage 3: try to infer default format based on current working directory
		currentWorkingDir=$(basename $(echo "$PWD"))
		if [[ "$currentWorkingDir" =~ $FOUR_DIGIT_REGEX ]]; then
			DEFAULT_FORMAT="${currentWorkingDir}${DEFAULT_MONTH}${DEFAULT_DAY}${DEFAULT_TIME_FOR_INFERRED_FORMATS}"
		else
			echo "Wrong number of params: at least a default format must be provided when not running from a year-like directory"
			exit 1;
		fi
	elif [[ $# -eq 1 ]]; then
		# Usage 2: using provided default format but will still try to infer from filenames too.
		DEFAULT_FORMAT=$1
	elif [[ $# -eq 2 ]]; then
		# Usage 1: will operate over only a single file using provided params
		DEFAULT_FORMAT=$1
		processSingleFile ${DEFAULT_FORMAT} "$2"
		exit 0;
	fi

	find . -type file | grep -vF -e '.DS_Store' -e '.picasa.ini' | sort -u | while read file
	do
		deriveFormat "$file"
		fixExifUsingFilename ${FORMAT_FOR_CURRENT_FILE} ${file}
	done
}

main "$@"
