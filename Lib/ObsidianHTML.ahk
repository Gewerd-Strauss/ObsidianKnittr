ObsidianHtml(manuscript_path:="",config_path:="",bUseConvert:=true,bVerbose:=false) {
    /*
        stuff to change:

        1.  accept config file
        2.   verify its existence and validate it.
        3.  Execution, either:
        3.1 Run the cmd via ComSpec
        3.2 Build a WScript.Shel-ComObj and runt the cmd through that.
        4.  retrieve the output.
        5.  be happy.
    */
    
    ;; get ObsidianHTML_Path
    ComObj := ComObjCreate("WScript.Shell")
    ;Env:=ComObj.Exec("set")
    obsidianhtml_path:=Trim(ComObj.Exec("where obsidianhtml").stdOut.ReadAll())   ;; works
    ;obsidianhtml_path2:=Trim(ComObj.Exec("where obsidianhtml").stdOut.ReadAll)     ;; works
    ;set:=Trim(ComObj.Exec("set").stdErr.ReadAll())                                ;; not
    ;set2:=Trim(ComObj.Exec("set").stdOut.ReadAll)                                 ;; not
    ;ENV:=Trim(ComObj.Exec("env").stdErr.ReadAll())                                ;; not
    ;ENV2:=Trim(ComObj.Exec("env").stdErr.ReadAll())                               ;; not
    ;ech:=Trim(ComObj.Exec("echo 22").stdOut.ReadAll)                              ;; not
    ;ech2:=Trim(ComObj.Exec("echo %time%").stdOut.ReadAll)                             ;; not
    ;m(obsidianhtml_path,ENV)
    obsidianhtml:=strreplace(obsidianhtml_path,"`r`n")
    bUseConvert:=(manuscript_path=""?true:false)
    if (obsidianhtml="") {
        MsgBox 0x2010, script.name " - ObsidianHTML not found ", "The CLI-Utility ObsidianHTML could not be found via 'where obsidianhtml'.`nAs this script is not functional without it, it will exit now."
        return false
    }

    ;; get ObsidianHTML_Version
    obsidianhtml_version:=ComObj.Exec("obsidianhtml version").stdOut.ReadAll
    obsidianhtml_version:=Trim(obsidianhtml_version)
    obsidianhtml_version:=Regexreplace(obsidianhtml_version,"\s*") ;; trim whitespace


    ;; Validate config file.
    ; Your configuration (I'm hardcoding this, you need to "do your thing" before reaching to this point)
    if (!FileExist(config_path)) {
        MsgBox 0x2010, script.name " - provided Config file does not exist ", % "The config-file provided to 'obsidianhtml  convert -i <config_file> does not exist. Returning early."
        return false
    } else {
        FileRead, config_contents, % config_path
        if !Instr(config_contents,"obsidian_entrypoint_path_str: '") && bUseConvert {
            MsgBox 0x2010
            , % script.name " - config-field 'obsidian_entrypoint_path_str' not found "
            , % "The config-file provided does not contain the setting 'obsidian_entrypoint_path_str', which is required for running the 'convert'-option. Please check the code. The script will reload now."
            reload
        }
    }
    

    ;; Command minding quote_obsidianhtmls for configuration
    if bUseConvert {
        command := """" obsidianhtml """" " convert -i " Quote_ObsidianHTML(Trim(config_path))
    } else {
        if (manuscript_path="") {
            MsgBox 0x2010, script.name " > " A_ThisFunc, No manuscript_path was provided to the run-verb execution. The script will reload. `n`nPlease provide a valid note-path or choose to convert.
            reload
        }
        command := """" obsidianhtml """" " run -f " Quote_ObsidianHTML(Trim(manuscript_path)) " -i " Quote_ObsidianHTML(Trim(config_path))
    }

    ;; Check Verbosity
    command.= " " (bVerbose?" -v ":" ")
    
    ; Output/error redirection
    command .= " 1> obsidianhtml.out 2> obsidianhtml.err"

    ;
    ; RESERVED, read explanation.
    ;

    ; Run command inside a shell (to redirect the output)
    final_cmd:= A_ComSpec " /C " Quote_ObsidianHTML(command)
    OutputDebug, % "CMD:`n" final_cmd
    RunWait % final_cmd, % WD:=A_ScriptDir, UseErrorLevel,PID ;; is there a way to have this window moved to a specific portion of screen before continuing into the winwait?
    Clipboard:=final_cmd
    
    ; ErrorLevel is overwritten, grab it
    gotErrors := ErrorLevel
    
    ; Read into variables the output/error
    FileRead stdErr, % WD "\obsidianhtml.err"
    FileRead stdOut, % WD "\obsidianhtml.out"
    
    ; Cleanup
    FileDelete % WD "\obsidianhtml.err"
    FileDelete % WD "\obsidianhtml.out"
    
    ; Report if there was an error
    if (gotErrors) {
        ; Show the actual error
        MsgBox 0x1010, There was an error with obsidianhtml, % stdErr
        Exit ; Ends the thread
    }

    OutputDebug, % "CMD:`n" final_cmd "`n`nOutput:`n" stdOut
    ; Happy ending



    ;; and now let's do it all again via ComObj - or try to, at least? cuz it's not working.
    ;ComObj:=ComObjCreate("WScript.Shell")
    ;Ret:=ComObj.Exec(final_cmd)
    ;RetOut:=Ret.stdOut.ReadAll()
    ;RetErr:=Ret.stdErr.ReadAll()
    ;OutputDebug, % "`n`nCOMOBJ_VARIANT:`n`n" "CMD:`n" final_cmd "`n`nOutput:`n" RetOut
    return {"CMD":final_cmd,"stdOut":stdOut,"obsidianhtml_version":obsidianhtml_version,"obsidianhtml_path":obsidianhtml_path}
}
createTemporaryObsidianHTML_Config(manuscriptpath, obsidianhtml_configfile,Verbose)
{
    FileRead, configfile_contents, % obsidianhtml_configfile
    configfile_contents:=StrReplace(configfile_contents,"#obsidian_entrypoint_path_str: '%obsidian_entrypoint_path_str%'","obsidian_entrypoint_path_str: '" manuscriptpath "'")
    SplitPath, % manuscriptpath, , manuscriptdir
    writeFile_ObsidianHTML(configfile_path:=A_ScriptDir "\OHTMLconfig_temp.yaml",configfile_contents,,true)
    return [(FileExist(configfile_path)?configfile_path:false),configfile_contents]
}
readObsidianHTML_Config(configpath)
{
    if !FileExist(configpath)
        return "E01: No config found"
    FileRead, txt, % configpath
    if (txt="")
        return "E02: Empty config file"
    conf:=[]
    confstr:=""
    for index, Line in strsplit(txt,"`n")
    {
        Line:=trim(Line)
        if !Instr(Line, ":") && Instr(Line, "# ")
            continue
        if RegExMatch(Line, "(?<Key>.*):(?<Value>.*)", v)
        {
            conf[vKey]:=vValue
            confstr.= vKey "=" vValue "`n"
        }
    }
    if (confstr="")
        return "E03: Config file contains no valid YAML config found in provided file."
    return [conf,confstr]
}
ObsidianHtml_WORKINGTemplate(Config:="") {
;FOR THE LOVE OF GOD DON'T CHANGE THIS.
    ;; Get ObsidianHTML_Path
    ComObj := ComObjCreate("WScript.Shell")
    obsidianhtml_path:=Trim(ComObj.Exec("where obsidianhtml").stdOut.ReadAll)
    obsidianhtml:=strreplace(obsidianhtml_path,"`r`n")

    
    ; If `obsidianhtml` is not in the %PATH%
    ;obsidianhtml := "X:\Path\To\obsidianhtml.exe"
    ; Your configuration (I'm hardcoding this, you need to "do your thing" before reaching to this point)
    config := "D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\OHTMLconfig_temp.yaml"
    ; Command minding quote_obsidianhtmls for configuration
    command := """" obsidianhtml """" " convert -i " Quote_ObsidianHTML(config)
    ; Output/error redirection
    command .= " 1> obsidianhtml.out 2> obsidianhtml.err"

    ;
    ; RESERVED, read explanation.
    ;

    ; Run command inside a shell (to redirect the output)
    Run % final_cmd:= A_ComSpec " /C " Quote_ObsidianHTML(command), % A_Temp,  UseErrorLevel,PID
    WinWait, % "ahk_pid " PID
    WinWaitClose, % "ahk_pid " PID
    ; ErrorLevel is overwritten, grab it
    gotErrors := ErrorLevel
    ; Read into variables the output/error
    FileRead stdErr, % A_Temp "\obsidianhtml.err"
    FileRead stdOut, % A_Temp "\obsidianhtml.out"
    ; Cleanup
    FileDelete % A_Temp "\obsidianhtml.*"
    ; Report if there was an error
    if (gotErrors) {
        ; Show the actual error
        MsgBox 0x1010, There was an error with obsidianhtml, % stdErr
        Exit ; Ends the thread
    }
    OutputDebug, % "CMD:`n" final_cmd "`n`n" stdOut
    ; Happy ending
    return stdOut
}
updateObsidianHTMLToLastRelease()
{
    RunWait, % A_Comspec "  /k echo y | pip uninstall obsidianhtml", , 
    RunWait, % A_Comspec "  /k echo y | pip install obsidianhtml", , 
    MsgBox,, % script.name, % "Successfully updated to last Release."
    return
}
updateObsidianHTMLToMaster()
{
    RunWait, % A_Comspec "  /k echo y | pip uninstall obsidianhtml", , 
    RunWait, % A_Comspec "  /k echo y | pip install git+https://github.com/obsidian-html/obsidian-html.git", , 
    MsgBox,, % script.name, % "Successfully updated to Master."
    return
}
; --uID:4179423054
 ; Metadata:
  ; Snippet: Quote_ObsidianHTML  ;  (v.1)
  ; --------------------------------------------------------------
  ; Author: u/anonymous1184
  ; Source: https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
  ; (11.11.2022)
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 05 - String/Array/Text
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: apostrophe

 ;; Description:
  ;; Quote_ObsidianHTMLs a string

 ;;; Example:
  ;;; Var:="Hello World"
  ;;; msgbox, % Quote_ObsidianHTML(Var . " Test")
  ;;; 

 Quote_ObsidianHTML(String)
 { ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
      return """" String """"
 }


; --uID:4179423054
; --uID:3352591673
 ; Metadata:
  ; Snippet: writeFile_ObsidianHTML  ;  (v.1.0)
  ;  10 April 2023  ; --------------------------------------------------------------
  ; Author: Gewerd Strauss
  ; License: MIT
  ; --------------------------------------------------------------
  ; Library: Personal Library
  ; Section: 10 - Filesystem
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: encoding, UTF-8/UTF-8-RAW

 ;; Description:
  ;; Small function for writing files to disk in a safe manner when requiring specific file encodings or flags. 
  ;; Allows f.e. UTF-8 filewrites

 ;;; Example:
  ;;; Loop, Files, % Folder "\*." script.config.Config.filetype, F
  ;;;         {
  ;;;             scriptWorkingDir:=renameFile(A_LoopFileFullPath,Arr[A_Index],true,A_Index,TrueNumberOfFiles)
  ;;;             writeFile_ObsidianHTML(scriptWorkingDir "\gfa_renamer_log.txt",Files, "UTF-8-RAW","w",true)
  ;;;         }

 writeFile_ObsidianHTML(Path,Content,Encoding:="",Flags:=0x2,bSafeOverwrite:=false) { 
 
    if (bSafeOverwrite && FileExist(Path))  ;; if we want to ensure nonexistance.
        FileDelete, % Path
    if (Encoding!="")
    {
        if (fObj:=FileOpen(Path,Flags,Encoding))
        {
            fObj.Write(Content) ;; insert contents
            fObj.Close()        ;; close file
        }
        else
            throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
    }
    else
    {
        if (fObj:=FileOpen(Path,Flags))
        {
            fObj.Write(Content) ;; insert contents
            fObj.Close()        ;; close file
        }
        else
            throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
    }
    return
 }


; --uID:3352591673