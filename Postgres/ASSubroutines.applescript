on openTerminalApp(command)
	tell application "Terminal"
		activate
		if number of windows = 0 then
			do script command
		else
			tell application "System Events" to keystroke "t" using command down
			do script command in window 1
		end if
	end tell
end openTerminalApp



on moveToFolder(srcPath, dstPath)
	tell application "Finder"
		--move POSIX file path to POSIX file path with replacing
	end tell
end moveToApplicationsFolder
