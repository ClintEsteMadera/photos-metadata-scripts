# photos-metadata-scripts
Several BASH scripts to automate the metadata and filename processing of digital photos

## How to add these scripts to MacOS' context menu:

In a nutshell, you will need to create new "Service" from scratch using Automator and make it a "Quick Action". The general script body is as follows:

```
on run {input, parameters}

	# Optional command to show current path in a dialog, for debugging purposes.
	# display dialog input as text
	

	set selectedDirectories to {}

	repeat with i from 1 to count input
		set end of selectedDirectories to quoted form of (POSIX path of (item i of input as string)) & space
	end repeat

	repeat with dir in selectedDirectories
		tell application "Terminal"
			# activate (uncomment to make the console show up on top of all other windows)

			do script "cd " & dir & " && " & "/Users/jony/bin/photos-metadata-scripts/rename.sh" & " && " & "/Users/jony/bin/photos-metadata-scripts/exifixer.sh"
		end tell
	end repeat

	return input

end run
```

Useful links:

- https://dev.to/ahmedmusallam/how-to-add-a-run-script-context-menu-in-macos--onh
- https://www.chriswrites.com/how-to-customise-the-right-click-menu-in-mac-os-x/
- https://alvinalexander.com/apple/applescript-list-iterate-items-for-loop-mac/