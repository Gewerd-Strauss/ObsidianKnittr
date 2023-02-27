#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

History:=[1,2,3,4,5,6,7,8,9]
OldHist:=History.clone()
History:=buildHistory(History,6,"DD")
m(OldHist,History)



buildHistory(History,NumberOfRecords,manuscriptpath:="")
{
    if (manuscriptpath!="")
        History.InsertAt(1,manuscriptpath)
    if (History.Count()>NumberOfRecords)
        History.Delete(NumberOfRecords+1,History.Count())
    return History
}