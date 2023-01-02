#SingleInstance, Force
SendMode Input
#Persistent
SetWorkingDir, %A_ScriptDir%
#if winactive("ahk_exe obsidian.exe")
^P::       ;; copy all assets of current note to vault root, then allow pandoc
{
    Storage:={Clip:"",cnt:0,bIsSelectedWhenPastingF10:""}
    if (storage.clip!=Clipboard)
        ttip(storage.clip:=Clipboard)
    SendInput,^P
    if fCKH(A_ThisHotkey)
    {
        SendInput,^P
        sleep,2000

        ; hk(0,0)
        
        ttip(Clipboard)
    SplitPath, Clipboard     ,d, OutDir, OutExtension, OutNameNoExt, OutDrive

        RegexMatch("300 Personal/301 DailyNotes/2022/01 January/31.01.2022.md","(?<Path>.*)(?<Name>\/.*\..*)",v)
       m:= RegexMatch(Clipboard,"(?<Path>.*)(?<Name>\/.*)\..*",v)
        m(Clipboard,vPath,vName,Path,Name)
        clipboard:=storage.clip
        hk(0,0)
    }
}
return
; "200 University/05/BE27_3 Environmental Biotechnology and Microalgae/BE27_3 Lecture 07 Summary.md"
