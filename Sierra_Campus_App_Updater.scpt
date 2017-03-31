display dialog "This Application will update Vassar College licensed software for macOS Sierra" with icon note buttons {"OK", "Quit"} default button 1
if the button returned of the result is "OK" then
	do shell script "./Software_Updates/Packages/disableOfficeFirstRun.sh" with administrator privileges and password
	do shell script "launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
	do shell script "/usr/bin/chflags nohidden $HOME/Library"
	do shell script "defaults write -g AppleShowScrollBars -string Always"
	do shell script "defaults write -g com.apple.swipescrolldirection -bool FALSE"
	do shell script "defaults write com.apple.finder ShowStatusBar -bool true"
	set dest_folder to quoted form of POSIX path of ((path to application support from local domain as text) & "CrashPlan:conf:custom.properties")
	set source_folder to quoted form of POSIX path of "Macintosh HD:Software_Updates:Packages:.Custom:custom.properties"
	do shell script "ditto -rsrc " & source_folder & " " & dest_folder with administrator privileges and password
	set progress description to "Installing Samanage Agent"
	set progress additional description to "Installing Packages..."
	do shell script "/Software_Updates/Packages/Samanage_Agent_1.1.65_osx_installer.app/Contents/MacOS/installbuilder.sh --mode unattended" with administrator privileges and password
	set filesFound to {}
	set filesFound2 to {}
	set nextItem to 1
	tell application "Finder"
		set updatePackages to name of every file of folder "Packages" of folder "Software_Updates" of startup disk whose name extension is "pkg" --change path to whatever path you want   
	end tell
	
	--loop used for populating list filesFound with all filenames found (name + extension)
	repeat with i in updatePackages
		set end of filesFound to (item nextItem of updatePackages)
		set nextItem to (nextItem + 1)
	end repeat
	
	set nextItem to 1 --reset counter to 1
	
	--loop used for pulling each filename from list filesFound and then strip the extension   
	--from filename and populate a new list called filesFound2
	repeat with i in filesFound
		set myFile2 to item nextItem of filesFound
		set myFile3 to text 1 thru ((offset of "." in myFile2) - 1) of myFile2
		set end of filesFound2 to myFile3
		set nextItem to (nextItem + 1)
	end repeat
	set thePackages to filesFound
	-- Update the initial progress information
	set packageCount to length of thePackages
	set progress total steps to packageCount
	set progress completed steps to 0
	set progress description to "Preparing to install."
	set progress additional description to "Installing Packages..."
	repeat with a from 1 to length of thePackages
		set theCurrentListItem to item a of thePackages
		set theCurrentListItem2 to item a of filesFound2
		set niceDisplay to theCurrentListItem2
		set niceDisplay to do shell script "echo " & quoted form of niceDisplay & ¬
			" | sed -e 's/_/ /g'"
		set progress description to "Installing " & niceDisplay
		-- Process the current list item
		do shell script "installer -pkg /Software_Updates/Packages/" & theCurrentListItem & " -target /" with administrator privileges and password
		set progress description to "Installing " & niceDisplay
		set progress completed steps to a
	end repeat
	display notification [packageCount] & " Packages Were Installed" as string
	-- Reset the progress information
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to [packageCount] & " Packages Were Installed" as string
else
	do shell script "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist" with administrator privileges and password
	error number -128 (* user cancelled *)
end if
display dialog "Would You like to update the Microsoft Office Dock icons?" with icon note buttons {"Yes", "No"} default button 1
if button returned of result is "Yes" then
	set officePath to "Macintosh HD:Applications:Microsoft Office 2011:"
	set officePosixPath to POSIX path of officePath
	set wordReplacePath to "/Applications/Microsoft Word.app"
	set excelReplacePath to "/Applications/Microsoft Excel.app"
	set wordReplacePosixPath to POSIX path of wordReplacePath
	set excelReplacePosixPath to POSIX path of excelReplacePath
	do shell script "python /Software_Updates/Packages/dock-icon-remove.py -r " & officePosixPath with administrator privileges and password
	do shell script "python /Software_Updates/Packages/dockutil.py --add " & quoted form of wordReplacePosixPath & " --position 5"
	do shell script "python /Software_Updates/Packages/dockutil.py --add " & quoted form of excelReplacePosixPath & " --position 6"
else
	do shell script "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist" with administrator privileges and password
	error number -128 (* user cancelled *)
end if
display dialog "Would You like to Run Apple Software Update?" with icon note buttons {"Yes", "Quit"} default button 1
if button returned of result is "yes" then
	set a to (do shell script "softwareupdate -l > ~/Public/SU-List.txt")
	
	--  save the current TID in oldtid and set the TID to return (the char we want to break the string at)
	set {oldtid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, return}
	
	-- create  list, b, from each text item in the string a. As the TID is set to the character return the string is broken at each
	-- return
	set b to do shell script "tail -n +6 ~/Public/SU-List.txt > ~/Public/SU-Trim.txt"
	set c to do shell script "cat ~/Public/SU-Trim.txt"
	set d to c as string
	set e to do shell script "sed -n '5p' ~/Public/SU-List.txt"
	set f to e as string
	-- Now set the TID back to want it was. Just a good pratice to get into so you don;t mess yourself up later on.
	set AppleScript's text item delimiters to oldtid
else
	do shell script "rm -rf /Software_Updates/Packages/" with administrator privileges and password
	do shell script "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
	error number -128 (* user cancelled *)
end if
display alert f message d buttons {"Update", "Quit"} default button 1
if button returned of result is "Update" then
	display notification "You will be notified when the updates have completed." with title "Apple Software Update is running" sound name "Sosumi"
	do shell script "softwareupdate -ia" with administrator privileges and password
	do shell script "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist" with administrator privileges and password
else
	do shell script "rm -rf /Software_Updates/Packages/" with administrator privileges and password
	do shell script "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
	error number -128 (* user cancelled *)
end if
