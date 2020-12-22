on run
	delay 0.1
	tell application "System Events"
		keystroke "c" using command down
	end tell
	delay 0.1
	set lingueeBaseURL to "https://www.linguee.com/english-german/search?source=auto&query="
	set lingueeURL to lingueeBaseURL & (the clipboard)
	set dictccBaseURL to "https://www.dict.cc/?s="
	set dictccURL to dictccBaseURL & (the clipboard)
	set deeplBaseURL to "https://www.deepl.com/en/translator#en/de/"
	set deeplBaseURLtwo to "https://www.deepl.com/en/translator#de/en/"
	set deeplURL to deeplBaseURL & (the clipboard)
	tell application "Google Chrome"
		set windowList to every tab of every window whose URL starts with lingueeBaseURL
		repeat with tabList in windowList
			set tabList to tabList as any
			repeat with tabItr in tabList
				set tabItr to tabItr as any
				delete tabItr
			end repeat
		end repeat
		set windowList to every tab of every window whose URL starts with dictccBaseURL
		repeat with tabList in windowList
			set tabList to tabList as any
			repeat with tabItr in tabList
				set tabItr to tabItr as any
				delete tabItr
			end repeat
		end repeat
		set windowList to every tab of every window whose URL starts with deeplBaseURL
		repeat with tabList in windowList
			set tabList to tabList as any
			repeat with tabItr in tabList
				set tabItr to tabItr as any
				delete tabItr
			end repeat
		end repeat
		set windowList to every tab of every window whose URL starts with deeplBaseURLtwo
		repeat with tabList in windowList
			set tabList to tabList as any
			repeat with tabItr in tabList
				set tabItr to tabItr as any
				delete tabItr
			end repeat
		end repeat
		delay 0.1
		tell its window 1
			set URL of (make new tab) to lingueeURL
			set URL of (make new tab) to dictccURL
			set URL of (make new tab) to deeplURL
		end tell
	end tell
end run