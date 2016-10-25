on open_Terminal(cmnd)
	tell application "Terminal"
		activate
		if number of windows = 0 then
			do script cmnd
			else
			tell application "System Events" to keystroke "t" using command down
			do script cmnd in window 1
		end if
	end tell
end open_Terminal


on open_iTerm(cmnd)
	tell application "iTerm"
		activate
		if number of windows = 0 then
			create window with default profile command cmnd
		else
			tell current window
				create tab with default profile command cmnd
			end tell
		end if
	end tell
end open_iTerm


on open_Postico(theURL)
	tell application "Postico"
		activate
		open location theURL
	end tell
end openPostico
