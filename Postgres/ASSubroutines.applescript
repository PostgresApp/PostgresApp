on openTerminalApp(cmnd)
	tell application "Terminal"
		activate
		if number of windows = 0 then
			do script cmnd
		else
			tell application "System Events" to keystroke "t" using command down
			do script cmnd in window 1
		end if
	end tell
end openTerminalApp
