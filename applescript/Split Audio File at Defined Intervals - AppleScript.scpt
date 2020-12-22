-- Assigning the script to open when a "Start over" button is selected:
-- From: http://apple.stackexchange.com/q/269936/184907
set pathToThisScriptFile to (path to me)



-- Ensuring that FFmpeg is installed:
try
	set ffmpegCheck to "/usr/local/bin/ffmpeg -version"
	do shell script ffmpegCheck
on error
	
	
	tell application "SystemUIServer"
		with timeout of 999999 seconds
			activate
			display alert "This script cannot split any audio file." message "
This script uses a third-party command line program called FFmpeg to split the source audio file.

FFmpeg is not currently installed on your computer. You must first install FFmpeg before you can utilize this script.


If FFmpeg is currently installed and you are reading this message, then you need to open the script and modify the code, so that the code is aware of the location of FFmpeg on your system.

This script references the default location of:
/usr/local/bin/ffmpeg

" buttons {"OK", "Open this script in Script Editor", "Go to official FFmpeg website"} default button "Go to official FFmpeg website" cancel button "OK"
		end timeout
	end tell
	
	if button returned of the result is "Go to official FFmpeg website" then
		open location "https://ffmpeg.org/"
	else if button returned of the result is "Open this script in Script Editor" then
		if application "Script Editor" is running then
			-- Check if this script file is already open.
			try
				set theDocuments to every document
				set theNameOfThisScript to name of (info for (path to me))
				repeat with aDocument in theDocuments
					if ((path of aDocument) as string) contains theNameOfThisScript then
						-- This file is already open in Script Editor.
						activate aDocument
					else
						-- Script Editor is running but the file is not open in Script Editor.
						tell application "Script Editor"
							activate
							open (path to me)
						end tell
					end if
				end repeat
			on error
				-- Script Editor is running but zero documents are open in Script Editor.
				tell application "Script Editor"
					activate
					open (path to me)
				end tell
			end try
		else
			-- Script Editor is not running.
			tell application "Script Editor"
				activate
				open (path to me)
			end tell
		end if
	end if
end try



repeat
	activate
	display dialog "Please enter the length of the desired interval:" default answer "(in seconds)" with title "Split Audio File at Defined Intervals" buttons {"Quit", "Continue"} default button "Continue" cancel button "Quit"
	set desiredIntervalLength to text returned of result
	
	try
		-- Check if variable is a number:
		-- From: http://stackoverflow.com/a/20319349
		set test to desiredIntervalLength as number
		if desiredIntervalLength contains " " then
			error
		end if
		exit repeat
	on error
		(*
			You will find a "SystemUIServer" tell-block surrounding every instance of
				"display alert"
				"display dialog" (that does not receive a input)
				"choose from list"
			in this code. 

			Its function is to bring the dialog to the front of the screen and pin the dialog on top of all other windows.

			From:
			http://apple.stackexchange.com/q/270749/184907
		*)
		tell application "SystemUIServer"
			with timeout of 999999 seconds
				activate
				display alert "The interval that you entered is invalid." message "You must enter a number with no units or letters for the desired interval.

The interval that you've entered, " & desiredIntervalLength & ", is not a number." as critical
			end timeout
		end tell
	end try
end repeat


activate
set ButtonAndInput1 to (display dialog "Please enter the base filename for the resulting files:" default answer "Audio Segment" with title "Split Audio File at Defined Intervals" buttons {"Start over", "Quit", "Continue"} default button "Continue" cancel button "Quit")
set desiredName to ButtonAndInput1's text returned
set buttonChoice1 to ButtonAndInput1's button returned
if buttonChoice1 is "Start over" then
	run script pathToThisScriptFile
	error number -128 (* cancels script *)
end if

-- If the user submits a desired name and that name does not already end in a space, I want to add a space to the end (to separate the name and the number).
if desiredName is not "" then
	set lengthOfDesiredName to (length of desiredName)
	if (character (lengthOfDesiredName) of desiredName is not " ") then
		set desiredName to (desiredName & " ")
	end if
end if











