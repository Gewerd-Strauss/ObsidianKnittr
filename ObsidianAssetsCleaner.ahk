	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	#SingleInstance,Force
	#Persistent
	;#Warn All  ; Enable warnings to assist with detecting common errors.
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,63 ;Set custom Script icon
	;DetectHiddenWindows, On
	;SetKeyDelay -1
	SetBatchLines -1
	SetTitleMatchMode, 2
	f_CreateTrayMenu(VN)
	OnMessage(0x404, "f_TrayIconSingleClickCallBack")
	#Include <scriptobj>
	global script := { base : script
		,name : regexreplace(A_ScriptName, "\.\w+")
		,version : "1.4.2"
		,author : "Gewerd Strauss"
		,authorlink : ""
		,email : ""
		,credits : ""
		,creditslink : ""
		,crtdate : "10.01.2022"
		,moddate : "11.01.2022"
		,homepagetext : ""
		,homepagelink : ""
		,ghtext 	 : "My GitHub"
		,ghlink		 : "https://github.com/Gewerd-Strauss"
		,doctext : ""
		,doclink	 : ""
		,forumtext 	 : ""
		,forumlink	 : ""
		,donateLink : ""
		;~ ,resfolder    : A_ScriptDir "\res"
		;~ ,iconfile     : A_ScriptDir "\res\sct.ico"
		,config:	[]
		,configfile : regexreplace(A_ScriptName, "\.\w+") ".ini"
		,configfolder : A_ScriptDir "\INI-Files\"
		,vAHK	 : A_AhkVersion}	

	Gui, Margin, 16, 16
	Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC
	cForeground := "c" . "c5c8c6"
	gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
	cBlue := "c" . "81a2be"
	Gui, Color, 1d1f21, 373b41, 
	Gui, Font, s11 cWhite, Segoe UI 
	GuiWidth:=330
	GuiHeight:=130
	GuiTextWidth:=380
	gui, add, text, x12 w%GuiTextWidth% vHeadText, -1
	Gui, Font, s10 cWhite, Segoe UI 
	gui, add, text,w%GuiTextWidth% vSubText, -2
	xpos:=A_ScreenWidth-GuiWidth-30
	ypos:=A_ScreenHeight-GuiHeight-30
	gui, add, Progress, w300 h20 cBlue vProgress,0
	
	IniTemplate=
	( LTRIM
	[Vault-Directories]

	[Settings]
	DisplayGUI=1
	FastGui=1
	TargetSpecificSubfolders=assets,
	MoveToObsidianTrashInsteadOfNormalTrash=0
	)
	sHowToText=
	( LTRIM
		No configuration found. To set up, please open the config-file and 
		insert any desired absolute/full path in below "[Vault-Directories], and above [Settings]".


		Settings:

		DisplayGUI: set to "0" to hide the gui. Can increase speed.

		FastGUI: speed up the GUI considerably. 
		TargetSpecificSubfolders: a comma-separated list of folders in the directory of **each markdown-file** to be searched. All folders not present in this list are skipped.

		MoveToObsidianTrashInsteadOfNormalTrash: Set to true to move any file to the .trash-folder of the respective vault. Note that files already present in that folder get overwritten, and that files cannot easily be moved back to their initial location, as there is no "Restore file"-option in the .trash-folder.

		---

		The script will exit now. Please add the paths necessary to the config-file, then start the script again.
	)
	ProgressStrings=
	( LTRIM
	Loading Settings| 
	Finding Vaults|%CurrentVault%
	Collecting Files|%CurrentFile%
	Looking for References|%CurrentFile%
	Collecting Files to Delete|
	Deleting unreferenced Files|%CurrentFile%
	Finished|All non-referenced files deleted.
	Finished|No additional files found.
	)

	if !InStr(FileExist(script.configfolder),"D")
		FileCreateDir, % script.configfolder
	if !FileExist(script.configfolder script.configfile)
	{
		FileAppend, %IniTemplate%,% script.configfolder script.configfile
		MsgBox, 65, % script.name ": No configuration found.",% sHowToText
		IfMsgBox, Ok
		{
			run, % script.configfolder script.configfile
			ExitApp, 
		}
		Else	
		{
			msgbox,, % "Exiting " script.name "...", % "Script cannot start because valid configuration isn't present. Exiting script now. Please try again."
			ExitApp
		}

	}
	Else
	{
		FileRead, CurrentStateINI, % script.configfolder script.configfile
		CurrentstateINI:=strreplace(CurrentStateINI,"`r","")
		if (CurrentStateINI=IniTemplate)
		{
			MsgBox, 65, % script.name ": No configuration found.",% sHowToText
			IfMsgBox, Ok
			{
				run, % script.configfolder script.configfile
				ExitApp, 
			}
			else
				ExitApp, 
		}
		else
			IniObj:=fReadINI(script.configfolder script.configfile)
	}


	
	CodeTimer("Hi")
	global MsgIndex:=1
	global ProgressMessages:=[]
	Texts:=strsplit(ProgressStrings,"`n")
	for k,v in Texts
	{
		ProgressMessages[k]:=strsplit(v,"|")
	}
	IniObj:=fReadINI(script.configfolder script.configfile)
	if IniObj["Settings"].DisplayGUI
		f_UpdateProgress(1,0)

	if IniObj["Settings"].DisplayGUI
		gui, Show,x%xpos% y%ypos% w%GuiWidth% h%GuiHeight%, M
	if IniObj["Settings"].DisplayGUI
		loop, 5
		{
			f_UpdateProgress(1,20,"+")
			if !IniObj["Settings"].FastGui
				sleep, 70
		}
	if IniObj["Settings"].DisplayGUI
		f_UpdateProgress(2,0)
	aObsidianPaths:=fGetObsidianPaths(IniObj,true)

	vDeletions:=0
	if IniObj["Settings"].DisplayGUI
		f_UpdateProgress(3,0)
	NumberOfDeletedFiles:=0	
	aToDelete:=[]
	for k,CurrentVault in aObsidianPaths 
	{
		afiles := []
		FileTypes:=[]
		images := {}
		yourPath:=CurrentVault ;"200 Subjects"
		loop files, % yourPath "\*.md", FR  
		{
			afiles.Push(A_LoopFileLongPath)
			if IniObj["Settings"].DisplayGUI
				f_UpdateProgress(3,0,,A_LoopFileName)
		}                

		; regex := "i)[\/\\]\K[^\/\\]+\.png"
		; regex := "(?i)[^\[\/]+\.(?:jpg|gif|png|etc)"
		;    regex := "(?i)[^\[\/]+\.(?:jpg|gif|png|webm|pdf|etc)"
		regex := "(?:\]\(|\[\[)(.*?\.(?:gif|jpg|png|pdf|webm))(?: "".*"")?(?:\)|\]\])"
		MaxIndex:=afiles.MaxIndex()
		for _,file in afiles 
		{
			FileRead buffer, % file
			p := 1
			while p := RegExMatch(buffer, regex, match, p) 
			{
				if IniObj["Settings"].DisplayGUI
					f_UpdateProgress(4,,,match)
				images[match] := true
				tmpArr:=strsplit(match,".")
				FileTypes.push(tmpArr[tmpArr.MaxIndex()])
				if IniObj["Settings"].DisplayGUI
					f_UpdateProgress(4,-1)
				p += StrLen(match)
			}
		}
		for _,file in afiles 
		{
			SplitPath, file  ,  , CurrentPath
			for x,y in % strsplit(IniObj["Settings"].TargetSpecificSubfolders,",")
			{
				if (y="")
					continue
				loop files, % CurrentPath "\" y "\*"
				{
					if !images.HasKey(A_LoopFileName) ;; Files aren't found in any .md file
					{
						cnt:=0
						for s,w in images
						{
							key:=StrReplace(s,"/","\")
							key:=StrReplace(key,"[")
							key:=StrReplace(key,"]")
							if Instr(A_LoopFileFullPath,key)
							{
								cnt++
								break
							}
						}
						if !cnt		;; if the current file is not a key to images, and no key of images is a substring of the current filepath, delete
						{
							if Instr(A_LoopFileFullPath,".md")
								continue
							
							if IniObj["Settings"].DisplayGUI
								f_UpdateProgress(5,0,,A_LoopFileName)
							aToDelete.push(A_LoopFileFullPath)
						}
					}
				}
			}
		}   
		sCurrentObsidianTrash:=CurrentVault ".trash\"
		CodeTimer("hi")
		for m,n in aToDelete
		{
			SplitPath, n, Name
			if IniObj["Settings"].DisplayGUI
				f_UpdateProgress(6,0,,Name)
			if IniObj["Settings"].MoveToObsidianTrashInsteadOfNormalTrash
				FileMove,% n, % sCurrentObsidianTrash ,1 ; move to vault-specific .trash-folder
			Else
				FileRecycle, % n
		}
	}
	NumberOfDeletedFiles+=aToDelete.MaxIndex()	
	if IniObj["Settings"].DisplayGUI
		f_UpdateProgress((NumberOfDeletedFiles?7:8),0)
	sleep, 2500
	Gui, 1: destroy
	str:=""
	str:=(NumberOfDeletedFiles?NumberOfDeletedFiles:"") (NumberOfDeletedFiles?" unrelevant files "(IniObj["Settings"].MoveToObsidianTrashInsteadOfNormalTrash?"moved to the respective trash-folder":"moved to th recycling bin") " from assets of the following Vaults:`n`n" regexreplace(Object2String(IniObj["Vault-Directories"]),"\.\d*\s\=\s","") "`n`nThe program has finished.":"") "The program has finished."
 	if (str!="")
		msgbox,0x0, % script.Name, % str  
	ExitApp
	return

	fGetObsidianPaths(IniObj,InsertParentInstead:=false)
	{ ; assemble paths to vaults from ini file
		ObsidianPath:=[]
		NumVaults:=IniObj["Vault-Directories"].MaxIndex()
		for k,v in IniObj["Vault-Directories"]
		{
			VaultInfo:=Strsplit(v,"\")
			VaultName:=VaultInfo[VaultInfo.MaxIndex()]
			if (VaultName="")
				VaultName:=VaultInfo[VaultInfo.MaxIndex()-1]
			f_UpdateProgress(2,(1/NumVaults)*100,"+",VaultName)
			ObsidianPath.push(v (InsertParentInstead?"":((SubStr(v,0,10)==".obsidian\")?:".obsidian\") ))
			if !IniObj["Settings"].FastGui
				sleep, 70
		}
		return ObsidianPath
	}

	fGetFoldersContainingNeedle(root,needle:="",mode=2)
	{
		if (mode=1)
		dir:= root . (subStr(root,0,1)="\"?:"\")
		else if (mode=2)
			dir:=root
		paths:=[]
		loop, files,%dir%* ,DR
		{
			if !Instr(A_LoopFileFullPath,needle)
				continue
			paths.push(A_LoopFileFullPath)
		}
		return paths
	}

	f_UpdateProgress(Index,BarValue:="",PlusMinus:="",Param4:="")
	{
		if !IniObj["Settings"].FastGui
			sleep, 70
		guicontrol,,HeadText, % d:=ProgressMessages[Index,1]
		str:=(ProgressMessages[Index,2]!=""?ProgressMessages[Index,2]:Param4)
		guicontrol,,SubText, % str
		if (BarValue!="") && (BarValue!=-1)
		{
			if (PlusMinus!="")
				guicontrol,,Progress, % PlusMinus BarValue   
			Else
				guicontrol,,Progress, % BarValue
			if !IniObj["Settings"].FastGui
				sleep, 70
		}
		else if (BarValue==-1)
			guicontrol,,Progress,0
		else
		{
			loop, 25
				guicontrol,,Progress,+4
		}
		return
	}

	Object2String(Obj,FullPath:=1,BottomBlank:=0)
	{
		static String,Blank
		if(FullPath=1)
			String:=FullPath:=Blank:=""
		if(IsObject(Obj)){
			for a,b in Obj{
				if(IsObject(b))
					Object2String(b,FullPath "." a,BottomBlank)
				else{
					if(BottomBlank=0)
						String.=FullPath "." a " = " b "`n"
					else if(b!="")
						String.=FullPath "." a " = " b "`n"
					else
						Blank.=FullPath "." a " =`n"
				}
		}}
		return String Blank
	}


	fReadINI(INI_File,bIsVar=0) ; return 2D-array from INI-file, or alternatively from a string with the same format.
	{
		Result := []
		if !bIsVar ; load a simple file
		{
			SplitPath, INI_File,, WorkDir
			OrigWorkDir:=A_WorkingDir
			SetWorkingDir, % WorkDir
			IniRead, SectionNames, %INI_File%
			for each, Section in StrSplit(SectionNames, "`n") {
				IniRead, OutputVar_Section, %INI_File%, %Section%
				for each, Haystack in StrSplit(OutputVar_Section, "`n")
				{
					if (Instr(Haystack, "="))
					{
						RegExMatch(Haystack, "(.*?)=(.*)", $)
					, Result[Section, $1] := $2
					}
					else			;; path for pushing just values, without keys into ordered arrays. Be aware that no error prevention is present, so mixing assoc. and linear array - types in the middle of an array will result in erroneous structures. ALso, this is not yet implemented for string-feeding
						Result[Section,each]:=Haystack
				}
			}
			if A_WorkingDir!=OrigWorkDir
				SetWorkingDir, %OrigWorkDir%
		}
		else ; convert string
		{
			Lines:=StrSplit(bIsVar,"`n")
			; Arr:=[]
			bIsInSection:=false
			for k,v in lines
			{
				
				If SubStr(v,1,1)="[" && SubStr(v,StrLen(v),1)="]"
				{
					SectionHeader:=SubStr(v,2)
					SectionHeader:=SubStr(SectionHeader,1,StrLen(SectionHeader)-1)
					bIsInSection:=true
					currentSection:=SectionHeader
				}
				if bIsInSection
				{
					RegExMatch(v, "(.*?)=(.*)", $)
					if ($2!="")
						Result[currentSection,$1] := $2
				}
			}
		}
		return Result
		/* Original File from https://www.autohotkey.com/boards/viewtopic.php?p=256714#p256714
		;-------------------------------------------------------------------------------
			ReadINI(INI_File) { ; return 2D-array from INI-file
		;-------------------------------------------------------------------------------
				Result := []
				IniRead, SectionNames, %INI_File%
				for each, Section in StrSplit(SectionNames, "`n") {
					IniRead, OutputVar_Section, %INI_File%, %Section%
					for each, Haystack in StrSplit(OutputVar_Section, "`n")
						RegExMatch(Haystack, "(.*?)=(.*)", $)
				, Result[Section, $1] := $2
				}
				return Result
		*/
	}


	f_CreateTrayMenu(IniObj)
	{ ; facilitates creation of the tray menu
		menu, tray, add,
		Menu, Misc, add, Open Script-folder, lOpenScriptFolder
		; Menu, Misc, add, Search for GHS changes , lUpdateLibrary
		menu, Misc, Add, Reload, lReload
		menu, Misc, Add, About, Label_AboutFile
		; menu, Misc, Add, How to use it, lExplainHowTo
		SplitPath, A_ScriptName,,,, scriptname
		Menu, tray, add, Miscellaneous, :Misc
		menu, tray, add,
		return
	}

	Label_AboutFile:
	script.about()
	return
	lOpenScriptFolder:
	run, % A_ScriptDir
	return
	lReload: 
	reload
	return
	; lUpdateLibrary:
	; ; FileDelete, % script.configfile
	; reload

	f_TrayIconSingleClickCallBack(wParam, lParam)
	{ ; taken and adapted from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
		VNI:=1.0.3.12
		; 0x201 WM_LBUTTONDOWN
		; 0x202 WM_LBUTTONUP
		if (lParam = 0x202) || (lParam = 0x201)
		{
			menu, tray, show
			return 0
		}
	}
