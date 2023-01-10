#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
;#Persistent
;#Warn All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;DetectHiddenWindows, On
;SetKeyDelay -1
SetBatchLines -1
SetTitleMatchMode, 2
; ntfy:=Notify()
;;_____________________________________________________________________________________
;{#[General Information for file management]
ScriptName=MISSING 
VN=1.0.1.1                                                                    
LE=20 März 2021 17:51:52                                                       
AU=Gewerd Strauss
;}______________________________________________________________________________________
;{#[File Overview]
Menu, Tray, Icon, C:\WINDOWS\system32\imageres.dll,101 ;Set custom Script icon
menu, Tray, Add, About, Label_AboutFile
;}______________________________________________________________________________________
;{#[Autorun Section]
if WinActive("Visual Studio Code")	; if run in vscode, deactivate notify-messages to avoid crashing the program.
	global bRunNotify:=!vsdb:=1
else
	global bRunNotify:=!vsdb:=0

Paths:=fGetFoldersContainingNeedle("D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\Download Lecture Slides for R&R\Obsidian NoteTaking\University\Subjects")
;}______________________________________________________________________________________
;{#[Hotkeys Section]
return

fGetFoldersContainingNeedle(root ,needle:="assets")
{
	d:= root . (subStr(root,0,1)="\"?:"\")
	paths:=[]
 	loop, files,%d%* ,DR
	{
  		; m(A_LoopFileName,A_LoopFileShortPath)
		if !Instr(A_LoopFileFullPath,needle)
			continue
		paths.push(A_LoopFileFullPath)
	}
	return paths
}

;}______________________________________________________________________________________
;{#[Label Section]


return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
MsgBox,, File Overview, Name: %ScriptName%`nAuthor: %AU%`nVersionNumber: %VN%`nLast Edit: %LE%`n`nScript Location: %A_ScriptDir%
return
;}______________________________________________________________________________________
;{#[Functions Section]



;}_____________________________________________________________________________________
;{#[Include Section]



;}_____________________________________________________________________________________
