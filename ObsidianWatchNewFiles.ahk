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
ntfy:=Notify()
;;_____________________________________________________________________________________
;{#[General Information for file management]
ScriptName=MISSING 
VN=1.0.2.1                                                                    
LE=24 Juni 2022 14:52:45                                                        
AU=Gewerd Strauss
;}______________________________________________________________________________________
;{#[File Overview]
Menu, Tray, Icon, C:\windows\system32\shell32.dll,102 ;Set custom Script icon

menu, Tray, Add, About, Label_AboutFile
; menu, tray, noicon
menu, tray, tip, .deleteUntitled
;}______________________________________________________________________________________
;{#[Autorun Section]
    
#Include <scriptObj/scriptObj>
FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
global script := {   base         : script
,name         : regexreplace(A_ScriptName, "\.\w+")
,version      : "1.2.1"
,author       : "Gewerd Strauss"
,authorlink   : "https://www.github.com/Gewerd-Strauss"
,email        : ""
,credits      : ""
,creditslink  : ""
,crtdate      : CrtDate
,moddate      : ModDate
,homepagetext : ""
,homepagelink : ""
,ghtext 	  : ""
,ghlink       : ""
,doctext	  : ""
,doclink	  : ""
,forumtext	  : ""
,forumlink	  : ""
,donateLink   : ""
,resfolder    : A_ScriptDir "\res"
,iconfile     : A_ScriptDir "\res\sct.ico"
,config       : []
,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
,configfolder : A_ScriptDir "\INI-Files"}


if WinActive("Visual Studio Code")	; if run in vscode, deactivate notify-messages to avoid crashing the program.
    global bRunNotify:=!vsdb:=1
else
    global bRunNotify:=!vsdb:=0

;; loading vaults
IniTemplate=
    ( LTRIM
    [Vault-Directories]

    [Settings]
    DeletionPeriodInSeconds=45
    MoveToObsidianTrashInsteadOfNormalTrash=0
    )
sHowToText=
    (LTRIM
    No configuration found. To set up, please open the config-file and 
    insert any desired absolute/full path in below "[Vault-Directories], and above [Settings]".


    Settings:
    DeletionPeriodInSeconds: number of seconds inbetween file deletions
    MoveToObsidianTrashInsteadOfNormalTrash: Set to true to move any file to the .trash-folder of the respective vault. Note that files already present in that folder get overwritten, and that files cannot easily be moved back to their initial location, as there is no "Restore file"-option in the .trash-folder.

    ---

    The script will exit now. Please add the paths necessary to the config-file, then start the script again.
)
if !InStr(FileExist(script.configfolder),"D")
    FileCreateDir, % script.configfolder
if !FileExist(script.configfile)
{
    FileAppend, %IniTemplate%,% script.configfile
    MsgBox, 65, % script.name ": No configuration found.",% sHowToText
    IfMsgBox, Ok
    {
        run, % script.configfile
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
    FileRead, CurrentStateINI, % script.configfile
    CurrentstateINI:=strreplace(CurrentStateINI,"`r","")
    if (CurrentStateINI=IniTemplate)
    {
        MsgBox, 65, % script.name ": No configuration found.",% sHowToText
        IfMsgBox, Ok
        {
            run, % script.configfile
            ExitApp, 
        }
        else
            ExitApp, 
    }
    else
        script.config:=fReadINI(script.configfile)
}


for k,v in script.config["Vault-Directories"]
{
    if (k>64)
        ttip("A maximum of 64 folders can be watched simultaneously. Also, what are you doing with 64 vaults?`nPlease reduce your number of vaults to a maximum of 64. Exiting script")
    else
        WatchFolder(v,"NewFileHandler",1,"0x1") ;; afaik is this supposed to trigger on ay
}

global aFilesToCheckAndDelete:=[]
Settimer, lCheckAndDelete, % 1000* script.config.Settings.CheckingPeriodInSeconds
Settimer, lLoopCheckAndDelete, % 1000*30* script.config.Settings.CheckingPeriodInSeconds
return

;}______________________________________________________________________________________
;{#[Hotkeys Section]
;}______________________________________________________________________________________
;{#[Label Section]
#If Winactive("ahk_exe obsidian.exe")
:*:.delUnt::
lLoopCheckAndDelete:
if !WinExist("ahk_exe obsidian.exe") ; make sure this is only executing as long as Obsidian itself is running.
    WinWaitActive, 
aFilesToCheckAndDelete:=fLoopFiles(aFilesToCheckAndDelete)
fCheckAndDelete(aFilesToCheckAndDelete)
return
lCheckAndDelete:          ; check and delete potential files
if !WinExist("ahk_exe obsidian.exe") ; make sure this is only executing as long as Obsidian itself is running.
    WinWaitActive, 
fCheckAndDelete(aFilesToCheckAndDelete)
return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
script.about()
return
;}______________________________________________________________________________________
;{#[Functions Section]
fLoopFiles(Files)
{
    for k,v in script.config["Vault-Directories"]
    {
        if Instr(v, "TestVault")
            continue
        e:=v 
        loop, files,%  v  "\*.md",FR
        {
            if Instr(A_LoopFileFullPath,"\.trash\")
                continue
            if RegexMatch(A_LoopFileName,"Untitled\s*\d*\.md")
                Files.push(A_LoopFileFullPath)
            }
    }
    ; m(Files)
    return Files
}

NewFileHandler(Folder, Changes)
{
    global
    Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
    if !WinExist("ahk_exe obsidian.exe")    ; prevent file analysis while obsidian is closed. 
        return
    aPossibleFileNamesToDelete:=["Untitled","null"]
    for each, CurrentChange in Changes
    {
        vName:=""
        if (CurrentChange.Action=2)
            continue
        SplitPath, % CurrentChange.Name, CurrentName,,CurrentExt
        if (CurrentExt!="md")
            continue
        if RegExMatch(CurrentChange.Name, "\\(?<Name>[\w\s]*)\.md",v)
        {
            needle:= 
            if RegExMatch(vName,"Untitled\s*\d*") || RegExMatch(vName,"null\s*\d*") 
                FileRead, UntitledContents,% CurrentChange.Name
            Else
                continue
            if (vName!="")
            {
                bSkip:=0
                for jede, RecordedChange in aFilesToCheckAndDelete ; check if path already exists in array
                {
                    if (CurrentChange.Name==RecordedChange.Name)
                    {   ;; CurrentChange is already present, so no need to continue looking
                        bSkip:=1
                        break
                    }
                    Else
                        bSkip:=0
                }
                if !bSkip || (vName="null")
                    aFilesToCheckAndDelete.push(CurrentChange)
            }
        }
    }
}

fCheckAndDelete(Files)
{
    for each, File in Files
    {
        if FileExist(File.Name) ||FileExist(File)
        {
            if IsObject(File)
            {
                if RegExMatch(File.Name,"Untitled\s*\d*") || RegExMatch(File.Name,"null\s*\d*") 
                {
                    FileRead, UntitledContents,% File.Name
                    if (UntitledContents="") || Instr(UntitledContents,"tp.file.cursor()")
                    {
                        if % d:=script.config.Settings.MoveToObsidianTrashInsteadOfNormalTrash
                            FileMove,% File.Name, CurrentVault ".trash\" , 1
                        Else
                            FileRecycle,% File.Name
                    }
                }
            }
            else
            {

                if RegExMatch(File,"Untitled\s*\d*") || RegExMatch(File,"null\s*\d*") 
                {
                    FileRead, UntitledContents,% File
                    if (UntitledContents="") || Instr(UntitledContents,"tp.file.cursor()")
                    {
                        if % d:=script.config.Settings.MoveToObsidianTrashInsteadOfNormalTrash
                            FileMove,% File, CurrentVault ".trash\" , 1
                        Else
                            FileRecycle,% File
                    }
                }
            }
        }
    }
    for each, File in Files
        if !FileExist(File.Name)
            Files.RemoveAt(each,1)
}
return
WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) 
{
    Static DummyObject := {Base: {__Delete: Func("WatchFolder").Bind("**END", "")}}
    Static TimerID := "**" . A_TickCount
    Static TimerFunc := Func("WatchFolder").Bind(TimerID, "")
    Static MAXIMUM_WAIT_OBJECTS := 64
    Static MAX_DIR_PATH := 260 - 12 + 1
    Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode
    Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
    Static SizeOfOVL := 32     ; size of the OVERLAPPED structure (64-bit)
    Static WatchedFolders := {}
    Static EventArray := []
    Static WaitObjects := 0
    Static BytesRead := 0
    Static Paused := False
    ; ===============================================================================================================================
    If (Folder = "")
        Return False
    SetTimer, % TimerFunc, Off
    RebuildWaitObjects := False
    ; ===============================================================================================================================
    If (Folder = TimerID) { ; called by timer
        If (ObjCount := EventArray.Count()) && !Paused {
            ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
            While (ObjIndex >= 0) && (ObjIndex < ObjCount) {
                Event := NumGet(WaitObjects, ObjIndex * A_PtrSize, "UPtr")
                Folder := EventArray[Event]
                If DllCall("GetOverlappedResult", "Ptr", Folder.Handle, "Ptr", Folder.OVLAddr, "UIntP", BytesRead, "Int", True) {
                Changes := []
                FNIAddr := Folder.FNIAddr
                FNIMax := FNIAddr + BytesRead
                OffSet := 0
                PrevIndex := 0
                PrevAction := 0
                PrevName := ""
                Loop {
                    FNIAddr += Offset
                    OffSet := NumGet(FNIAddr + 0, "UInt")
                    Action := NumGet(FNIAddr + 4, "UInt")
                    Length := NumGet(FNIAddr + 8, "UInt") // 2
                    Name   := Folder.Name . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
                    IsDir  := InStr(FileExist(Name), "D") ? 1 : 0
                    If (Name = PrevName) {
                        If (Action = PrevAction)
                            Continue
                        If (Action = 1) && (PrevAction = 2) {
                            PrevAction := Action
                            Changes.RemoveAt(PrevIndex--)
                            Continue
                        }
                    }
                    If (Action = 4)
                        PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
                    Else If (Action = 5) && (PrevAction = 4) {
                        Changes[PrevIndex, "Name"] := Name
                        Changes[PrevIndex, "IsDir"] := IsDir
                    }
                    Else
                        PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
                    PrevAction := Action
                    PrevName := Name
                } Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
                If (Changes.Length() > 0)
                    Folder.Func.Call(Folder.Name, Changes)
                DllCall("ResetEvent", "Ptr", Event)
                DllCall("ReadDirectoryChangesW", "Ptr", Folder.Handle, "Ptr", Folder.FNIAddr, "UInt", SizeOfFNI
                                                , "Int", Folder.SubTree, "UInt", Folder.Watch, "UInt", 0
                                                , "Ptr", Folder.OVLAddr, "Ptr", 0)
                }
                ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
                Sleep, 0
            }
        }
    }
    ; ===============================================================================================================================
    Else If (Folder = "**PAUSE") { ; called to pause/resume watching
        Paused := !!UserFunc
        RebuildObjects := Paused
    }
    ; ===============================================================================================================================
    Else If (Folder = "**END") { ; called to stop watching
        For Event, Folder In EventArray {
            DllCall("CloseHandle", "Ptr", Folder.Handle)
            DllCall("CloseHandle", "Ptr", Event)
        }
        WatchedFolders := {}
        EventArray := []
        Paused := False
        Return True
    }
    ; ===============================================================================================================================
    Else 
    { ; called to add, update, or remove folders
        Folder := RTrim(Folder, "\")
        VarSetCapacity(LongPath, MAX_DIR_PATH << !!A_IsUnicode, 0)
        If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", MAX_DIR_PATH)
            Return False
        VarSetCapacity(LongPath, -1)
        Folder := LongPath
        If (WatchedFolders.HasKey(Folder)) { ; update or remove
            Event :=  WatchedFolders[Folder]
            FolderObj := EventArray[Event]
            DllCall("CloseHandle", "Ptr", FolderObj.Handle)
            DllCall("CloseHandle", "Ptr", Event)
            EventArray.Delete(Event)
            WatchedFolders.Delete(Folder)
            RebuildWaitObjects := True
        }
        If InStr(FileExist(Folder), "D") && (UserFunc <> "**DEL") && (EventArray.Count() < MAXIMUM_WAIT_OBJECTS) {
            If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
                Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
                                            , "UInt", 0x42000000, "Ptr", 0, "UPtr")
                If (Handle > 0) {
                Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
                FolderObj := {Name: Folder, Func: UserFunc, Handle: Handle, SubTree: !!SubTree, Watch: Watch}
                FolderObj.SetCapacity("FNIBuff", SizeOfFNI)
                FNIAddr := FolderObj.GetAddress("FNIBuff")
                DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", SizeOfFNI)
                FolderObj["FNIAddr"] := FNIAddr
                FolderObj.SetCapacity("OVLBuff", SizeOfOVL)
                OVLAddr := FolderObj.GetAddress("OVLBuff")
                DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", SizeOfOVL)
                NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
                FolderObj["OVLAddr"] := OVLAddr
                DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", SizeOfFNI, "Int", SubTree
                                                , "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
                EventArray[Event] := FolderObj
                WatchedFolders[Folder] := Event
                RebuildWaitObjects := True
                }
            }
        }
        If (RebuildWaitObjects) {
            VarSetCapacity(WaitObjects, MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
            OffSet := &WaitObjects
            For Event In EventArray
                Offset := NumPut(Event, Offset + 0, 0, "Ptr")
        }
    }
    ; ===============================================================================================================================
    If (EventArray.Count() > 0)
        SetTimer, % TimerFunc, -100
    Return (RebuildWaitObjects) ; returns True on success, otherwise False
}
;}_____________________________________________________________________________________
;{#[Include Section]
ttip(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
{
    /*
        Date: 24 Juli 2021 19:40:56: 
        
        Modes:  
        1: remove tt after "to" milliseconds 
        2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
        3: not sure anymore what the plan was lol - remove 
        4: shows tooltip slightly offset from current mouse, does not repeat
        5: keep that tt until the function is called again  

        CoordMode:
        -1: Default: currently set behaviour
        1: Screen
        2: Window

        to: 
        Timeout in milliseconds
        
        xp/yp: 
        xPosition and yPosition of tooltip. 
        "NaN": offset by +50/+50 relative to mouse
        IF mode=4, 
        ----  Function uses tooltip 20 by default, use parameter
        "currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
        separately from each other, hence a removal of ttip20 will not remove tt14 
    */
    
    ;if (text="TTIP: Test")
        ;m(to)
        cCoordModeTT:=A_CoordModeToolTip
    if (text="")
        gosub, lRemovettip
    static ttip_text
    static lastcall_tip
    static currTip2
    global ttOnOff
    currTip2:=currTip
    cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
    CoordMode, % cMode
    tooltip,

    
    ttip_text:=text
    lUnevenTimers:=false 
    MouseGetPos,xp1,yp1
    if (mode=4) ; set text offset from cursor
    {
        yp:=yp1+15
        xp:=xp1
    }	
    else
    {
        if (xp="NaN")
            xp:=xp1 + 50
        if (yp="NaN")
            yp:=yp1 + 50
    }
    tooltip, % ttip_text,xp,yp,% currTip
    if (mode=1) ; remove after given time
    {
        SetTimer, lRemovettip, % "-" to
    }
    else if (mode=2) ; remove, but repeatedly show every "to"
    {
        ; gosub,  A
        global to_1:=to
        global to2_1:=to2
        global tTimes:=Times
        Settimer,lSwitchOnOff,-100
    }
    else if (mode=3)
    {
        lUnevenTimers:=true
        SetTimer, lRepeatedshow, %  to
    }
    else if (mode=5) ; keep until function called again
    {
        
    }
    CoordMode, % cCoordModeTT
    return
    lSwitchOnOff:
    ttOnOff++
    if mod(ttOnOff,2)	
    {
        gosub, lRemovettip
        sleep, % to_1
    }
    else
    {
        tooltip, % ttip_text,xp,yp,% currTip
        sleep, % to2_1
    }
    if (ttOnOff>=ttimes)
    {
        Settimer, lSwitchOnOff, off
        gosub, lRemovettip
        return
    }
    Settimer, lSwitchOnOff, -100
    return

    lRepeatedshow:
    ToolTip, % ttip_text,,, % currTip2
    if lUnevenTimers
        sleep, % to2
    Else
        sleep, % to
    return
    lRemovettip:
    ToolTip,,,,currTip2
    return
}
HasVal(Nestedhaystack, needle) 
{	; code from jNizM on the ahk forums: https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
    if !(IsObject(haystack)) || (haystack.Length() = 0)
        return 0
    for index, value in haystack
        if (value = needle)
            return index
    return 0
}
m(x*){
    static List:={BTN:{OC:1,ARI:2,YNC:3,YN:4,RC:5,CTC:6},ico:{X:16,"?":32,"!":48,I:64}},Msg:=[]
    static Title
    List.Title:="AutoHotkey",List.Def:=0,List.Time:=0,Value:=0,TXT:="",Bottom:=0
    WinGetTitle,Title,A
    for a,b in x{
        Obj:=StrSplit(b,":"),(Obj.1="Bottom"?(Bottom:=1):""),(VV:=List[Obj.1,Obj.2])?(Value+=VV):(List[Obj.1]!="")?(List[Obj.1]:=Obj.2):TXT.=(IsObject(b)?Obj2String(b,,Bottom):b) "`n"
    }
    Msg:={option:Value+262144+(List.Def?(List.Def-1)*256:0),Title:List.Title,Time:List.Time,TXT:TXT}
    Sleep,120
    MsgBox,% Msg.option,% Msg.Title,% Msg.TXT,% Msg.Time
    for a,b in {OK:Value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
        IfMsgBox,%a%
            return b
    return % Msg.Txt
    Move:
    TT:=List.Title " ahk_class #32770 ahk_exe AutoHotkey.exe"
    WinGetPos,x,y,w,h,%TT%
    WinMove,%TT%,,2000,% Round((A_ScreenHeight-h)/2)
    return 
}
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
    static String,Blank
    if(FullPath=1)
        String:=FullPath:=Blank:=""
    if(IsObject(Obj)){
        for a,b in Obj{
            if(IsObject(b))
                Obj2String(b,FullPath "." a,BottomBlank)
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

;}_____________________________________________________________________________________