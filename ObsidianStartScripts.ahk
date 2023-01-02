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
	; f_CreateTrayMenu(VN) 
	OnMessage(0x404, "f_reload")
	#Include <scriptobj>
	global script := { base : script
		,name : regexreplace(A_ScriptName, "\.\w+")
		,version : "1.1.1"
		,author : "Gewerd Strauss"
		,authorlink : ""
		,email : ""
		,credits : ""
		,creditslink : ""
		,crtdate : "12.01.2022"
		,moddate : ""
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
		,configfile : regexreplace(A_ScriptName, "\.\w+") ".ini"
		,configfolder : A_ScriptDir "\INI-Files\"
		,vAHK	 : A_AhkVersion}	
if WinActive("Visual Studio Code")	; if run in vscode, deactivate notify-messages to avoid crashing the program.
	global bRunNotify:=!vsdb:=1
else
	global bRunNotify:=!vsdb:=0
FileRead, ThisFile, % A_ScriptFullPath
txt=
(
Hotstrings:
obsidian.run.cleanassets - clean assets
obsidian.set.cleanassets - open settings
obsidian.run.syncVault - sync Vaults
)
retVal:=fExtractHotKeysHotStringsAndComments(thisFile)
; m(retVal)
retVal:=fExtractHotKeysHotStringsAndComments(thisFile)
; m(retVal)
menu, tray, tip, % txt
Programs:={ Discord : "C:\Users\Claudius Appel\AppData\Local\Discord\Update.exe  --processStart Discord.exe"
			,Spot: "Spotify.exe"
			,mailp: "C:/Program%20Files/Mozilla%20Thunderbird/thunderbird.exe"}
return
;}______________________________________________________________________________________
;{#[Hotkeys Section]
#if Winactive("- Obsidian v") and Winactive("ahk_exe Obsidian.exe")
:*C0:obsidian.run.cleanAssets::  ; run ObsidianAssetCleaner
run, %A_ScriptDir%\ObsidianAssetsCleaner.ahk
return
:*C0:obsidian.set.cleanAssets:: ; open settings for ObsidianAssetCleaner
run, %A_ScriptDir%\INI-Files\ObsidianAssetsCleaner.ini
return

:*C0:obsidian.run.syncVault:: ; run ObsidianVaultSync
run, %A_ScriptDir%\ObsidianVaultSync.ahk
return
; Capslock & g::
str:=fClip()
str2:=(substr(str,1,1)="#"?"":"#") strreplace(str," ","-")
fclip(str2)
; ~+!^*F1:: 						;; this is a comment
:C0:obsidian.help:: 
retVal:=[]
str:=""
symbolControl:="^"
symbolWin:="#"
symbolAlt:="!"
symbolShift:="+"

for k,v in retVal[2,1]
{
	str.=v
}
return
:*:@::							; open program based on name and key
Input,Embed, ,@

Path:=Programs[Embed]
ttip(Embed "|"  Path )
run,% Path 
; run, % "C:\@C:\Users\Claudius Appel\AppData\Local\Discord\Update.exe  --processStart Discord.exeart Discord.exe
fClip("@" "[" Embed "](file:///" strreplace(Path,"\","/") ")")
; m(Path)
return
#If


;}______________________________________________________________________________________
;{#[Label Section]


return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
script.about()
return
;}______________________________________________________________________________________
;{#[Functions Section]



;}_____________________________________________________________________________________
;{#[Include Section]
fExtractHotKeysHotStringsAndComments(sFileContent)
{
	aFileLines:=strsplit(sFileContent,"`n")
	HotKeys:=[[],[]]
	HotStrings:=[[],[]]
	IndHotString:=0
	IndHotKey:=0
	for _,Line in aFileLines
	{
		sComment:=""
		if !RegexMatch(Line,"(?<Hotstuff>.*)`:`:(?:.*(?:`;(?<Comment>.*)?))?",s)
			continue
		if (substr(sHotStuff,1,1)=";")		; don't include deactivated lines.
			continue
		if instr(sHotStuff,":")
		{
			;; we are matching a hotstring, so trim off the options from the hs itself.
			HS:=(instr(sHotStuff,"`:`:")?substr(sHotStuff,3):substr(sHotStuff,instr(sHotStuff,":",,2)+1))
			Hotstrings.1.push(HS)
			Hotstrings.2.push((sComment!=""?Trim(sComment):Trim(sComment))) ; why does trim leave the `r in the string?
			d:=substr(sComment,1,strlen(sComment)-1)	
		}
		else
		{
			;; we are matching a hotkey, so convert the options (later?)
			HotKeys.1.push(sHotStuff)
				HotKeys.2.push((sComment!=""?Trim(sComment):Trim(sComment)))
		}

	}
	; "(?<Section>.*)\:\:\s*(\;)*(?<Desc>.*)?" 
	return [HotKeys,HotStrings]
}
f_CreateStaticTextFromHotKeysHotStringsAndComments(oArray)
{

}

;}_____________________________________________________________________________________
st_count(string, searchFor="`n")
{
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}
