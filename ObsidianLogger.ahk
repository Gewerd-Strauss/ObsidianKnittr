#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
#MaxHotkeysPerInterval, 99999999
;#Persistent 
 ;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
SetKeyDelay -1,-1
SetBatchLines,-1
SetTitleMatchMode, 2
#Include, <ScriptObj/ScriptObj>
/*
for creditsRaw, use "/" in the "URL"-field when the snippet is not published yet (e.g. for code you've written yourself and not published yet)
space author, SnippetNameX and URLX out by spaces or tabs, and remember to include "-" inbetween both fields
when 2+ snippets are located at the same url, concatenate them with "|" and treat them as a single one when putting together the URL's descriptor string
finally, make sure toingest 'CreditsRaw' into the 'credits'-field of the template below.
*/
CreditsRaw=
(LTRIM
author1   -		 snippetName1		   		  			-	URL1
author2,author3   -		 snippetName1		   		  			-	URL2,URL3
ScriptObj  							- Gewerd S, original by RaptorX							    - https://github.com/Gewerd-Strauss/ScriptObj/blob/master/ScriptObj.ahk, https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
)
FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)

global script := {   base         : script
                    ,name         : regexreplace(A_ScriptName, "\.\w+")
                    ,version      : ""
                    ,author       : "Gewerd Strauss"
					,authorID	  : "Laptop-C"
					,authorlink   : ""
                    ,email        : ""
                    ,credits      : CreditsRaw
					,creditslink  : ""
                    ,crtdate      : CrtDate
                    ,moddate      : ModDate
                    ,homepagetext : ""
                    ,homepagelink : ""
                    ,ghtext 	  : "GH-Repo"
                    ,ghlink       : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME"
                    ,doctext	  : ""
                    ,doclink	  : ""
                    ,forumtext	  : ""
                    ,forumlink	  : ""
                    ,donateLink	  : ""
                    ,resfolder    : A_ScriptDir "\res"
                    ,iconfile	  : ""
;					  ,reqInternet: false
					,rfile  	  : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME/archive/refs/heads/BRANCH_NAME.zip"
					,vfile_raw	  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
					,vfile 		  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
					,vfile_local  : A_ScriptDir "\version.ini" 
;					,DataFolder:	A_ScriptDir ""
                    ,config:		[]
					,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
                    ,configfolder : A_ScriptDir "\INI-Files"}
/*	
	For throwing errors via script.debug
	script.Error:={	 Level		:""
					,Label		:""
					,Message	:""	
					,Error		:""		
					,Vars:		:[]
					,AddInfo:	:""}
	if script.error
		script.Debug(script.error.Level,script.error.Label,script.error.Message,script.error.AddInfo,script.error.Vars)
*/

main()
return

main()
{
	if !script.load()
	{
		msgbox, "error not implemented: config not found"
	}
	out:=guiShow()
    Logs:=ProcessLogs(out)
    ;Clipboard:=Logs[202301082004,0]
    ReAssembly:=reassemble(Logs,"DaysDescending_HoursDescending") 
    ReAssembly2:=reassemble(Logs,"DaysDescending_HoursAscending") 
}


reassemble(Logs,Direction:="DaysDescending_HoursAscending")
{
    AssembledText:=""
    Ind:=0
    Days:=reassemble_Days(Logs,Direction)
    for k,v in Days
    {
        Backwards:=GetBackwardsCorrectIndex(Logs,Ind)
        if (Direction="DaysDescending_HoursAscending") ;; Newest day first, oldest day last
            AssembledText:=AssembledText "`n" Backwards[0]
        else
            AssembledText:= Backwards[0] "`n" AssembledText

        Ind++
    }
    Clipboard:=AssembledText
    return AssembledText
}
GetBackwardsCorrectIndex(Logs,Index)
{
    Ind:=1
    MaxInd:=Logs.MaxIndex()-Index
    for k,v in Logs
    {
        if (Ind++==MaxInd)
            return v
    }
}
reassemble_Days(Logs,Direction)
{
    AssembledDays:=[]
    Ind:=0
    MaxInd:=Logs.MaxIndex()
    for k,v in Logs
    {
        Backwards:=Logs[Logs.MaxIndex()-Ind]
        ElementIndex:=(Direction="DaysDescending_HoursAscending"?k:Backwards-Ind)
        if (Direction="DaysDescending_HoursAscending")
            AssembledDays[Trim(SubStr(v.TimeSort,1,8))].=  Trim(v.0) ;; "`n" Trim(v.Time) ":  `n"
        else if (Direction="DaysDescending_HoursDescending")
            AssembledDays[Trim(SubStr(v.TimeSort,1,8))]:=  Trim(v.0) AssembledDays[Trim(SubStr(v.TimeSort,1,8))]
        Ind++
    }
        ;Clipboard:=AssembledDays[AssembledDays.MaxIndex()]
    return AssembledDays
}