repeat
	activate
	set ButtonAndInput2 to (display dialog "
Please paste the file path of the audio file to split (including its file extension):


(Tip: While holding down the Option ⌥ key, right-click on the file in Finder and select \"Copy [file] as Pathname.\")

(Alternatively, you can drag the file's icon itself to the below text field.)


The resulting files will be output to a new folder within this audio file's parent folder.
" default answer "" with title "Split Audio File at Defined Intervals" buttons {"Start over", "Quit", "Continue"} default button "Continue" cancel button "Quit")
	set desiredSourceFile to (ButtonAndInput2's text returned) as text
	set buttonChoice2 to ButtonAndInput2's button returned
	
	if buttonChoice2 is "Start over" then
		run script pathToThisScriptFile
		error number -128 (* cancels script *)
	end if
	
	
	-- Ensure that desiredSourceFile contains text:
	if desiredSourceFile is "" then
		tell application "SystemUIServer"
			with timeout of 999999 seconds
				activate
				display alert "A path has not been provided by the user." message "You must enter the path of the source file to continue." as critical
			end timeout
		end tell
	else
		
		if desiredSourceFile does not contain "." then
			tell application "SystemUIServer"
				with timeout of 999999 seconds
					activate
					display alert "The path you entered is invalid." message "The path that you entered does not possess any file extension:
				
" & desiredSourceFile & "

Please provide the full file path of the audio file, including the extension." as critical
				end timeout
			end tell
		else
			-- Check if desiredSourceFile contains the file's extension.
			set lengthOfDesiredSourceFile to (length of desiredSourceFile)
			if (character (lengthOfDesiredSourceFile - 3) of desiredSourceFile is ".") or (character (lengthOfDesiredSourceFile - 4) of desiredSourceFile is ".") then
				-- The third-to-last character or the fourth-to-last character is a period, so an extension exists.
				
				-- Get audio file type of source file (by splitting text based on the dot (".") character):
				-- From: http://macscripter.net/viewtopic.php?id=24473
				set tempStorage to AppleScript's text item delimiters
				set AppleScript's text item delimiters to "."
				set the desiredSourceFileInAList to desiredSourceFile's text items
				set AppleScript's text item delimiters to tempStorage
				set theLastItemInTheList to (count of the items in desiredSourceFileInAList)
				set fileExtension to (item theLastItemInTheList of desiredSourceFileInAList) as text
				set fileExtensionWithDot to "." & fileExtension
				
				
				(*
Ensuring that the file extension of the provided file is supported by FFmpeg:

I got the huge list of extensions by typing:
ffmpeg -formats
in Terminal.
From:
http://askubuntu.com/questions/286624/what-input-types-of-files-can-ffmpeg-convert-and-to-what-output-files/286655#286655

NOTE: This list contains non-audio file types, i.e., as video files.

I do not feel the urge to create a list that only contains audio file types.

But just note that this script has been designed to split exclusively AUDIO files. If you do use a non-audio file as the source file... the splitting functon might still not work...or it might give the user an error later on while getting the data for the summary dialog. So, if it matters to you, you should write some code to catch a non-audio file extension (that is supported by FFmpeg).

I just tested my script with a .mov file, out of curiosity, and the script worked perfectly, with no error whatsoever.

Of course, YMMV and use video files at your own risk.
*)
				
				set listOfAllFileExtensionsThatFFmpegSupports to {"3dostr", "3g2", "3gp", "4xm", "a64", "aa", "aac", "ac3", "acm", "act", "adf", "adp", "ads", "adts", "adx", "aea", "afc", "aiff", "aix", "alaw", "alias_pix", "amr", "anm", "apc", "ape", "apng", "aqtitle", "asf", "asf_o", "asf_stream", "ass", "ast", "au", "avfoundation", "avi", "avm2", "avr", "avs", "bethsoftvid", "bfi", "bfstm", "bin", "bink", "bit", "bmp_pipe", "bmv", "boa", "brender_pix", "brstm", "c93", "caf", "cavsvideo", "cdg", "cdxl", "cine", "concat", "crc", "dash", "data", "daud", "dcstr", "dds_pipe", "dfa", "dirac", "dnxhd", "dpx_pipe", "dsf", "dsicin", "dss", "dts", "dtshd", "dv", "dvbsub", "dvbtxt", "dvd", "dxa", "ea", "ea_cdata", "eac3", "epaf", "exr_pipe", "f32be", "f32le", "f4v", "f64be", "f64le", "ffm", "ffmetadata", "fifo", "film_cpk", "filmstrip", "flac", "flic", "flv", "framecrc", "framehash", "framemd5", "frm", "fsb", "g722", "g723_1", "g729", "genh", "gif", "gsm", "gxf", "h261", "h263", "h264", "hash", "hds", "hevc", "hls", "applehttp", "hnm", "ico", "idcin", "idf", "iff", "ilbc", "image2", "image2pipe", "ingenient", "ipmovie", "ipod", "ircam", "ismv", "iss", "iv8", "ivf", "ivr", "j2k_pipe", "jacosub", "jpeg_pipe", "jpegls_pipe", "jv", "latm", "lavfi", "live_flv", "lmlm4", "loas", "lrc", "lvf", "lxf", "m4v", "matroska", "webm", "md5", "mgsts", "microdvd", "mjpeg", "mkvtimestamp_v2", "mlp", "mlv", "mm", "mmf", "mov", "mp4", "m4a", "mj2", "mp2", "mp3", "mpc", "mpc8", "mpeg", "mpeg1video", "mpeg2video", "mpegts", "mpegtsraw", "mpegvideo", "mpjpeg", "mpl2", "mpsub", "msf", "msnwctcp", "mtaf", "mtv", "mulaw", "musx", "mv", "mvi", "mxf", "mxf_d10", "mxf_opatom", "mxg", "nc", "nistsphere", "nsv", "null", "nut", "nuv", "oga", "ogg", "ogv", "oma", "opus", "paf", "pam_pipe", "pbm_pipe", "pcx_pipe", "pgm_pipe", "pgmyuv_pipe", "pictor_pipe", "pjs", "pmp", "png_pipe", "ppm_pipe", "psp", "psxstr", "pva", "pvf", "qcp", "qdraw_pipe", "r3d", "rawvideo", "realtext", "redspark", "rl2", "rm", "roq", "rpl", "rsd", "rso", "rtp", "rtp_mpegts", "rtsp", "s16be", "s16le", "s24be", "s24le", "s32be", "s32le", "s8", "sami", "sap", "sbg", "sdp", "sdr2", "segment", "sgi_pipe", "shn", "siff", "singlejpeg", "sln", "smjpeg", "smk", "smoothstreaming", "smush", "sol", "sox", "spdif", "spx", "srt", "stl", "stream_segment", "stream_segments", "subviewer", "subviewer1", "sunrast_pipe", "sup", "svag", "svcd", "swf", "tak", "tedcaptions", "tee", "thp", "tiertexseq", "tiff_pipe", "tmv", "truehd", "tta", "tty", "txd", "u16be", "u16le", "u24be", "u24le", "u32be", "u32le", "u8", "uncodedframecrc", "v210", "v210x", "vag", "vc1", "vc1test", "vcd", "vivo", "vmd", "vob", "vobsub", "voc", "vpk", "vplayer", "vqf", "w64", "wav", "wc3movie", "webm_chunk", "webm_dash_manifest", "webp", "webp_pipe", "webvtt", "wsaud", "wsd", "wsvqa", "wtv", "wv", "wve", "xa", "xbin", "xmv", "xvag", "xwma", "yop", "yuv4mpegpipe"}
				
				if listOfAllFileExtensionsThatFFmpegSupports does not contain fileExtension then
					tell application "SystemUIServer"
						with timeout of 999999 seconds
							activate
							display alert "The extension of the file that you provided is invalid." message "
This script uses a third-party command line program called FFmpeg to split the source audio file.

FFmpeg cannot transcode multimedia files that possess the file extension that you submitted (" & fileExtension & ").

" buttons {"Start over", "Quit", "View supported file extensions"} default button "View supported file extensions" cancel button "Quit"
						end timeout
					end tell
					if button returned of the result is "Start over" then
						return run script pathToThisScriptFile
						error number -128 (* cancels script *)
					else if button returned of the result is "View supported file extensions" then
						tell application "SystemUIServer"
							with timeout of 999999 seconds
								activate
								set listButton to (choose from list listOfAllFileExtensionsThatFFmpegSupports with title "FFmpeg Supported File Extensions" with prompt "
Here is a list of all file extensions that FFmpeg can accept, in alphabetical order.

Please note that this list includes various multimedia types(including video files), not only audio file extensions.


The extension of the file that you provided, " & fileExtension & ", does not exist in the list.

For more info, please visit:
https://ffmpeg.org/general.html#File-Formats

" cancel button name "Quit" OK button name "Start over" with empty selection allowed and multiple selections allowed)
							end timeout
						end tell
						
						if listButton is false then
							error number -128 (* user cancelled *)
						else
							return run script pathToThisScriptFile
							error number -128 (* cancels script *)
						end if
					end if
				end if
				
				
				
				
				-- Make sure that the desiredSourceFile actually exists:
				-- From: http://stackoverflow.com/a/3469708
				tell application "System Events"
					if exists file desiredSourceFile then
						exit repeat
					end if
				end tell
				tell application "SystemUIServer"
					with timeout of 999999 seconds
						activate
						display alert "The path you entered is invalid." message "The path that you entered does not exist:
				
" & desiredSourceFile & "

Please provide a valid source file." as critical
					end timeout
				end tell
			else
				tell application "SystemUIServer"
					with timeout of 999999 seconds
						activate
						display alert "The path you entered is invalid." message "The file that you entered does not possess an extension:
				
" & desiredSourceFile & "

Please provide the full file path of the audio file, including the extension." as critical
					end timeout
				end tell
			end if
		end if
	end if
end repeat

-- Get duration of the source audio file in seconds:
-- From: https://discussions.apple.com/message/22447897#message22447897
set desiredSourceFileFormatted to (quoted form of (POSIX path of desiredSourceFile))
set lengthOfSourceFileInSeconds to (word -2 of (do shell script "/usr/bin/afinfo " & desiredSourceFileFormatted & "|grep duration")) as text
-- Round the length DOWN (to the nearest whole number integer):
if lengthOfSourceFileInSeconds contains "." then
	set tempStorage to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "."
	set the lengthOfSourceFileInSecondsInAList to lengthOfSourceFileInSeconds's text items
	set AppleScript's text item delimiters to tempStorage
	set lengthOfSourceFileInSeconds to (item 1 of lengthOfSourceFileInSecondsInAList) as text
end if



-- Ensuring that the audio file length is greater than the interval length:
if (desiredIntervalLength as number is greater than or equal to lengthOfSourceFileInSeconds as number) then
	tell application "SystemUIServer"
		with timeout of 999999 seconds
			activate
			display alert "This script cannot continue." message "The interval that you desire (" & desiredIntervalLength & " seconds) is greater than or equal to the duration of the source audio file (" & (lengthOfSourceFileInSeconds as integer) & " seconds).

Therefore, it is not possible to split this audio file using the specified interval.

What would you like to do?
" as critical buttons {"Quit", "Start over"} default button "Start over" cancel button "Quit"
		end timeout
	end tell
	if button returned of the result is "Start over" then
		run script pathToThisScriptFile
		error number -128 (* cancels script *)
	end if
else
	-- The desiredIntervalLength is good.
	set howManyTimesCan_desiredIntervalLength_FitIn_lengthOfSourceFileInSeconds to (lengthOfSourceFileInSeconds div desiredIntervalLength)
	set totalNumberOfFilesToBeCreated to (1 + howManyTimesCan_desiredIntervalLength_FitIn_lengthOfSourceFileInSeconds)
end if



-- Getting the desired output file bit rate from the user:
set bitRateOfSource to (word -4 of (do shell script "/usr/bin/afinfo " & desiredSourceFileFormatted & "|grep rate")) as text
set bitRateOfSourceInKbps to (text 1 thru -4 of (bitRateOfSource as text))

set commonBitRates to {"Same as source", "32 kbps", "96 kbps", "128 kbps", "160 kbps", "192 kbps", "256 kbps", "320 kbps", "Custom number"}

tell application "SystemUIServer"
	with timeout of 999999 seconds
		activate
		set theBitRate to choose from list commonBitRates with title "Bit Rate of Resulting Files" with prompt "
Select a CBR (constant bit rate) for the resulting files.

(This script does not support VBR encoding.)

The source file has a bit rate of approximately " & bitRateOfSourceInKbps & " kbps.


Note: The higher the bit rate, the larger the resulting file size.

Also note: If you select a bit rate other than \"Same as source,\" the processing time will dramatically increase. This is, e.g., the difference between a total runtime of 20 seconds and a total runtime of 2 minutes.
" default items "Same as source" cancel button name {"       Quit       "} OK button name {"       Continue       "} without empty selection allowed
	end timeout
end tell

if theBitRate is false then
	error number -128 (* user cancelled *)
else
	set theBitRate to theBitRate's item 1 (* extract choice from list *)
end if




if (theBitRate is "Same as source") then
	-- Keep same setting as source audio file:
	-- From:http://askubuntu.com/a/328180
	set theBitRateFormatted to "-acodec copy"
else if (theBitRate is "320 kbps") then
	-- Format custom bit rate for ffmpeg:
	-- From:
	-- https://superuser.com/a/370637/598118
	-- https://superuser.com/a/521684/598118
	set theBitRateFormatted to "-b:a 320k"
else if (theBitRate is "256 kbps") then
	set theBitRateFormatted to "-b:a 256k"
else if (theBitRate is "192 kbps") then
	set theBitRateFormatted to "-b:a 192k"
else if (theBitRate is "160 kbps") then
	set theBitRateFormatted to "-b:a 160k"
else if (theBitRate is "128 kbps") then
	set theBitRateFormatted to "-b:a 128k"
else if (theBitRate is "96 kbps") then
	set theBitRateFormatted to "-b:a 96k"
else if (theBitRate is "32 kbps") then
	set theBitRateFormatted to "-b:a 32k"
else if (theBitRate is "Custom number") then
	repeat
		activate
		display dialog "Please enter the desired bit rate in kilobits per second (kbps):" default answer "128" with title "Custom Bit Rate of Resulting Files" buttons {"Quit", "Continue"} default button "Continue" cancel button "Quit"
		set customBitRate to text returned of result
		
		try
			-- Check if variable is a number:
			-- From: http://stackoverflow.com/a/20319349
			set checkCustomBitRate to customBitRate as number
			
			if customBitRate contains " " then
				error
			else if ((length of customBitRate) is greater than 4) then
				tell application "SystemUIServer"
					with timeout of 999999 seconds
						activate
						display alert "The bit rate that you entered (" & customBitRate & ") is invalid." message "You must enter a desired bit rate in kilobits per second (kbps).
					
A bit rate of " & customBitRate & " kbps is impossibly large.

Try again." as critical
					end timeout
				end tell
			else if ((length of customBitRate) is less than 5) then
				exit repeat
			end if
		on error
			tell application "SystemUIServer"
				with timeout of 999999 seconds
					activate
					display alert "The bit rate that you entered (" & customBitRate & ") is invalid." message "You must enter a number for the desired bit rate.
					
Do not include punctuation or units in your entry." as critical
				end timeout
			end tell
		end try
	end repeat
	set theBitRateFormatted to ("-b:a " & customBitRate & "k")
end if







-- Get parent folder of source file (since this is where the resulting files will be saved):
-- From post #3 in this thread: http://macscripter.net/viewtopic.php?id=33828
set parentDirectory to (do shell script "dirname " & quoted form of POSIX path of (desiredSourceFile))

-- Get the current date (in my preferred format):
-- From: http://henrysmac.org/blog/2014/1/4/formatting-short-dates-in-applescript.html
set TodayDate to current date
set y to text -4 thru -1 of ("0000" & (year of TodayDate))
set m to text -2 thru -1 of ("00" & ((month of TodayDate) as integer))
set d to text -2 thru -1 of ("00" & (day of TodayDate))
set FormattedTodayDate to y & "_" & m & "_" & d & " - "




-- Putting all of the variables together:
set folderToSaveResultingFiles to parentDirectory & "/" & FormattedTodayDate & "Script Output - Audio Segments By Interval/"
set startingTimestamp to 0
set endingTimestamp to desiredIntervalLength as number
set counter to 1
set theFullFilepath to folderToSaveResultingFiles & desiredName & counter & fileExtensionWithDot
set theFullFilepathFormatted to quoted form of POSIX path of theFullFilepath

set theStringEnding to (startingTimestamp & " -t " & endingTimestamp & " " & theBitRateFormatted & " " & theFullFilepathFormatted) as text
set theStringBeginning to "/usr/local/bin/ffmpeg -i " & desiredSourceFileFormatted & " -ss "
(*
	NOTE: One cannot simply use "ffmpeg -i" in the above string without including the leading filepath.
		This is because of the fact that: "Scripts that run via Automator use the default search path which usually does not include /usr/local/bin."
	See:
		http://apple.stackexchange.com/questions/97502/my-automator-workflow-fails-because-it-fails-to-find-the-git-command-within-the/167783#167783
		http://stackoverflow.com/a/3774262
		http://apple.stackexchange.com/a/130841/184907
*)
set theFullString to (theStringBeginning & theStringEnding)
(*
theFullString should be in this format: 
ffmpeg -i source_audio_file.m4a -ss 0 -t 120 -acodec copy segment_1.m4a 
ffmpeg -i source_audio_file.m4a -ss 0 -t 120 -b:a 96k segment_1.m4a 
*)





-- Ensuring that the new folder for the resulting files to output to does not already exist:
-- Original author: user3439894

set theFolderAlreadyExistsAndUserWantsToStartOver to false
set theFolderAlreadyExistsAndUserWantsToOpenIt to false

set folderToCheck to POSIX file folderToSaveResultingFiles as string
tell application "Finder" to set b to exists folder folderToCheck
tell current application
	try
		if b then
			tell application "SystemUIServer"
				with timeout of 999999 seconds
					activate
					display dialog "                                       The output directory: 

\"" & POSIX path of folderToCheck & "\" 
                                            already exists!" & return & return & "Do you want to overwrite the directory?" buttons {"No. Start over.", "No. Open the folder that already exists.", "Yes"} default button 1 with title "Folder Already Exists" with icon caution
				end timeout
			end tell
			if the button returned of result is "No. Start over." then
				set theFolderAlreadyExistsAndUserWantsToStartOver to true
				-- I can't use  a return within a try block so, I am using the above boolean variable instead.
				-- This variable will be referenced after the try block is completed to restart the script.				
			else if the button returned of result is "No. Open the folder that already exists." then
				--  # The file already exists, chose not to overwrite it, just open the document.
				set theFolderAlreadyExistsAndUserWantsToOpenIt to true
				-- Open folder in Finder:
				tell application "Finder"
					open (folderToSaveResultingFiles as POSIX file)
					-- Bring Finder window to foreground:		
					activate
					-- Enlarging the Finder window to my preferred size:
					-- From: http://apple.stackexchange.com/a/268667/184907
					set bounds of front window to {161, 49, 1260, 740}
				end tell
			else if the button returned of result is "Yes" then
				tell application "Finder"
					-- Delete the folder, so that I can now recreate this folder.
					delete the folder folderToCheck
				end tell
			end if
		end if
	on error eStr number eNum
		activate
		tell application "SystemUIServer"
			with timeout of 999999 seconds
				activate
				display dialog eStr & " number " & eNum buttons {"OK"} default button 1 with icon caution
			end timeout
		end tell
		error number -128
	end try
end tell

if (theFolderAlreadyExistsAndUserWantsToStartOver is true) then
	run script pathToThisScriptFile
	error number -128 (* user cancelled *)
else if (theFolderAlreadyExistsAndUserWantsToOpenIt is true) then
	error number -128 (* user cancelled *)
end if






-- Creating the new folder for the resulting files to output to:
-- From: http://stackoverflow.com/a/4493619
tell application "Finder"
	make new folder at POSIX file parentDirectory with properties {name:FormattedTodayDate & "Script Output - Audio Segments By Interval"}
end tell

set giveUpTime to 30
tell application "SystemUIServer"
	with timeout of 999999 seconds
		activate
		display alert "Dividing of 1 audio file into " & totalNumberOfFilesToBeCreated & " parts will now begin..." message "
Depending on the duration of the resulting audio files, the number of new audio files to be created, and whether the desired bit rate differs from the bit rate of the source file, this process may take several minutes.

Please wait as the task is completed.

Do not shut down the computer until the splitting is complete.


(automatically proceeding in " & giveUpTime & " seconds)" buttons {"Abort", "Start over", "Split audio file"} default button "Split audio file" cancel button "Abort" giving up after giveUpTime
	end timeout
end tell
if button returned of the result is "Start over" then
	run script pathToThisScriptFile
	error number -128 (* cancels script *)
end if

-- Keeping track of the elapsed time so that the script can notify the user that the script is still running:
-- From: https://discussions.apple.com/message/6883418#message6883418
set BeforeTime_m to minutes of (current date)
set BeforeTime_s to seconds of (current date)
set periodicIntervalToShowUserDialog to 60

set stopMark to 0

repeat until ((stopMark as integer) is greater than or equal to lengthOfSourceFileInSeconds as integer)
	-- This line is where all of the action happens:
	do shell script theFullString
	
	set startingTimestamp to ((startingTimestamp as integer) + desiredIntervalLength as integer) as integer
	set endingTimestamp to (endingTimestamp + desiredIntervalLength)
	
	set counter to ((counter as integer) + 1) as integer
	
	set theFullFilepath to folderToSaveResultingFiles & desiredName & counter & fileExtensionWithDot
	set theFullFilepathFormatted to quoted form of POSIX path of theFullFilepath
	set theStringEnding to (startingTimestamp & " -t " & desiredIntervalLength & " " & theBitRateFormatted & " " & theFullFilepathFormatted) as text
	set theFullString to (theStringBeginning & theStringEnding)
	
	set stopMark to (endingTimestamp)
	
	
	
	set AfterTimeCheck_m to minutes of (current date)
	set AfterTimeCheck_s to seconds of (current date)
	set checkRuntimeInSeconds to ((AfterTimeCheck_m * 60) + AfterTimeCheck_s) - ((BeforeTime_m * 60) + BeforeTime_s)
	
	if (checkRuntimeInSeconds as integer is greater than or equal to periodicIntervalToShowUserDialog as integer) then
		
		set periodicIntervalToShowUserDialog to (periodicIntervalToShowUserDialog + 120)
		
		
		set midstCounter to (counter - 1)
		set howManyMoreFiles to (totalNumberOfFilesToBeCreated - midstCounter)
		
		if (howManyMoreFiles is 1) then
			set howManyMoreFilesDisplayString to "1 more file still has"
		else if (howManyMoreFiles is greater than 1) then
			set howManyMoreFilesDisplayString to (howManyMoreFiles & " more files still have")
		end if
		
		tell application "SystemUIServer"
			with timeout of 999999 seconds
				activate
				display alert "Splitting of the audio file is still occurring..." message "
This script has just completed the creation of audio segment number " & midstCounter & ". 

" & howManyMoreFilesDisplayString & " to be created.

This process may take several minutes to conclude.

Do you want to continue?


(automatically proceeding in " & giveUpTime & " seconds)" buttons {"Stop now", "Start over", "Proceed"} default button "Proceed" cancel button "Stop now" giving up after giveUpTime
			end timeout
		end tell
		if button returned of the result is "Start over" then
			return run script pathToThisScriptFile
			error number -128 (* cancels script *)
		end if
	end if
	
end repeat


-- The final resulting file must have a shorter runtime than the specified interval. Calculate the custom length of this special, last file:
set startingTimestamp to (stopMark - desiredIntervalLength)
set customIntervalLength to (lengthOfSourceFileInSeconds - startingTimestamp)
set theFullFilepath to folderToSaveResultingFiles & desiredName & counter & fileExtensionWithDot
set theFullFilepathFormatted to quoted form of POSIX path of theFullFilepath
set theStringEnding to (startingTimestamp & " -t " & customIntervalLength & " " & theBitRateFormatted & " " & theFullFilepathFormatted) as text
set theFullString to (theStringBeginning & theStringEnding)
do shell script theFullString





-- Convert seconds to minutes for display to user:
set durationOfFinalResultingSegment to customIntervalLength as integer
set desiredIntervalLength to desiredIntervalLength as integer
set lengthOfSourceFileInSeconds to lengthOfSourceFileInSeconds as integer

if desiredIntervalLength is less than 60 then
	if desiredIntervalLength is less than 2 then
		set displayIntervalString to (desiredIntervalLength & " second")
	else
		set displayIntervalString to (desiredIntervalLength & " seconds")
	end if
else
	set displayIntervalString to convertSecondsToHoursAndMinutes(desiredIntervalLength)
end if
if durationOfFinalResultingSegment is less than 60 then
	if durationOfFinalResultingSegment is less than 2 then
		set displayFinalFileLengthString to (durationOfFinalResultingSegment & " second")
	else
		set displayFinalFileLengthString to (durationOfFinalResultingSegment & " seconds")
	end if
else
	set displayFinalFileLengthString to convertSecondsToHoursAndMinutes(durationOfFinalResultingSegment)
end if
if lengthOfSourceFileInSeconds is less than 60 then
	if lengthOfSourceFileInSeconds is less than 2 then
		set displaySourceFileDurationString to (lengthOfSourceFileInSeconds & " second")
	else
		set displaySourceFileDurationString to (lengthOfSourceFileInSeconds & " seconds")
	end if
else
	set displaySourceFileDurationString to convertSecondsToHoursAndMinutes(lengthOfSourceFileInSeconds)
	-- The comma placement is a bit confusing when the source file info is displayed, so change the comma to an ampersand:
	if displaySourceFileDurationString contains ", " then
		set displaySourceFileDurationString to replace_chars(displaySourceFileDurationString, ", ", " & ")
	end if
end if


-- Get bit rates to display to user:
set aRegularResultingFile to (folderToSaveResultingFiles & desiredName & (counter - 1) & fileExtensionWithDot)
set aRegularResultingFileFormatted to (quoted form of (POSIX path of aRegularResultingFile))
set bitRateOfResultingFile to (word -4 of (do shell script "/usr/bin/afinfo " & aRegularResultingFileFormatted & "|grep rate")) as text
set bitRateOfResultingFineInKbps to (text 1 thru -4 of (bitRateOfResultingFile as text))

-- Get sample rates to display to user:
set sampleRateOfResultingFile to (word 5 of (do shell script "/usr/bin/afinfo " & aRegularResultingFileFormatted & "|grep format")) as text
set sampleRateUnitOfResultingFile to (word 6 of (do shell script "/usr/bin/afinfo " & aRegularResultingFileFormatted & "|grep format")) as text
set sampleRateOfResultingFile to (sampleRateOfResultingFile & " " & sampleRateUnitOfResultingFile)

set sampleRateOfSourceFile to (word 5 of (do shell script "/usr/bin/afinfo " & desiredSourceFileFormatted & "|grep format")) as text
set sampleRateUnitOfSourceFile to (word 6 of (do shell script "/usr/bin/afinfo " & desiredSourceFileFormatted & "|grep format")) as text
set sampleRateOfSourceFile to (sampleRateOfSourceFile & " " & sampleRateUnitOfSourceFile)

-- Get file sizes to display to the user:
set theFolderSize to size of (info for folderToSaveResultingFiles)
set theFolderSize to convertByteSize(theFolderSize, 1000, 2)

set theSourceFileSize to size of (info for desiredSourceFile)
set theSourceFileSize to convertByteSize(theSourceFileSize, 1000, 2)

set aRegularFileFileSize to size of (info for aRegularResultingFile)
set aRegularFileFileSize to convertByteSize(aRegularFileFileSize, 1000, 1)

set theMostRecentlyCreatedFileSize to size of (info for theFullFilepath)
set theMostRecentlyCreatedFileSize to convertByteSize(theMostRecentlyCreatedFileSize, 1000, 2)

-- Completing elapsed time calculation:
set AfterTime_m to minutes of (current date)
set AfterTime_s to seconds of (current date)
set runtimeInSeconds to ((AfterTime_m * 60) + AfterTime_s) - ((BeforeTime_m * 60) + BeforeTime_s)

-- Convert runtime in seconds to minutes for display to user:
set runtimeInSeconds to runtimeInSeconds as integer
if runtimeInSeconds is less than 60 then
	if runtimeInSeconds is less than 2 then
		set displayRuntimeString to (runtimeInSeconds & " second")
	else
		set displayRuntimeString to (runtimeInSeconds & " seconds")
	end if
else
	set displayRuntimeString to convertSecondsToHoursAndMinutes(runtimeInSeconds)
end if

tell application "SystemUIServer"
	with timeout of 999999 seconds
		activate
		display alert "Splitting of the audio file is complete." message "
Summary:

• " & counter & " " & fileExtension & " audio files have been created.

• This script required " & displayRuntimeString & " to create the files.

• The segments are located in:
" & folderToSaveResultingFiles & "

• The size of the output folder is " & theFolderSize & ".

• Each file has a file size of approximately " & aRegularFileFileSize & ", except for the last file, which has a file size of exactly " & theMostRecentlyCreatedFileSize & ".

• Each file has a duration of " & displayIntervalString & ", except for the last file, which has a duration of " & displayFinalFileLengthString & ".

• Each file has a bit rate of approximately " & bitRateOfResultingFineInKbps & " kbps.

• Each file has a sample rate of " & sampleRateOfResultingFile & ".

• The source audio file has a duration of " & displaySourceFileDurationString & ", a bit rate of " & bitRateOfSource & " bit/s, a sample rate of " & sampleRateOfSourceFile & ", and a file size of " & theSourceFileSize & ".

Do you want to open the output folder?
" buttons {"No", "Yes"} default button "Yes"
	end timeout
end tell

if button returned of the result is "Yes" then
	tell application "Finder"
		open (folderToSaveResultingFiles as POSIX file)
		-- Bring Finder window to foreground:		
		activate
		-- Enlarging the Finder window to my preferred size:
		-- From: http://apple.stackexchange.com/a/268667/184907
		set bounds of front window to {161, 49, 1260, 740}
	end tell
	
else if button returned of the result is "No" then
	error number -128 (* cancels script *)
end if



on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars



on convertSecondsToHoursAndMinutes(timeInSeconds)
	
	-- Convert seconds to minutes and hours:
	-- From: http://wiki.indigodomo.com/doku.php?id=applescript_snippit
	
	set theHours to (timeInSeconds div hours)
	set theRemainderSeconds to (timeInSeconds mod hours)
	set theMinutes to (theRemainderSeconds div minutes)
	set theRemainderSeconds to (theRemainderSeconds mod minutes)
	
	set theTimeString to theHours & ":" & theMinutes & ":" & theRemainderSeconds as text
	
	
	if (character 1 of theTimeString is "0") or (character 1 of theTimeString is ":") then
		set theFirstCharIsAColonOrZero to true
	else
		set theFirstCharIsAColonOrZero to false
	end if
	
	
	repeat until (theFirstCharIsAColonOrZero is false)
		-- Removing the first character of the string:
		set theTimeString to ((characters 2 thru -1 of theTimeString) as string)
		
		if (character 1 of theTimeString is "0") or (character 1 of theTimeString is ":") then
			set theFirstCharIsAColonOrZero to true
		else
			set theFirstCharIsAColonOrZero to false
		end if
	end repeat
	
	set tempStorage to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set colonCount to (count theTimeString's text items) - 1
	set AppleScript's text item delimiters to tempStorage
	
	
	if (colonCount is 1) then
		-- Splitting text based on a specific character
		-- From: http://macscripter.net/viewtopic.php?id=24473
		set tempStorage to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ":"
		set theTimeStringInAList to theTimeString's text items
		set AppleScript's text item delimiters to tempStorage
		
		set minutesFig to item 1 of theTimeStringInAList
		set secondsFig to item 2 of theTimeStringInAList
		
		set theWordExactlyShouldPrecedeTheMinuteFig to false
		
		if (minutesFig as number is less than 2) then
			set minutesUnitInCorrectPluralState to "minute"
		else
			set minutesUnitInCorrectPluralState to "minutes"
		end if
		set minutesWithUnit to minutesFig & " " & minutesUnitInCorrectPluralState
		
		
		if (secondsFig as number is less than 2) then
			if (secondsFig as number is 0) then
				set secondsFig to ""
				set secondsUnitInCorrectPluralState to ""
				set theWordExactlyShouldPrecedeTheMinuteFig to true
			else
				set secondsUnitInCorrectPluralState to " second"
				set secondsFig to ", " & secondsFig
			end if
		else
			set secondsUnitInCorrectPluralState to " seconds"
			set secondsFig to ", " & secondsFig
		end if
		
		set secondsWithUnit to secondsFig & secondsUnitInCorrectPluralState
		
		set timeStringToDisplay to minutesWithUnit & secondsWithUnit
		
		if theWordExactlyShouldPrecedeTheMinuteFig is true then
			set timeStringToDisplay to "exactly " & timeStringToDisplay
		end if
		
	else if (colonCount is 2) then
		-- Splitting text based on a specific character
		-- From: http://macscripter.net/viewtopic.php?id=24473
		set tempStorage to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ":"
		set theTimeStringInAList to theTimeString's text items
		set AppleScript's text item delimiters to tempStorage
		
		set hoursFig to item 1 of theTimeStringInAList
		set minutesFig to item 2 of theTimeStringInAList
		set secondsFig to item 3 of theTimeStringInAList
		
		set theWordExactlyShouldPrecedeTheMinuteFig to false
		set theWordExactlyShouldPrecedeTheHourFig to false
		
		if (hoursFig as number is less than 2) then
			set hoursUnitInCorrectPluralState to "hour"
		else
			set hoursUnitInCorrectPluralState to "hours"
		end if
		set hoursWithUnit to hoursFig & " " & hoursUnitInCorrectPluralState
		
		
		if (minutesFig as number is less than 2) then
			if (minutesFig as number is 0) then
				set minutesFig to ""
				set minutesUnitInCorrectPluralState to ""
				set theWordExactlyShouldPrecedeTheHourFig to true
			else
				set minutesUnitInCorrectPluralState to " minute"
				set minutesFig to ", " & minutesFig
			end if
		else
			set minutesUnitInCorrectPluralState to " minutes"
			set minutesFig to ", " & minutesFig
		end if
		set minutesWithUnit to minutesFig & minutesUnitInCorrectPluralState
		
		
		if (secondsFig as number is less than 2) then
			if (secondsFig as number is 0) then
				set secondsFig to ""
				set secondsUnitInCorrectPluralState to ""
				set theWordExactlyShouldPrecedeTheHourFig to true
			else
				set secondsUnitInCorrectPluralState to " second"
				set secondsFig to ", and " & secondsFig
			end if
		else
			set secondsUnitInCorrectPluralState to " seconds"
			set secondsFig to ", and " & secondsFig
		end if
		set secondsWithUnit to secondsFig & secondsUnitInCorrectPluralState
		
		
		
		set timeStringToDisplay to hoursWithUnit & minutesWithUnit & secondsWithUnit
		
		if theWordExactlyShouldPrecedeTheHourFig is true then
			set timeStringToDisplay to "exactly " & timeStringToDisplay
		end if
	end if
	
	return timeStringToDisplay
	
end convertSecondsToHoursAndMinutes




on convertByteSize(byteSize, KBSize, decPlaces)
	-- Convert byte size to MG size.
	-- From: Post #1 in this thread: http://macscripter.net/viewtopic.php?id=37035
	if (KBSize is missing value) then set KBSize to 1000 + 24 * (((system attribute "sysv") < 4192) as integer)
	
	if (byteSize is 1) then
		set conversion to "1 byte" as Unicode text
	else if (byteSize < KBSize) then
		set conversion to (byteSize as Unicode text) & " bytes"
	else
		set conversion to "Oooh lots!" -- Default in case yottabytes isn't enough!
		set suffixes to {" K", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"}
		set dpShift to ((10 ^ 0.5) ^ 2) * (10 ^ (decPlaces - 1)) -- (10 ^ decPlaces) convolutedly to try to shake out any floating-point errors.
		repeat with p from 1 to (count suffixes)
			if (byteSize < (KBSize ^ (p + 1))) then
				tell ((byteSize / (KBSize ^ p)) * dpShift) to set conversion to (((it div 0.5 - it div 1) / dpShift) as Unicode text) & item p of suffixes
				exit repeat
			end if
		end repeat
	end if
	
	return conversion
end convertByteSize