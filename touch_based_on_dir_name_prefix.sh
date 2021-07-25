#!/bin/bash

# Usage: touch_based_on_dir_name_prefix.sh <fullDirPath>

source common-functions.sh

dateInTouchFormat="$(extractDateInTouchFormatFromDirectoryName "$1")";

touch -t "$dateInTouchFormat" "$1"/*;

jhead -dsft "$1"/*