guiCreate()
{
    global
    PotentialOutputs:=["All","html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document"]
    gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
    Gui, Margin, 16, 16
    Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC
    cBackground := "c" . "1d1f21"
    cCurrentLine := "c" . "282a2e"
    cSelection := "c" . "373b41"
    cForeground := "c" . "c5c8c6"
    cComment := "c" . "969896"
    cRed := "c" . "cc6666"
    cOrange := "c" . "de935f"
    cYellow := "c" . "f0c674"
    cGreen := "c" . "b5bd68"
    cAqua := "c" . "8abeb7"
    cBlue := "c" . "81a2be"
    cPurple := "c" . "b294bb"
    Gui, Color, 1d1f21, 373b41, 
    Gui, Font, s11 cWhite, Segoe UI 
    gui, add, text,xm ym, Please copy file contents to clipboard
    ; gui, add, listview,  vvLV1 cWhite checked, % "Type"
    ; for k,v in PotentialOutputs
    ; {
        
    ;     Options:=
    ;     Options:=((Instr(script.config.lastrun.last_output_type,v))?"Check":"-Check")
    ;     LV_Add(Options,v)
    ; }
    ; gui, add, ddl, vDDLval, All||html_document|word_document|odt_document|rtf_document|md_document|
    Gui, add, button, gChooseFile, Choose Manuscript
    gui, add, edit, disabled w330 vChosenFile
    gui, add, checkbox,  vbVerboseCheckbox, Verbose?
    gui, add, checkbox,  vbFullLogCheckbox, Full Log on successful execution?
    Gui, Font, s7 cWhite, Verdana
    gui, add, button, gGCSubmit, Submit
    Gui, Add, Text,x25,% " Version: " script.version " Author: " script.author

    ; script.config.lastrun.last_output_type:=["html_document","word_document"]
    if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="")
    {
        SplitPath, % script.config.lastrun.manuscriptpath, , OutDir, , manuscriptname,
        SplitPath, % OutDir, OutFileName, OutDir,
        guicontrol,, bVerboseCheckbox, % (script.config.LastRun.Verbose)
        guicontrol,, bFullLogCheckbox, % (script.config.LastRun.FullLog)
        guicontrol,, ChosenFile, % manuscriptname "(" OutFileName ") - " script.config.lastrun.manuscriptpath
    }
    
    return
}

guiShow()
{
    global
    while (Contents="")
    {
        guiCreate()
        w:=script.config.GuiPositioning.w
        h:=script.config.GuiPositioning.H
        x:=(script.config.GuiPositioning.X!=""?script.config.GuiPositioning.X:200)
        y:=(script.config.GuiPositioning.Y!=""?script.config.GuiPositioning.Y:200)
        gui,1: show,x%x% y%y%, % script.name " - Choose manuscript"
        ; enableGuiDrag(1)
        WinWaitClose, % script.name " - Choose manuscript"
        if (Contents!="")
            break
    }
    return Contents
}

GCEscape()
{
    guiEscape()
}
GCSubmit()
{
    ret:=guiSubmit()
    return ret
}
guiEscape()
{
    gui, destroy
    return
}

