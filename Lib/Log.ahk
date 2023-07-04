class log
{
    __Init() {
        tpl=
    (

___________________________________________________
Overview:

Manuscript                : `%manuscriptname`%
Used Verb                 : `%UsedVerb`%
OHTML - Version           : `%obsidianhtml_version`%
Used Personal Fork        : `%bUseOwnOHTMLFork`%
ObsidianKnittr - Version  : `%ObsidianKnittr_Version`%

___________________________________________________
Timings:

ObsidianHTML            > `%ObsidianHTML_Start`%
ObsidianHTML            < `%ObsidianHTML_End`%
                                       `%ObsidianHTML_Duration`%
intermediary Processing > `%Intermediary_Start`%
intermediary Processing < `%Intermediary_End`%
                                       `%Intermediary_Duration`%
R                       > `%RScriptExecution_Start`%
R                       < `%RScriptExecution_End`%
                          Codechunks -       `%RCodeChunkExecutionTime`%
                                       `%RScriptExecution_Duration`%

Total (not ms-precise)                 `%TotalExecution_Duration`%

___________________________________________________
Script Execution Settings:

ObsidianKnittr:
ObsidianKnittr - Version  : `%ObsidianKnittr_Version`%
Output - Formats          : `%formats`%
Keep Filename             : `%bKeepFilename`%
SRC_Converter Version     : `%bSRCConverterVersion`% (deprecated, only for completeness)
Stripped '#' from Tags    : `%bRemoveHashTagFromTags`%
Full Log                  : `%bFullLogCheckbox`%

ObsidianHTML:
OHTML - Version           : `%obsidianhtml_version`%
Used Verb                 : `%UsedVerb`%
Used Personal Fork        : `%bUseOwnOHTMLFork`%
Verbosity                 : `%bVerboseCheckbox`%
Stripped OHTML - Errors   : `%bRemoveObsidianHTMLErrors`%
Stripped Local MD-Links   : `%bStripLocalMarkdownLinks`%
Vault Limited             : `%bRestrictOHTMLScope`%

RMD:
Execute R-Script          : `%bExecuteRScript`%
Fixed PNG Files           : `%bForceFixPNGFiles`%
Inserted Setup Chunk      : `%bInsertSetupChunk`%

QMD: 
Strip Type from Crossrefs : `%bRemoveQuartoReferenceTypesFromCrossrefs`%

___________________________________________________
Fed OHTML - Config:

`%configfile_contents`%

___________________________________________________
RMarkdown Document Settings:

`%DocumentSettings`%

___________________________________________________
Paths:
manuscriptlocation        : `%manuscriptpath`%
Vault limited to childs of: `%temporaryVaultpath`%
Vault-Limiter removed     : `%temporaryVaultpathRemoved`%
Output Folder             : `%output_path`%
Raw Input Copy            : `%rawInputcopyLocation`%
ObsidianHTML - Path       : `%obsidianHTML_path`% (either the path to the installed exe or the personal modded version)
Config - Template         : `%configtemplate_path`%
ObsidianHTMLCopy Dir      : `%ObsidianHTMLCopyDir`%
ObsidianHTMLWorking Dir   : `%ObsidianHTMLWorkDir`%
ObsidianHTMLOutputPath    : `%ObsidianHTMLOutputPath`%
___________________________________________________
OHTML - StdStreams:
Issued Command            : `%CMD`%
stdOut                    : `%data_out`%
___________________________________________________
R - StdStreams:
Issued Command            : `%RCMD`%
Working Directory         : `%RWD`%
stdOut                    : `%Rdata_out`%

)
        ObjRawSet(this, "tpl", tpl)
    }
    __New(Path, Cache, Encoding := "UTF-8") {
        ObjRawSet(this, "__path", Path)
        ObjRawSet(this, "__encoding", Encoding)
        ObjRawSet(this, "__Cache", false)
        writeFile_Log(Path, this.tpl, Encoding, , true)
        tempfile:=FileOpen(Path,"rw",Encoding)
        ObjRawSet(this,"content",tempfile.read())
        tempfile.close()
        ObjRawSet(this,"__h",FileOpen(Path,"w",Encoding))
        this.Cache(Cache)
        OnExit(this.close)
        OnError(this.close)
    }
    cache(Set := "") {
        ;; TODO: implement Cache (false by default, if true we don't close the fo inbetween calls? )
        if !StrLen(Set) {
            return this.__Cache
        }
        return this.__Cache := !!Set
    }
    close() {
        OutputDebug % this.content
        this.__h.close()
    }
    handle() {
        OutputDebug % this.content
        this.__h.handle()
    }
    getTotalDuration(atc1,atc2) {
        diff:=atc2-atc1
        Time:=PrettyTickCount(diff)
        this.TotalExecution_Duration:=RegExReplace(Time,"[hms]")
    }
    __Set(Key, Value) {
        OutputDebug % this.__h.tell()
        OldLength:=strLen(this.content)
        this.__h.Pos:=0 ; reset the pointer to the beginning of the file → this apparently still frameshifts?
        Key:="`%" Key "`%" ; prep the eky
        this.content:=strreplace(this.content,Key, Value)
        NewLength:=strLen(this.content)
        if (NewLength<OldLength) {
            Diff:=abs(NewLength-OldLength)
            loop, % Diff {
                this.content.=A_Space
            }
            L:=strLen(this.content)
            if (OldLength!=L) {
                MsgBox 0x30, % "Log.__Set()", String written to fileobject was improperly padded.`n`nThis is not a catastrophic error`, just means your execution log is going to be ugly at the bottom.
            }

        }
        this.__h.write(this.content)
    }
}

; #region: writeFile_Log (3352591673)
; #region: Metadata:
; Snippet: writeFile_Log;  (v.1.0)
;  10 April 2023
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: MIT
; --------------------------------------------------------------
; Library: Personal Library
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: encoding, UTF-8/UTF-8-RAW
; #endregion:Metadata

; #region:Description:
; Small function for writing files to disk in a safe manner when requiring specific file encodings or flags.
; Allows f.e. UTF-8 filewrites
; #endregion:Description

; #region:Example
; Loop, Files, % Folder "\*." script.config.Config.filetype, F
;         {
;             scriptWorkingDir:=renameFile(A_LoopFileFullPath,Arr[A_Index],true,A_Index,TrueNumberOfFiles)
;             writeFile_Log(scriptWorkingDir "\gfa_renamer_log.txt",Files, "UTF-8-RAW","w",true)
;         }
; #endregion:Example

; #region:Code
writeFile_Log(Path, Content, Encoding := "", Flags := 0x2, bSafeOverwrite := false) {

    if (bSafeOverwrite && FileExist(Path)) ;; if we want to ensure nonexistance.
        FileDelete % Path
    if (Encoding != "") {
        if (fObj := FileOpen(Path, Flags, Encoding)) {
            fObj.Write(Content) ;; insert contents
            fObj.Close() ;; close file
        } else
            throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
    } else {
        if (fObj := FileOpen(Path, Flags)) {
            fObj.Write(Content) ;; insert contents
            fObj.Close() ;; close file
        } else
            throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
    }
    return
}
; #endregion:Code

; #endregion:writeFile_Log (3352591673)

; #region:CodeTimer_Log (2035383057)

; #region:Metadata:
; Snippet: CodeTimer_Log;  (v.1.0)
; --------------------------------------------------------------
; Author: CodeKnight
; Source: -
; (05.03.2020)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 23 - Other
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: performance, time
; #endregion:Metadata

; #region:Description:
; approximate measure of how much time has exceeded between two positions in code. Returns an array containing the time expired (in ms), as well as the displayed string.
; #endregion:Description

; #region:Example
; CodeTimer_Log("A timer")
; Sleep 1050
; ; Insert other code between the two function calls
; CodeTimer_Log("A timer")
;
; #endregion:Example

; #region:Code
CodeTimer_Log() {

    Global StartTimer

    If (StartTimer != "") {
        FinishTimer := A_TickCount
        TimedDuration := FinishTimer - StartTimer
        StartTimer := ""
        time_withletters:=PrettyTickCount_Log(TimedDuration)
        time_withoutletters:=RegexReplace(time_withletters,"[hms]")
        Return time_withoutletters
    } Else {
        StartTimer := A_TickCount
    }
}
; #endregion:Code

; #endregion:CodeTimer_Log (2035383057)

; --uID:2595808127
; Metadata:
; Snippet: PrettyTickCount_Log()
; 09 Oktober 2022  ; --------------------------------------------------------------
; License: WTFPL
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 26 - Date or Time
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

;; Description:
;; takes a time in milliseconds and displays it in a readable fashion
;;
;;

PrettyTickCount_Log(timeInMilliSeconds) { 	;-- takes a time in milliseconds and displays it in a readable fashion
    ElapsedHours := SubStr(0 Floor(timeInMilliSeconds / 3600000), -1)
    ElapsedMinutes := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000) / 60000), -1)
    ElapsedSeconds := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000) / 1000), -1)
    ElapsedMilliseconds := SubStr(0 timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000 - ElapsedSeconds * 1000, -2)
    returned := ElapsedHours "h:" ElapsedMinutes "m:" ElapsedSeconds "s." ElapsedMilliseconds
    return returned
}

; --uID:2595808127