guiSubmit()
{
    global
    gui, 1: default
    ; sel:=f_GetSelectedLVEntries()
    gui, submit
    gui, destroy
    
    FileRead, Contents, % "D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\306 Health\_Attention Deficit Hyperactivity Disorder.md"
    ; Contents:=Clipboard
	if (Contents="")
		msgbox, 0x40010, % script.name, % " No file on clipboard"
    ; regex:="# \[\[(?<Date>(\d|\.)*)\]\]\s(?<Time>(\d|\.|:)*)"
	; Logs:=RegexSplit(Contents,regex)
    ; Logs.RemoveAt(1,1)
	; ; regex := "O)# \[\[(?<Date>(\d|\.)*)\]\]\s(?<Time>(\d|\.|:)*)"
    ; ; Dates:=RegExMatch(Contents,, NeedleRegEx [, UnquotedOutputVar = "", StartingPos = 1])
    ; p := 1
    ; k:=1
    
    ; while p := RegExMatch(Contents, regex, match, p) 
    ; {	
    ;     Lines:=SubStr(Contents,p,99)
    ;     Line:=Strsplit(Lines,"`n").1
    ;     A:=SubStr(Contents, p + StrLen(Line),99)
    ;     ; Entries{p " - " }:=
    ;     Info:=SubStr(Contents,p,99)
    ;     TS:={}
    ;     TS.Date:=SubStr(Info,5,10) 
    ;     TS.Time:=SubStr(Info,18,5)
    ;     TS.Assembly:=Strsplit(TS.Date,".").3 Strsplit(TS.Date,".").2 Strsplit(TS.Date,".").1 Strsplit(TS.Time,":").1 Strsplit(TS.Time,":").2
    ;     if Instr(TS.Assembly,"`n")
    ;         TS.Assembly:=Strsplit(TS.Assembly,"`n").1
    ;     DateLogPairs[TS.Assembly]:=Logs[k]
    ;     p += StrLen(Info) + StrLen(DateLogPairs[Info])
    ;     k++
    ; }
	; if RegExMatch(Contents, , v)
	; {

	; }

    DateLogPairs:={}
    ; Entries:={}
    regex:="mU)# \[\[(?<Date>(\d|\.)*)\]\]\s*(?<Time>(\d|\.|:){0,5})\n\n(?<Content>(\W|.)*)#"
    Out:=RegExMatchAll(Contents,regex)
    for k,Match in Out
    {
        
        TS:={}
        TS.Date:=SubStr(Info,5,10) 
        TS.Time:=SubStr(Info,18,5)
        Match.TimeSort:=Strsplit(Match.Date,".").3 Strsplit(Match.Date,".").2 Strsplit(Match.Date,".").1 Strsplit(Match.Time,":").1 Strsplit(Match.Time,":").2
        DateLogPairs[Match.TimeSort]:=Match
    }
    return Contents
}

ProcessLogs(Content)
{
    DateLogPairs:={}
    ; Entries:={}
    regex:="mU)# \[\[(?<Date>(\d|\.)*)\]\]\s*(?<Time>(\d|\.|:){0,5})\n\n(?<Content>(\W|.)*)#"
    Out:=RegExMatchAll(Content,regex)
    for k,Match in Out
    {
        TS:={}
        TS.Date:=SubStr(Info,5,10) 
        TS.Time:=SubStr(Info,18,5)
        Match.TimeSort:=Strsplit(Match.Date,".").3 Strsplit(Match.Date,".").2 Strsplit(Match.Date,".").1 Strsplit(Match.Time,":").1 Strsplit(Match.Time,":").2
        DateLogPairs[Match.TimeSort]:=Match
    }
    index:=1, ret:=[]
    for k,v in DateLogPairs
        ret[index++]:=v
    return ret
}

RegExMatchAll(text, regexp, pos=1)
{ ;; retrieved from https://www.autohotkey.com/board/topic/60131-regexmatchall/ 10.01.2023, author: Rapte_of_Suzaku
    ; prep work for getting list of local variables
    static hwndEdit, pSFW, pSW, bkpSFW, bkpSW
    if !hwndEdit
    {
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
        Process, Exist
        ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
        DetectHiddenWindows, %dhw%

        hmod := DllCall("GetModuleHandle", "str", "user32.dll")
        pSFW := DllCall("GetProcAddress", "uint", hmod, "astr", "SetForegroundWindow")
        pSW := DllCall("GetProcAddress", "uint", hmod, "astr", "ShowWindow")
        DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
        DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
        bkpSFW := NumGet(pSFW+0, 0, "int64")
        bkpSW := NumGet(pSW+0, 0, "int64")
    }
    
    ; RegExMatch until there are no more matches
    ret := Object()
    n := i := 0
    While ( pos := RegExMatch(text, regexp, m%A_Index%_, pos) )
    {
        ret[++n] := Object()
        ret[n][0]:=m%A_Index%_
        pos+=StrLen(m%A_Index%_)
    }

    ; place convenient bookends for regexing matches
    m0_:="start"
    m__:="stop"

    ; get a list of local variables
    NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")  ; return TRUE
    NumPut(0x0008C200000001B8, pSW+0, 0, "int64")   ; return TRUE
    ListVars
    NumPut(bkpSFW, pSFW+0, 0, "int64")
    NumPut(bkpSW, pSW+0, 0, "int64")
    ControlGetText, text,, ahk_id %hwndEdit%
    
    ; process list of local variables to place all match info into return object
    RegExMatch(text, "sm)^m0_.*(?:^m__.*Global Variables \(alphabetical\)`r`n-{50}`r`n)", matches)
    Loop Parse, matches, `n, `r
    {
        RegExMatch(A_LoopField,"m)^m(\d+)_(\S+)\[[^\]]*\]:",part)
        ret[part1][part2]:=m%part1%_%part2%
    }
    
    return ret
}
ChooseFile()
{
    global
    ttip(Clipboard)
    SplitPath, % Clipboard, , , Ext
    if CF_bool:=FileExist(Clipboard) && (Ext="md") && !GetKeyState("LShift","P")
        manuscriptpath:=(CF_bool?Clipboard:script.config.searchroot)
    else
    {
        FileSelectFile, manuscriptpath, 3, % (FileExist(Clipboard)?Clipboard:script.config.config.searchroot)  , % "Choose manuscript file", *.md
        if (manuscriptpath="")
            return
    }
    SplitPath, % manuscriptpath, , OutDir, , manuscriptname,
    SplitPath, % OutDir, OutFileName,
    guicontrol,, ChosenFile, % manuscriptname "(" OutFileName ") - " manuscriptpath
    return manuscriptpath
}

; --uID:63479989
 ; Metadata:
  ; Snippet: RegExSplit()
  ; --------------------------------------------------------------
  ; Author: ObiWanKenobi
  ; Source: https://autohotkey.com/board/topic/123708-useful-functions-collection/
  ; 
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 05 - String/Array/Text
  ; Dependencies: ExtractSE()
  ; AHK_Version: v1
  ; --------------------------------------------------------------


 ;; Description:
  ;; split a String by a regular expressin pattern and you will receive an array as a result
  ;; 
  ;; ;- - ObiWanKenobi
  ;; ;Parameters for RegExSplit:
  ;; ;psText                      the text you want to split
  ;; ;psRegExPattern      the Regular Expression you want to use for splitting
  ;; ;piStartPos               start at this posiiton in psText (optional parameter)
  ;; ;function ExtractSE() is a helper-function to extract a string at a specific start and end position.

 RegExSplit(ByRef psText, psRegExPattern, piStartPos:=1) {				;-- split a String by a regular expressin pattern and you will receive an array as a result
 	aRet := []
 	if (psText != "") 	{
 
 		iStartPos := piStartPos
 		while (iPos := RegExMatch(psText, "P)" . psRegExPattern, match, iStartPos)) {
 
 			sFound := ExtractSE(psText, iStartPos, iPos-1)
 			aRet.Push(sFound)
 			iStartPos := iPos + match
 		}
         sFound := ExtractSE(psText, iStartPos)
         aRet.Push(sFound)
 	}
 	return aRet
 }


; --uID:63479989
; --uID:3819447232
 ; Metadata:
  ; Snippet: ExtractSE()
  ; --------------------------------------------------------------
  ; Author: ObiWanKenobi
  ; Source: https://autohotkey.com/board/topic/123708-useful-functions-collection/
  ; 
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 05 - String/Array/Text
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------


 ;; Description:
  ;; helper-subfunction of RegExSplit to extract a string at a specific start and end position
  ;; 
  ;; 

 ExtractSE(ByRef psText, piPosStart, piPosEnd:="") {                      	;-- subfunction of RegExSplit
 	if (psText != "")
 	{
 		piPosEnd := piPosEnd != "" ? piPosEnd : StrLen(psText)
 		return SubStr(psText, piPosStart, piPosEnd-(piPosStart-1))
 	}
 }


; --uID:3819447232