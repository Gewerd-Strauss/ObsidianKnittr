#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Requires AutoHotkey v1.1.36+ ;; version at which script was written.
#SingleInstance,Force
#MaxHotkeysPerInterval, 99999999
#Warn All, Outputdebug
;#Persistent
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
DetectHiddenWindows, On
SetKeyDelay -1,-1
SetBatchLines,-1
SetTitleMatchMode, 2
/*
for creditsRaw, use "/" in the "URL"-field when the snippet is not published yet (e.g. for code you've written yourself and not published yet)
space author, SnippetNameX and URLX out by spaces or tabs, and remember to include "-" inbetween both fields
when 2+ snippets are located at the same url, concatenate them with "|" and treat them as a single one when putting together the URL's descriptor string
finally, make sure toingest 'CreditsRaw' into the 'credits'-field of the template below.
*/
creditsRaw=
(LTRIM
    Gewerd Strauss   -      main script
    tidbit et al - st_count - https://www.autohotkey.com/boards/viewtopic.php?t=53
    jNizM   -   HasVal  - https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
    SKAN        - Base64PNG_to_HICON, regarding licensing             -   https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36636, https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/
    author2,author3   -		 snippetName1		   		  			-	URL2,URL3
    Gewerd Strauss      -   partial, self-written subset of ScriptObj						    - https://github.com/Gewerd-Strauss/ScriptObj/blob/master/ScriptObj.ahk
    SKAN, Goyyah    - enableGuiDrag - http://autohotkey.com/board/topic/80594-how-to-enable-drag-for-a-gui-without-a-titlebar
    anonymous1184 - Quote   - https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
    Gewerd Strauss      - ttip      -   https://gist.github.com/Gewerd-Strauss/fad218c28b8120ab1a3cadea1a8dea9b
    hi5 - TF.ahk, license   - https://github.com/hi5/TF, https://github.com/hi5/TF/blob/master/license.txt
    anonymous1184, in request of help from Gewerd Strauss - SRC_ImageConverter
)
FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7, 2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7, 2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
global script := new script()

; script := {base : script.base
; ,vfile_local : A_ScriptDir "\version.ini"
; ,DataFolder:	A_ScriptDir ""
; ,configfolder : A_ScriptDir "\INI-Files"}

script := {base : script.base
    , name : regexreplace(A_ScriptName, "\.\w+")
    , crtdate : CrtDate
    , moddate : ModDate
    , offdoclink : A_ScriptDir "\assets\Documentation\GFA_Renamer_Readme.html"
    , resfolder : A_ScriptDir "\res"
    , iconfile	 : ""
    , version : ""
    , config: []
    , configfile : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
    , configfolder : A_ScriptDir "\INI-Files"
    , aboutPath : A_ScriptDir "\res\About.html"
    , reqInternet: false
    , rfile : "https://github.com/Gewerd-Strauss/OBSIDIANSCRIPTS/archive/refs/heads/master.zip"
    , vfile_raw : "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
    , vfile : "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
    ; , vfile_local : A_ScriptDir "\res\version.ini"
    , EL : "359b3d07acd54175a1257e311b5dfaa8370467c95f869d80dba32f4afdcae19f4485d67815d9c1f4fe9a024586584b3a0e37489e7cfaad8ce4bbc657ed79bd74"
    , authorID : "Laptop-C"
    , Computername : A_ComputerName
    , license : A_ScriptDir "\res\LICENSE.txt" ;; do not edit the variables above if you don't know what you are doing.
    , blank : "" }
global DEBUG:=IsDebug()
main()
ExitApp,
return

main() {
    global EL := new log(A_ScriptDir "\Executionlog.txt", true)
    fTraySetup()
    script.loadCredits(script.resfolder "\credits.txt")
    script.loadMetadata(script.resfolder "\meta.txt")
    erh:=Func("fonError").Bind(DEBUG)
    onError(erh)
    exh:=Func("fonExit").Bind(DEBUG)
    onExit(exh)
    if !script.load() {
        ;InputBox, given_obsidianhtml_configfile, % script.name " - Initiate settings","Please give the path of your configfile for obsidianhtml."
        InputBox, given_searchroot, % script.name " - Initiate settings","Please give the search root folder."
        InputBox, given_rscriptpath, % script.name,% "Please give the absolute path of your installed 'Rscript.exe'-file you wish to use.`nIf you don't want to use this step, leave this empty and continue.", , , , , , , , % "C:\Program Files\R\R-MAJORVERSION.MINORVERSION.PATCH\bin\Rscript.exe"
        InitialSettings=
        (LTrim
            [Config]
            bundleAHKRecompileStarter=0
            Destination=0
            FullLogOnSuccess=0
            HistoryLimit=25
            obsidianhtml_configfile=
            obsidianTagEndChars=():´
            OpenParentfolderInstead=1
            RScriptPath=%given_rscriptpath%
            searchroot=%given_searchroot%
            SetSearchRootToLastRunManuscriptFolder=1
            OHTML_OutputDir=%A_Desktop%\TempTemporal
            [Version]
            ObsidianHTML_Version=3.4.1
            ObsidianKnittr_Version=2.1.3
            [LastRun]
            Conversion=
            ForceFixPNGFiles=0
            FullLog=0
            InsertSetupChunk=0
            KeepFileName=1
            last_output_type=
            manuscriptpath=
            RemoveHashTagFromTags=1
            RenderRMD=1
            UseCustomTOC=0
            Verbose=0
            [GuiPositioning]
            H=
            W=
            X=
            Y=
            [DDLHistory]
        )
        writeFile(script.configfile,InitialSettings)
        script.load()
    }
    EL.ObsidianKnittr_Version:=script.version:=script.config.version.ObsidianKnittr_Version

    ; 2.2
    out:=guiShow()
    WorkDir := "C:\Users\Claudius Main\Desktop\TempTemporal"
    WorkDir_OwnFork := "D:\Dokumente neu\ObsidianPluginDev\obsidian-html"
    formats:=""
    for _,format in out.Outputformats {
        if format.HasKey("Error") && (format.Error.ID=0) {
            Reload
            ExitApp ;; fucking weird bug. DO NOT remove this exitapp below the reload-command. for some reason, removing it results in the script just ignoring the reload and continuing on as normal under certain situations
        }
        formats.=_ ", "
    }
    output_type:=out.sel
    if (output_type="All") || HasVal(output_type,"All") {
        output_type:=["html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document"] ;; todo:: add bookdown format support
    }
    if (HasVal(output_type,"First in YAML")) {
        output_type:=""
    }
    manuscriptpath:=out.manuscriptpath
    bVerboseCheckbox:=out.Settings.bVerboseCheckbox
    bFullLogCheckbox:=out.Settings.bFullLogCheckbox
    ;bSRCConverterVersion:=out.Settings.bSRCConverterVersion
    bKeepFilename:=out.Settings.bKeepFilename
    bRenderRMD:=out.Settings.bRenderRMD
    bRemoveHashTagFromTags:=out.Settings.bRemoveHashTagFromTags
    ;bUseCustomTOC:=out.3.7
    bForceFixPNGFiles:=out.Settings.bForceFixPNGFiles
    bInsertSetupChunk:=out.Settings.bInsertSetupChunk
    bConvertInsteadofRun:=out.Settings.bConvertInsteadofRun
    bRemoveObsidianHTMLErrors:=out.Settings.bRemoveObsidianHTMLErrors
    bUseOwnOHTMLFork:=out.Settings.bUseOwnOHTMLFork
    EL.formats:=SubStr(formats,1,StrLen(formats)-2)
    EL.manuscriptpath:=out.manuscriptpath
    EL.bVerboseCheckbox:=out.Settings.bVerboseCheckbox
    EL.bFullLogCheckbox:=out.Settings.bFullLogCheckbox
    EL.bSRCConverterVersion:=out.Settings.bSRCConverterVersion
    EL.bKeepFilename:=out.Settings.bKeepFilename
    EL.bRenderRMD:=out.Settings.bRenderRMD
    EL.bRemoveHashTagFromTags:=out.Settings.bRemoveHashTagFromTags
    EL.bForceFixPNGFiles:=out.Settings.bForceFixPNGFiles
    EL.bInsertSetupChunk:=out.Settings.bInsertSetupChunk
    EL.bConvertInsteadofRun:=out.Settings.bConvertInsteadofRun
    EL.bRemoveObsidianHTMLErrors:=out.Settings.bRemoveObsidianHTMLErrors
    EL.bUseOwnOHTMLFork:=out.Settings.bUseOwnOHTMLFork

    if (output_type="") && (bVerboseCheckbox="") {
        reload
    }
    obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    SplitPath, % manuscriptpath,,,, manuscriptName

    tmpconfig:=createTemporaryObsidianHTML_Config(manuscriptpath, obsidianhtml_configfile,bConvertInsteadofRun)
    EL.configtemplate_path:=obsidianhtml_configfile
    EL.configfile_contents:=tmpconfig[2]
    ttip("Running ObsidianHTML",5)
    if (obsidianhtml_configfile="") {
        obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    }
    EL.ObsidianHTML_Start:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec
    ATC1:=A_TickCount
    CodeTimer_Log("Timing ComObjTime, Verb: " (bConvertInsteadofRun?"Convert":"Run"))
    OHTML_OutputDir:=Deref(script.config.config.OHTML_OutputDir)
    if (tmpconfig[1] && bConvertInsteadofRun) {
        ret:=ObsidianHtml(,tmpconfig[1],,bUseOwnOHTMLFork,bVerboseCheckbox,OHTML_OutputDir,WorkDir,WorkDir_OwnFork)
    } else {
        ret:=ObsidianHtml(manuscriptpath,tmpconfig[1],,bUseOwnOHTMLFork,bVerboseCheckbox,OHTML_OutputDir,WorkDir,WorkDir_OwnFork)
    }
    EL.ObsidianHTML_Duration:=CodeTimer_Log("")
    EL.ObsidianHTML_End:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec
    EL.obsidianhtml_version:=strreplace(ret.obsidianhtml_version,"`n")
    EL.obsidianhtml_path:=ret.obsidianhtml_path
    EL.UsedVerb:=(bConvertInsteadofRun?"Convert":"Run")
    EL.ObsidianHTMLWorkDir:=ret["WorkDir"]
    EL.ObsidianHTMLOutputpath:=ret["Outputpath"]
    EL.ObsidianHTMLCopyDir:=ret["ObsidianHTMLCopyDir"]
    EL.CMD:=ret["CMD"]
    EL.data_out:=ret["stdOut"]
    if RegExMatch(ret["stdOut"], "md: (?<MDPath>.*)(\s*)", v) || FileExist(ret.OutputPath) {
        if FileExist(ret.OutputPath) {
            _:=SubStr(ret.OutputPath,-1)
            vMDPath:=strreplace(ret.OutputPath (SubStr(ret.OutputPath,-1)="md"?"":"/md"),"//","\")
            vMDPath:=strreplace(vMDPath ,"/","\")
        }
        vMDPath:=Trim(vMDPath)
        vMDPath:=strreplace(vMDPath,"`n")
        script.config.version.ObsidianHTML_Version:=strreplace(ret.obsidianhtml_Version,"`n")
        if !FileExist(vMDPath) {
            MsgBox 0x40010, % script.name, % "File md_Path does not seem to exist. Please check manually."
        }
    } else {
        if RegExMatch(ret["stdOut"], "Created empty output folder path (?<MDPath>.*)(\s*)", v) {
            if !FileExist(vMDPath) {
                MsgBox 0x40010, % script.name, % "File md_Path does not seem to exist. Please check manually."
            }
        } else {
            MsgBox, 0x40010, % script.name " - Output could not be parsed.", % "DO NOT CONTINUE WITHOUT FULLY READING THIS!`n`nThe command line output of obsidianhtml does not contain the required information.`nThe output has been copied to the clipboard, and written to file under '" A_ScriptDir "\Executionlog.txt" "'`n`nTo carry on, find the path of the md-file and copy it to your clipboard.`nONLY THEN close this window."
        }
    }

    ;; Intermediary
    EL.Intermediary_Start:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec
    CodeTimer_Log("")
    ttip("Converting to .rmd-file",5)
    rmd_Path:=convertMDToRMD(vMDPath,"index")
    ; 5, 6
    ttip("Moving to output folder",5)
    rmd_Path:=copyBack(rmd_Path,script.config.Destination,manuscriptpath)
    SplitPath, % rmd_Path,, OutDir
    rawinputCopyLocation:=regexreplace(OutDir "\" manuscriptName "_vault.md ","\\{2,}","\")
    EL.output_path
    EL.rawInputcopyLocation:=rawinputCopyLocation
    ; 7
    ttip("Converting Image SRC's")
    NewContents:=ConvertSRC_SYNTAX_V4(rmd_Path,bDontInsertSetupChunk,bRemoveObsidianHTMLErrors)
    ttip("Processing Tags",5)
    NewContents:=processTags(NewContents,bRemoveHashTagFromTags)
    ttip("Processing Abstract",5)
    NewContents:=processAbstract(NewContents)
    EL.Intermediary_Duration:=CodeTimer_Log("Intermediary")
    EL.Intermediary_End:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec

    ;; R
    EL.RScriptExecution_Start:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec
    CodeTimer_Log("")
    writeFile(rmd_Path,NewContents,"UTF-8",,true)
    ttip("Creating R-BuildScript",5)
    if bKeepFilename {
        tmp:=buildRScriptContent(rmd_Path,manuscriptName,out)
    } else {
        tmp:=buildRScriptContent(rmd_Path,,out)
    }
    script_contents:=tmp.1
    format:=tmp.2
    if bRenderRMD {
        ttip("Executing R-BuildScript",5)
        runRScript(rmd_Path,script_contents,script.config.config.RScriptPath)
    } Else {
        ttip("Opening RMD-File",5)
        SplitPath, % rmd_Path,, OutDir
        writeFile(OutDir "\build.R",script_contents,"UTF-8-RAW",,true)
        if (!DEBUG) {
            run, % rmd_Path
        }
    }
    EL.DocumentSettings:=tmp[2]
    EL.RScriptExecution_Duration:=CodeTimer_Log("")
    EL.RScriptExecution_End:=A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec
    EL.getTotalDuration(ATC1,A_TickCount)

    ;; final touches - ahk starter, moving shit to output folder
    ttip("Building AHK-Starterscript",5)
    buildAHKScriptContent(rmd_Path,script.config.config.RScriptPath)
    SplitPath, % Path,, OutDir
    SplitPath, % OutDir,, OutDir2
    if script.config.config.OpenParentfolderInstead {
        EL.output_path:=OutDir
    } else {
        EL.output_path:=OutDir2
    }
    if !DEBUG {
        openFolder(rmd_Path)
    }
    SplitPath, % rmd_Path, , OutDir
    FileMove, % EL.__path, % OutDir "\Executionlog.txt",true
    removeTempDir(md_Path)
    removeTempDir(ret.OutputPath)

    script.save()
    return
}

openFolder(Path) {
    SplitPath, % Path,, OutDir
    SplitPath, % OutDir, OutFileName, OutDir2
    if (WinExist(OutFileName " ahk_exe explorer.exe")) {
        WinActivate
        return
    }
    if script.config.config.OpenParentfolderInstead {
        run, % OutDir2
    } else {
        run, % OutDir
    }
    return
}

buildAHKScriptContent(Path,RScript_Path:="") {
    SplitPath, % Path,, OutDir
    if script.config.config.bundleAHKStarter && (RScript_Path!="") {
        RSCRIPT_PATH:=RScript_Path
        BUILD_RPATH:=strreplace(OutDir "\build.R","\","\\")
        OUTDIR_PATH:=OutDir
        AHK_Build=
        (Join`s LTRIM
            #Requires AutoHotkey v1.1.36+
            `nrun, `% Clipboard:=`"`"`"%RSCRIPT_PATH%"""
            A_Space """%BUILD_RPATH%"""
            , `% "%OUTDIR_PATH%"
        )
        writeFile(OutDir "\build.ahk",AHK_Build,"UTF-8",,true)
    }
    return
}
copyBack(Source,Destination,manuscriptpath) {
    SplitPath, % Source, OutFileName, Dir,
    SplitPath, % manuscriptpath,,,,manuscriptname,
    if Destination {
        if FileExist(Destination "\" manuscriptname "\") { ;; make sure the output is clean
            FileRemoveDir, % Destination "\" manuscriptname "\", true
        }
        FileCopyDir, % Dir, % Output_Path:=Destination "\" manuscriptname "\", true
        writeFile(Output_Path "\index.md",Clipboard:=manuscriptcontent,,,true)
        FileCopy, % manuscriptpath, % rawinputCopyLocation, 1
    } Else {
        FileCopyDir, % Dir, % Output_Path:= A_Desktop "\TempTemporal\" manuscriptname "\" , true
        if Errorlevel {
            msgbox, % Errorlevel
        }
        global pd:=regexreplace(Output_Path "\" manuscriptname "_vault.md ","\\{2,}","\")
        pd:=Trim(pd)
        FileCopy, % manuscriptpath, % pd, 1
    }
    return Output_Path OutFileName
}
getOutputPath(Destination,manuscriptpath) {
    SplitPath, % manuscriptpath,,,, manuscriptname
    if Destination {
        Output_Path:=Destination "\" manuscriptname "\"
        Raw_InputFile:=Output_Path "\" manuscriptname "_vault.md"
    } else {
        Output_Path:= A_Desktop "\TempTemporal\" manuscriptname
        Raw_InputFile:=Output_Path "\" manuscriptname "_vault.md "
    }
    return [Output_Path,Raw_InputFile]
}
convertMDToRMD(md_Path,notename) {
    OldName:=md_Path "\" notename ".md"
    NewName:=md_Path "\" notename ".rmd"
    FileCopy, % OldName, % NewName, true
    return NewName
}
removeTempDir(Path,RemoveParent:=TRUE) {
    SplitPath, % Path,, OutDir
    if RemoveParent {
        FileRemoveDir, % OutDir,1
        if FileExist(OutDir) {
            MsgBox, % "Error occured - Directory '" OutDir "' could not be removed"
            Run, % "explorer " OutDir
        }
    } else {
        FileRemoveDir, % Path,1
        if FileExist(Path) {
            MsgBox, % "Error occured - Directory '" Path "' could not be removed"
            Run, % "explorer " Path
        }
    }
    return
}
processAbstract(Contents) {
    if (FileExist(Contents)) {
        FileRead Contents, % Contents
    }
    Lines:=Strsplit(Contents,"`r`n")
        , Rebuild:=""
    for index, Line in Lines
    {
        if (st_count(Rebuild,"`n")>1) {
            Rebuild.="`n" Line
            continue
        }
        if (!Instr(Rebuild,"abstract")) {
            Rebuild.=((index=1)?Line:"`n" Line)
        } else {
            Rebuild.=((SubStr(Line,1,2)=" ")?A_Space LTrim(Line):"`n" Line)
        }
    }
    return Rebuild
}
processTags(Contents,bRemoveHashTagFromTags) {
    if (FileExist(Contents)) {
        FileRead Contents, % Contents
    }
    AlreadyReplaced:=""
    if Instr(Contents,"_obsidian_pattern") {
        Tags:=Strsplit(Contents,"tags:").2

        ;; eliminate duplicates
        Lines:=strsplit(Tags,"`r`n")
        Tags:=""
        for _, Line in Lines {
            if SubStr(Line,1,2)="- " && !Instr(Tags,Line) {
                Tags.=Line "`r`n"
            }
            if SubStr(Line,1,2)="- " {
                OrigTags.=Line "`r`n"
            }
            if SubStr(Line,1,3)="---" {
                break
            }
        }
        if (Tags="") {
            Tag:=Trim(Lines[1])
            Needle:="``{_obsidian_pattern_tag_" Tag "}``"
            if bRemoveHashTagFromTags {
                Contents:=Strreplace(Contents,Needle,Tag)
                if Instr(Contents,Tag) && !Instr(Contents,Needle) {
                    Tags:=""
                }
            } else {
                Contents:=Strreplace(Contents,Needle,"#" Tag)
                if Instr(Contents,"#" Tag) {
                    Tags:=""
                }
            }
            AlreadyReplaced.=Tag "`n"
        } else {
            Tags:=Trim(Tags)
            Tags:=Strsplit(Tags,"`r`n")
            for ind,Tag in Tags {
                if (SubStr(Tag,1,1)="-") {
                    Tags[ind]:=SubStr(Tag,3)
                }
            }

            for ind, Tag in Tags
            {
                loop, Parse, % script.config.Config.obsidianTagEndChars
                {
                    Tags[ind]:=(InStr(Tags[ind],A_LoopField)?StrSplit(Tags[ind],A_LoopField).1:Tags[ind])
                }
            }
            for ind, Tag in Tags {
                if (Tag="") && !Instr(AlreadyReplaced,Tag) {
                    continue
                }
                Needle:="``{_obsidian_pattern_tag_" Tag "}``"
                if bRemoveHashTagFromTags {
                    if !Instr(Contents,Needle) {
                        continue
                    }
                    Contents:=Strreplace(Contents,Needle,Tag)
                    if Instr(Contents,Tag) && !Instr(Contents,Needle) {
                        Tags[ind]:=""
                    }
                } else {
                    if !Instr(Contents,Needle) {
                        continue
                    }
                    Contents:=Strreplace(Contents,Needle,"#" Tag)
                    if Instr(Contents,"#" Tag) {
                        Tags[ind]:=""
                    }
                }
                AlreadyReplaced.=Tag "`n"
            }
            rebuild:="`r`n"
            for ind, Tag in Tags {
                if (Tag="") {
                    continue
                }
                rebuild.="- " Tag "`r`n"
            }
            ;rebuild.="---"
            Contents:=strreplace(Contents,OrigTags,rebuild)
            Contents:=StrReplace(Contents,"---`r`n---", "`r`n---`r`n",,1)
            Contents:=StrReplace(Contents,"`r`n`r`n", "`r`n",,1)
        }
        Matches:=RegexMatchAll(Contents,"(?<IDStart>\{_obsidian_pattern_tag_)(?<Tag>.+)(?<IDEnd>}`)")
        for _, match in Matches {
            _match:=match[0]
            Contents:=strreplace(Contents,"``" _match "``",(bRemoveHashTagFromTags?"":"#") match[2])
        }
    }
    ;;  TODO: regexreplaceall for these patterns: "`{_obsidian_pattern_tag_XXXX}", as they are not found in the frontmatter and thus are not replaced
    return Contents
}
guiCreate() {
    global
    gui, destroy
    PotentialOutputs:=["First in YAML" , "html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document" , "All"]
    Gui, Margin, 16, 16
    Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC +hwndOKGui
    Gui, Color, 1d1f21, 373b41,
    Gui, Font, s11 cWhite, Segoe UI
    gui, add, text,xm ym, Choose output type:
    WideControlWidth:=330
    gui, add, listview, vvLV1 cWhite LV0x8 w%WideControlWidth% checked, % "Type"
    for _,output_type in PotentialOutputs {
        Options:=((Instr(script.config.lastrun.last_output_type,output_type))?"Check":"-Check")
        LV_Add(Options,output_type)
    }
    HistoryString:=""
    for each, File in script.config.DDLHistory {
        SplitPath, % File, , OutDir, , FileName
        SplitPath, % OutDir,OutFileName
        HistoryString.=((each=1)?"":"|") FileName "(" OutFileName ")" " -<>- " File
        if (each=1) {
            HistoryString.="|"
        }
    }
    Gui, add, button, gChooseFile, &Choose Manuscript
    DDLRows:=script.config.Config.HistoryLimit
    gui, add, DDL, w%WideControlWidth% vChosenFile hwndChsnFile r%DDLRows%, % HistoryString
    gui, add, checkbox, vbConvertInsteadofRun, % "!!Use verb 'Convert' for OHTML-call?"
    gui, add, checkbox, vbUseOwnOHTMLFork, % "!!!Use the personal fork? *CAUTION*"
    gui, add, checkbox, vbRemoveObsidianHTMLErrors, % "!Purge OHTML-Error-strings?"
    gui, add, checkbox, vbFullLogCheckbox, % "Full Log on successful execution?"
    gui, add, checkbox, vbVerboseCheckbox, % "Set OHTML's Verbose-Flag?"
    Gui, Add, Text, w%WideControlWidth% h1 0x7 ;Horizontal Line > Black
    gui, add, checkbox, vbRemoveHashTagFromTags, % "Remove '#' from tags?"
    gui, add, checkbox, vbInsertSetupChunk, % "!Insert Setup-Chunk?"
    gui, add, checkbox, vbForceFixPNGFiles, % "Double-convert png-files pre-conversion?"
    gui, add, checkbox, vbKeepFilename, % "Keep Filename?"
    gui, add, checkbox, vbRenderRMD, % "Render RMD to chosen outputs?"
    Gui, Font, s7 cWhite, Verdana
    gui, add, button, gGCSubmit, &Submit
    gui, add, button, gGCAutoSubmit yp xp+60, &Full Submit
    onOpenConfig:=Func("EditMainConfig").Bind(script.configfile)
    gui, add, button, hwndOpenConfig yp xp+81, Edit General Config
    gui, add, button, gGCAbout hwndAbout yp xp+122, &About
    GuiControl, +g,%OpenConfig%, % onOpenConfig
    Gui, Add, Text,x15,% script.name " v." script.config.version.ObsidianKnittr_Version " | Obsidian-HTML v." strreplace(script.config.version.ObsidianHTML_Version,"commit:")
    script.version:=script.config.version.ObsidianKnittr_Version

    if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="") {
        SplitPath, % script.config.lastrun.manuscriptpath, , OutDir
        SplitPath, % OutDir, OutFileName, OutDir,
        guicontrol,, bVerboseCheckbox, % (script.config.LastRun.Verbose)
        guicontrol,, bFullLogCheckbox, % (script.config.LastRun.FullLog)
        guicontrol,, bSRCConverterVersion, % (script.config.LastRun.Conversion)
        guicontrol,, bKeepFilename, % (script.config.LastRun.KeepFileName)
        guicontrol,, bRenderRMD, % (script.config.LastRun.RenderRMD)
        guicontrol,, bRemoveHashTagFromTags, % (script.config.LastRun.RemoveHashTagFromTags)
        guicontrol,, bForceFixPNGFiles, % (script.config.LastRun.ForceFixPNGFiles)
        guicontrol,, bInsertSetupChunk, % (script.config.LastRun.InsertSetupChunk)
        guicontrol,, bConvertInsteadofRun, % (script.config.LastRun.ConvertInsteadofRun)
        guicontrol,, bRemoveObsidianHTMLErrors, % (script.config.LastRun.RemoveObsidianHTMLErrors)
        guicontrol,, bUseOwnOHTMLFork, % (script.config.LastRun.UseOwnOHTMLFork)
    }
    return
}
GCAutoSubmit() {
    global bAutoSubmitOTGUI:=True
    return guiSubmit()
}

guiShow() {
    global
    guiCreate()
    x:=(script.config.GuiPositioning.X!=""?script.config.GuiPositioning.X:200)
    y:=(script.config.GuiPositioning.Y!=""?script.config.GuiPositioning.Y:200)
    bAutoSubmitOTGUI:=false
    gui,1: show,x%x% y%y%, % script.name " - Choose manuscript"
    enableGuiDrag(1)
    WinWaitClose, % script.name " - Choose manuscript"
    Outputformats:={}
    for _, format in sel {
        ot:=new ot(format,A_ScriptDir "\INI-Files\DynamicArguments.ini","-<>-")
        if bAutoSubmitOTGUI {
            ot.SkipGUI:=bAutoSubmitOTGUI
        }
        ot.GenerateGUI(x,y)
        ot.AssembleFormatString()
        Outputformats[format]:=ot
    }
    if (manuscriptpath!="") && !ot.bClosedNoSubmit {
        return {"sel":sel
            ,"manuscriptpath":manuscriptpath
            ,Settings:{"bVerboseCheckbox":bVerboseCheckbox + 0
                ,"bFullLogCheckbox":bFullLogCheckbox + 0
                ,"bSRCConverterVersion":bSRCConverterVersion + 0
                ,"bKeepFilename":bKeepFilename + 0
                ,"bRenderRMD":bRenderRMD + 0
                ,"bRemoveHashTagFromTags":bRemoveHashTagFromTags + 0
                ,"bUseCustomTOC":bUseCustomTOC + 0
                ,"bForceFixPNGFiles":bForceFixPNGFiles + 0
                ,"bInsertSetupChunk":bInsertSetupChunk + 0
                ,"bConvertInsteadofRun":bConvertInsteadofRun + 0
                ,"bRemoveObsidianHTMLErrors":bRemoveObsidianHTMLErrors + 0
                ,"bUseOwnOHTMLFork":bUseOwnOHTMLFork + 0}
            ,"Outputformats":Outputformats}
    } Else {
        ExitApp
    }
}

GCAbout() {
    script.About()
}
GCEscape() {
    guiEscape()
}
GCSubmit() {
    ret:=guiSubmit()
    return ret
}
guiEscape() {
    gui, destroy
    return
}
guiSubmit() {
    global
    gui, 1: default
    sel:=getSelectedLVEntries()
    gui, submit
    gui, destroy
    if Instr(ChosenFile,"-<>-") {
        ChosenFile:=Trim(StrSplit(chosenFile,"-<>-").2)
    }
    manuscriptpath:=ChosenFile
    if (script.config.LastRun.manuscriptpath!="") && (manuscriptpath="") {
        manuscriptpath:=script.config.LastRun.manuscriptpath
        bVerboseCheckbox:=bVerboseCheckbox+0
        bFullLogCheckbox:=bFullLogCheckbox+0
    }
    if (manuscriptpath="") && (sel.count()=0) {
        if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="") {
            if IsObject(strsplit(script.config.LastRun.last_output_type,", ")) {
                sel:=strsplit(script.config.lastrun.last_output_type,", ")
            } else {
                sel:=script.config.lastrun.last_output_type
            }
            manuscriptpath:=script.config.lastrun.manuscriptpath
            bVerboseCheckbox:=script.config.LastRun.Verbose+0
            bFullLogCheckbox:=script.config.LastRun.FullLog+0
        }
    }
    if !FileExist(manuscriptpath) {
        manuscriptpath:=chooseFile()
    }
    script.config.LastRun.manuscriptpath:=manuscriptpath
    script.config.LastRun.last_output_type:=""
    script.config.LastRun.Verbose:=bVerboseCheckbox+0
    script.config.LastRun.FullLog:=bFullLogCheckbox+0
    script.config.LastRun.Conversion:=bSRCConverterVersion+0
    script.config.LastRun.KeepFileName:=bKeepFilename+0
    script.config.LastRun.RenderRMD:=bRenderRMD+0
    script.config.LastRun.RemoveHashTagFromTags:=bRemoveHashTagFromTags+0
    script.config.LastRun.ForceFixPNGFiles:=bForceFixPNGFiles+0
    script.config.LastRun.InsertSetupChunk:=bInsertSetupChunk+0
    script.config.LastRun.ConvertInsteadofRun:=bConvertInsteadofRun+0
    script.config.LastRun.RemoveObsidianHTMLErrors:=bRemoveObsidianHTMLErrors+0
    script.config.LastRun.UseOwnOHTMLFork:=bUseOwnOHTMLFork+0
    script.config.DDLHistory:=buildHistory(script.config.DDLHistory,script.config.Config.HistoryLimit,script.config.LastRun.manuscriptpath)

    for each,output_type in sel {
        script.config.LastRun.last_output_type.=output_type
        if (each<sel.count()) {
            script.config.LastRun.last_output_type.=", "
        }

    }
    script.save()
    return [DDLval,manuscriptpath,sel]
}
buildHistory(History,NumberOfRecords,manuscriptpath:="") {
    if (manuscriptpath!="") {
        if HasVal(History,manuscriptpath) {
            History.RemoveAt(HasVal(History,manuscriptpath),1)
        }
        History.InsertAt(1,manuscriptpath)
    }
    if (History.Count()>NumberOfRecords) {
        History.Delete(NumberOfRecords+1,History.Count())
    }
    return History
}
getSelectedLVEntries() {
    vRowNum:=0
    sel:=[]
    loop {
        vRowNum:=LV_GetNext(vRowNum,"C")
        if not vRowNum {
            break ; The above returned zero, so there are no more selected rows.
        }
        LV_GetText(sCurrText1,vRowNum,1)
        sel.push(sCurrText1)
    }
    return sel
}
editMainConfig(configfile) {
    static
    gui, Submit, NoHide
    RunWait, % configfile,,,PID
    WinWaitClose, % "ahk_PID" PID
    Gui +OwnDialogs
    OnMessage(0x44, "DA_OnMsgBox")
    MsgBox 0x40044, % this.ClassName " > " A_ThisFunc "()", You modified the configuration for this class.`nReload?
    OnMessage(0x44, "")
    IfMsgBox Yes, {
        reload
    } Else IfMsgBox No, {

    }
}
chooseFile() {
    ;global
    if FileExist(strreplace(clipboard,"/","\")) {
        clipboard:=strreplace(clipboard,"/","\")
    } else {
        ttip("Clipboard does not contain a valid path.")
    }
    SplitPath, % clipboard, , , Ext
    if CF_bool:=FileExist(clipboard) && (Ext="md") && !GetKeyState("LShift","P") {
        manuscriptpath:=(CF_bool?clipboard:script.config.searchroot)
    } else {
        if script.config.config.SetSearchRootToLastRunManuscriptFolder {
            SplitPath, % script.config.Lastrun.manuscriptpath,, LastRunDir
            FileSelectFile, manuscriptpath, 3, % (FileExist(clipboard)?clipboard:LastRunDir) , % "Choose &manuscript file", *.md
        } else {
            FileSelectFile, manuscriptpath, 3, % (FileExist(clipboard)?clipboard:script.config.config.searchroot) , % "Choose &manuscript file", *.md
        }
        if (manuscriptpath="") {
            return
        }
    }
    script.config.DDLHistory:=buildHistory(script.config.DDLHistory,script.config.Config.HistoryLimit,manuscriptpath)
    HistoryString:=""
    for each, File in script.config.DDLHistory {
        SplitPath, % File, , OutDir, , FileName
        SplitPath, % OutDir,OutFileName
        HistoryString.=((each=1)?"":"|") FileName "(" OutFileName ")" " -<>- " File
        if (each=1) {
            HistoryString.="|"
        }
    }
    GuiControl,, ChosenFile, |
    guicontrol,, ChosenFile, % HistoryString
    return manuscriptpath
}

fTraySetup() {
    b64QuickIcon_64x64 := "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAABlFSURBVHhe1VsJeE3X9r+JKYMgEkNQKaE1JyQiIUIkkoiIKaMkMojUFEMoQWZBZELEFKqpMTw6PGqq0kGLp2iK0j9qKJGipoRoi/XWWufsc8+9Lv++V31t1/et78xnr99vr7X22vvcq/kTpM727dubV1dXtzl+/Lj9wYMHnY6cOOHw9OnTNjt37mxha2trIt/39xcAqHn27Nkul69eHXP79u1Vd+7c+bSqqupCZVVV5a+PHz95/PgxCKVjvFZVWVn5/d27dz9DXV1eXj7u5MmT9viqWtIb/yZiojFxbdX4tcXvb9t+Bkn4XfLLL79A1YMH3924cWNpWVlZb7mJv57YODqa1Te2jnNu2/+orcXrUF9jDc3MX4XREWPh25PfynAAnjx9Ck+ePFH0sazqc2pVy1PU+/fvn7h69eq4tLS0unLTf7oYY/yOnxA18btGxi1hoEsMeHULhhZmbaCexgpqaEygUe1mMOmNqfD9ue8lJChMhKz4PKsgR02Iel8tDx48OH/t2rVJ2H5NyYw/QTA+PaofVR96WFUNbRu3g45NXSDQawIM6fMGeDoEwStIgqWmETRANdLUgeb1bCFjVhZUlP8ow8BeFeARoNj+v4r3Cbl3795X3377rbds0v9Mal2/fr2AkhfJm2OToLbGAjzsgyAhJgfiQ9PB23EEekIItDBtjQRYg7XGhj3CSFMbWjd6HXLn5MP9e5X8PInWA17sBWKftzIR9GxFRcWywMBAU9m+P06OHDnyGmbzL7hllO/O/B9Y1m4ErzXsBoOx52dPKYaUxGLw7xkNvs6R4NU1GJozCVZgbWTDRNTVWLJH2Ns5QvGS1VBd/Uh+m0yEHlhDStfEdSHoDUf/9a9/dZJNffmC43YfjL2bcnss8WHjGIxbhwCIHjIT5sx8h/WNsAzoZx8Mfi5RMgl2iidI2hRMNfVAgx7h3LEXlK7dzOCFPH36LGD1MalOyMjPon13z5w54yOb/PLk9NmzQ6ofPXpIjVCDJF8f+wYsjC2hlUUHGNAjAhJH50NmUgmkv/kW61D0CK+uoUhCDHgiCepwsDZqyh5hhfsmSAQlS48e/eGDrdv53UKoreeBZwJYpXN0H8mjR49+OX/+fJhs+u+Xc+fODf7555/57dQINs0NjRgUhb1fC5zbeENw/wRIn76GgadNWw1Z6AUTY7IxGYaCT/cImYQQaG5GnoDhgMAJPHkCaUPU2hpzqKUxgwF9A+CjXfu4DSHUriBCC1ybQAUBggTavhQSjh075o6MKj1PSvL5gS/QhS3gFdO24InJbuyIDHZ9Ak9KRGTOKIEgJMYTvUAiIVoiwbSVlgT0BEnJK4iUJkiCOXvFUN8gbOcgtydEABfgmRQ+lmxT24jl9q84Uv334YB1uh2+5Cd6mWCXGiXxdxsMxhi/DrbuMKh3HMxKWAoZ6AGCANLMpHcgMX4h9McRwdspXEUC5gQzCoeGDJ48gLxBIQP3LZGImugN5nhPWEAkfHnwELcrep+2Yl/nWLZTkPDw4cP7mLg7ypB+uzg6OtbCbH+YXiJeSkqy8/3d6K5m0KTWK9CnyzCIDHgT5iBYNXg1CWF+k6GfQwgT4O0UgfkiGofIUCyWRDgILyAyBBHoEcbN8LgZJsqaqBrIL8jn9tXgxb44VhMg7MXRoWzKlCn/2RCJ5eYieli8lJQaobG/Txcv7B1TaN/ECQa4jIQpcXmc/PTBp0wt5vNJ44sYvPAEUiKBwqGFuUSClVETCTQRgGpthODx2MzYAoyMjZiAzp07sx3CLh3wso2kggBWvEaCdcsKCdlvkK++/trtKT5MIl4o2Ny87h8I3oSzeK/2/pz8yPVF8pN0FaROXQXzkjdBwdx/wsKsHRAXmM6FkiBAImGkVCyZt8G5gxwOCLoR9noDI2uoZVwbNMYaMDKSCKDtV199xXYoHaNHgLr3xb6Q02VlnhLCF0tNnIoepwfULyOpflgNzq+7cba2a9CRe3Rs+BzO+AI8AU9DXZC+FQoX7IbF83dC4fxdMHdmKfj1xHkCJkQtCSOQhChOkuQJlvIQWde4HoI1Bo2RBoyNjVkFCTNnzmRbdHpfRYBQYbu4ToITqVMJvr51JJjPkYsXL46lm+khfRZXLXmLix5LTWNwsvOEwe6jYdakZdz7qXKvp01dDXkZ26AwezcsQvBEwOL5H8KCtC0QG5gMHl2EF6jDgYqlEGhs2hxHALnX5Z7XJ6Bjx45KhygE0MAsAxUeYeiY5PLly1MkpAYEp5gmlZWVl+lGNZskWGGBw6vdcXiygOYmraAvJr9RgSmQm74NCZCGPSIgF3t+idzzi7N3wcJ5OyBz5jpIw3uSp6yEgeQF3cIU8EIH9YwD+zZuiqsL0BT/agJIDx3SjggMFG0U+8o5A+dJcFQoLyoqMjyVvnDhwii+C0X/wWX5K7j3KVY72jiDT49IyEraBquLTsDS3IPo7vsgP+sD7PldCnjygHmzN/LcgMJjzsy18EZ4pkECfLuP5JAyrW3OIJWeF0TIStcSExPZJrSO7Xtez6tVjeXSpUsTGLCeGOFw8Q2/mG6m3pcfuHf3HnRoZg9mmvqcrV1f94WY4XNg/aorsG7VRVhTdAaK8j6BRSrwlPzmp5TCfCQgc/rbHCIiUQ52j4f+TAINi1oS/F1HQWubjjoEiN5XE2BnZwdYmbJtAhip8Fj1OX0luV95/zt8j+46AmZXF+HuzJr8IpKF8wrl2G8Ereq1h/5OoZCTshe2rLsKpW+Xw/ri72F5wUHscex1BE+eMD95I4PP5u16Bk+agrPFALdR3NuiLpAIwCIJh8ZenQYpoA2RgKayHjhwgG0TwMheka/UvS72xbGQEydO9GXgQipu3CiiC8pDMhl3bt+F9jb2YIGu35CSX+t+MLzfBOz1MigtIQIqoHRNOZQsO8VekDfnfQS/QQa/SSZiE44C65iA2ZOWw0DXaCSAKsNIJkFsBQmNGzR/1gv0SEhISGD7FAJUEyImAVVg0d4jKcnNW7dWMXCS+Pj4WjhEXKAL6gdI0mZnYIO1eXhqYdIGx/LhED00Gd3/DKxffQEJuA6bSypg41tXoCh3P8b8BrnXJQLE/nw8n5W0FpISirh4ol7XEqBVf5dY6Nq2D4N8kRe0atWKEhrbqAA0QIC+0nkSxPsDJX0m4PDhw/a//vorXxA3klRUVED9BvVxqloHq7Om0KV5T+y5UJgcuxBKik9DyYpTsAFJ2FxyHcPgPORlvo8ErMdex55n0FIIEBH5mVKCnDVpJQKVYl6fADpHyZA8wdyU1goM5wI6T7p79262U7eXZQJwqz0nqdgnIaKOHj3qTPg1V65eHUcn6RI/RAco06ZNU3qiYY3G4NF5GBoYDsmTV0HBvO043O2DNUvL4J3lp2HlwsOQm/Eu9zT3OoaBAJ+NRCycuwNWLPoMZ4gbEKB2cmTICwa5xsFrLRwkArBtBo/DoSBAkDBuHJutBYqgCBipck5W9T3CC8rLyxMJP8V/CZ3gm+WLp06dAjMzM4Xt5tatwa97FE5vJ0B22ias9DZDdmopLJr7ISya9yGC38bHEmhtzyv7OCIsydmLz73PJbC3yAFOssrgvVFpntDHYRjUrFFLal8FXE2Ara0tPFCFgSCAtvrgxTmhJD/++GMpvkejuXP3Lk+6xcMkW7duVcCT1q9rxeN3qO8krPHXIyB0c9aNXPNz4mOVAJMnSN5AJGyCebPWc1GUwwRg5dc9FLx6BIOnrN7dySu0XkBDIpHO7T+HANJdu3axvWS3mgABXiFAbOXrJJgHjmr8/f3N7ldWXlG/hOTatWtgYWHBjYgGndv1h4HYO4nxBZAxg8b2tyALgVHvzkPQuRlbuRKkYS8v813IxxGBwBMpeXhtecEB9JJ3wcslCEEHgrczgkb1cg4FTzrnHIzeIBEwEJOhc3tvmQDJBiNlqyVh9OjRbK+6d/WBi331MQlWvdc16OotMZtW0wk1ASR9+/blRigGaduyyWvg6zQSIgZNxfK2BKe7WNzgTJB6ekHaZqwGpUKIK0Ish4tyP8Ze3wkFOBtchnVCceGXMHXiYujnFAg+jqK3RQhEgqdrIJJB6waRmGsi2VMsLRpx22rgagJatGjBZTqJAKmvjEtOikyAjBGLqceamzdvvo4jAFNCF9iF8GaSWbNmSY3L8/E6tU3Bs1sw+GM9n5SwFOv7NZCMZW4W9vjibJz1IWjK9NIWCcjZBysWfgnFi7+Ct5adhAIkKH5kKpIYyYmQRgPh8kI9XYZjOEjnKQzs7Xq/kADSnTt3sr2GgWu36msktLah+fzzzx1ph0QhAJWEXiwaEQ3ShGUADlWxQckYBiU87c2b8x4ClmZ+Yga4ZMFeHhmKFx+CVUXHYQ0SkJm6HibHF/JHE28cTiUCVCSg+1NeULzAWaoXzEy0oaivdD5ulDSFYdCyCgLUW7Ev8NF9mv379/eiCyQEXk0AZkmoX7++DgHWDWxgABrm3ysG5uLwtjT3I2X2R+BJC0llTyjK+ZgrxOUFn0JGcimkvPkxhPrlM3BvLKkV8IIABC8IoHM0S3ztlW4vJKB58+b0BZlt1u9phQyxVeEjoSJIxwNIiQQhffpqqzLaGhsZQ89OA2CI2wxInbwDlubtUYArHiCDL8BckJ26BeZioizI+idkJm+DNye+B6NHfABhA+ZyjGvrgQiOe88eQeDlpCWAhkSPrkFQq1YdgyTQOVJ1GBBYoQoRiEm6psVHx8/kAKF0kSQlJUWnYdq3bfo6DHWfCmNCKPax92X3Z+CoSxbswcJnu7JGkI6jBa0N5szZA2PjVkFc2LsQPXgpBHrMQALCZAIQsHM4ePQYpkyUhPpjYfSqTXuDBAiboqKi2F6y+hnwpAKbvE/COeD06dO21fLHObqghAHeSELjLDXAKjdmUtsMk2EgDOqVgCC3oBfs5aSXk74NR4e1MD91M68SS+DFUlkxesNWmDBqEQz3y4SowUsgsN9MzAVh3PME3tN1KNYHIXKRpPUM+uTu1plmiTUMkkDnbGxsoKqqim0WoNUE8JZwyUpCH3s0ERER5vjgD8qDejfdunULrKysdBqmfQc7Nx7KooenwbL8fTj/3y6vC67SLo/J4IVmJr0NY0ZkYYxHQIDnePBzjwPP7lJN0Nd5CE6SwmBwzygGLY0EUhjQdqDLKGhqZSvboUsCnSN93mjAuFRb0blYCP2Iz2k0uPOleJCAqxMhibe3VJCoG7Su3wz8nKMwU0dA8pTVWBCt49XhqfH5MDku55mPJKT05Wh0SBp4OoRAf3T9fk7DoV/3QNwGYWKNgKE9o1FHQoCrmC3KocFeYKgw0iUhOjqa7dUHra8CG+I+hs9pNDdu3VhHJ+gBAV4oSVZWlkSAPCOjfUqG5Jbe3cIhelgSu7z0KWw8jA3PwOMSdn/KA2oCRgWlMAEEilzfl7cR2PMjYQjqYJdICOn3BoT7JXLpLQigWSKtFTyvMKJzTRo3po8gbDMDFYDlrVpJbty48Q98TqO5dv3aRPVD+gTQ6gs1QCpmZrRv16wTz9/9XKMgLXEVTB9XiAksDBLjpK/E6t4XBEQPTUICsORFUJKG4zsiueeJgACXCAj1GguzJi7lBVR1QqRkaG/n/lwCSHfs2ME2v6j36RrJ9evXp+MzGs3Ro2XdDBVDgoCffvrJYB4wrVMXXRlr+a5hMD4iC2KGzeSvPTPGF/JcwRABIwOmyQRgHYAqub4EnnRQj3AY4T0eh861EE+/MZC9hXQAhhyFhrmp4cKIzsXExLDNOqBlFfsktP3mm29c8RmNJiEhoU5lVdUluqCMAvKWHiLx9PR8plE6dmjbBydIMVwY0UrPgB6R/K1g7ux1PE/QEvAWh0W4f6JCAIEajPGuQwBOjkb6TVa+NQ7pE88E070UBlQd1jfX7Qy1PU2bNqXYZpsFaH0lwYlQeVpamhk+I8nNW7eK6YJ+DhBekJ6ertOoGBIbW7aAga6x2DM0nZXclYymX4ikJK7kr0b86QzBZKJXhA6YxF5CvU+uL4CrCYgZNI1DiJR+Y0Bfk+i9lAP62A+FGjWePxySbty0iW0WgA15AI5ua/FerZSVlbmLh9ReIAjAkllpQN0g5YTeXQazcWQkaf9uoei6OGnqFQtxwSn8QSQLXZrICPFBAtCtyfWH4JCnS0AUEhAGcRhKRFrG9BIMhXXS12V7fB9OjhzaGM4BQunamDFj2GaCqg9egg9g6JdlNe7ev3+WLup7Acndu3ehUaNnMzAdt7LpyMapixcmAhMYETEQwyMuOBlSkYgQnwTu0cGYOCUCBAnSvn/3EVhhpsH8lM28xLY4ewfOOEsgoPc4JrlV0w7PJYDOk256gQeQ3Lt//2JQUFBtvFdXrly5MkE8KEigrXhQvx4QjVJl2A+nyTRJksCLAoY0XCYiBKfRsZzZ/bH3hynAdT3Av3sYJETM5+UzWmorzCb9FEnBEQY9q2G9JooN+itFdN7a2hpu377N9goC1Epy6dKlN/HeZ2X16tUWlQ8elNNNArzYkog8oG1YhIQGenfGMHCO5qmur2ppS61ERH/M4uT+gzj+o3QSIGkA5oBI/2m8irwkh9YVdsLcpI3oAW+Ah0Mg1KllohCgr3Q+NDSUbSWoauDkASQPHz68+d577zXAew3LxcuX+cMbPaAOBZJ9+/ZJBCgGSPutbDpgQqMQwLEae5li3Kub7oRGVyMxCdKwJo0Cw3pFM3giw79HBPTrGgyhvokY/6WQk7oNwnwmc8Hl2sGPq8DnVYKkpaWlbKtweQGetiRXr16djfc9X+hjAVZT/Ctv4f6CAJw5QoMGDRQCaGtmUo/HZjIwEOv7VMz84yOzsMfi+FO4NIRRSKjDQlIigdYABuLQSQTQqCBdC+fcETZgCowOTsdRI4xzTHtbZ6VtfaXz9erVo+qObRXghZLgUH9+7dq15njvi+Xrkyd9xEuEFwhxdXXVIaBrWw8sXuIwPkdwBUjjf27GZsz4a2HyqAIkYjT07RKoU9ZKqt0nIqgcNpRESYlgIqCZ1YtXiQMCAmQrJdup54Xrk5w5cyYA7/ttUlFR8TY9JEJAkJCbmysZgdrMqhXGMoLHHooeNovHbQI+D4e83IwtsHzRAcjNfB8mIRH8RRjBaAHqewQdk+qSIE2K6PxIsDC35HZ1gKsIKCnhzxsKeLElQe/dhPf8dlm5cqUZhsIpepi8QCRC+h7n4CB9taGMTDNCcv8xI+ZIn8Vmb+APoTkZW2FJ7h5Ymr8fSlaWYXVYgmN5oArcswT49YhV9kmlL8dSCezexXABJAqyunXrUnyzjQI8KQlWfefXrVtXj3D9R3Lo2LEuCJgX28gDxAuPHDmiGEOfsOhTFhmcNH4J5KZtgXkzN6AXbOCvRcvyPoXVRcchO3W7lCu4R9XAtTrQJR5L3RjcF70uztMHU2mJXt3rCgl43seHo5ZFEEBSXV39y+HDh10Iz38lWDH5P3r0iLtfJEUSsWRew7gGTosDMIajOPFlYgW3IHUzfyWmym9x9h5eFS6YuwdrgFg5DLTgRC/Tvp/LaNR45Zq4j0aY1jadFAL0lc6vWLmC7VL3PNl79uzZEMLxu+T8+fPSghuKyAXILLTvIFVllhZNeIHTxykWp7uZ2Nvyl2EkYmn+Z1C85DjkYVUX6DWOfxGmJUDtDVgf8NR6DO5LISBIoBCwqtf0GQKE+5uamsLlK/xxSwFPQj/4IvtfiuDLYsQPpgUJez/aywaQtrN1hCFuE2CETwFMiloMhTkY/3n7YVnBZ1CU+wnkpG/mP1J4qKa3WpBCabYn5hQSCQSe6oLnFUB0zsvLi+0RQlP7y5cvvzzwQs6cOxcgcgI6GjcWGxvLRtCXXHf7ABiKJIR4zoD0qRuhuPAL9IBPeGk8O2UjzMAcwcOaCqAuEeqttE8Los7tXrwUVlhYyLaQYLj+fP7ixVCy9w+RY8eOOeF8m39MRUKFR7Nm9HteDVjVb8qhMLxPAoT7zIKctA9gEZaytEBKy2Up8s/kpJ/HyEDl+H+WBElp/G/3iiO/3xD4OnXqkKuzLVVVVWdPnDjRi+z8Q2XBggUWWCes4VZRNmzYIPUQaruWjhDkMQlC+ydBVEAKTmmlH0fR4gZNcYO8aDYovgWg8u8DxL68VTyAVoNjwcbqVRUBWiLonL+/P9tw586djWiHJZ7738k5DAkcY0+TAcHBwWwQDY8e3YIg1Gs6JzxaJqPiSCyJ0d9qaK4gVX4EOpInT9rhUe0JVAvQEpj0cxkBXK1JSUlnMfEFskF/htA/tR4+ejQTR4ofWrZsyYZSxqbk5YPGUwk8eVQeg6dlrglR83lFiGeMoveFyqCFJ9D8361TgPJ5nra8KCuBL8f9VDz/1/gDJfZCQ3d396m4exYVQ6EbBPSUyl//XqOkVSH0BEqE9G8yH8wDEgmkBFzsS+BJKf672PXSAY96Do+TUK1R/5JCKy2+NWvUfMeti/8V+tcYAYwalATZyaVcHA3rO0ZaN0AiaKFzgOz2vPaPwyDFPVWXQ3uPA9sm7YiAH7DH12N4+eP+3+ff5Y3QPXs7+PV0dxw23a1DwJYx4eknUqeX/Bjim/ikv4OcCOXYp48kSMqTft1Cb2Du+NrDIWhrnx4hSTaWrd3wVRbSG1+2aDT/BtnUHzfcnqz7AAAAAElFTkSuQmCC"
    hICON := Base64PNG_to_HICON( b64QuickIcon_64x64 ) ; Create a HICON for Tray

    Menu, Tray, Icon, HICON:*%hICON% ; AHK makes a copy of HICON when * is used
    Menu, Tray, Icon
    DllCall( "DestroyIcon", "Ptr",hICON ) ; Destroy original HICON
    menu, tray, add,
    Menu, tray, add, Update ObsidianHTML to Master Branch ,updateObsidianHTMLToMaster
    Menu, tray, add, Update ObsidianHTML to Last Release ,updateObsidianHTMLToLastRelease
    return
}

#Include, <PrettyTickCount>
#Include, <CodeTimer>
#Include, <st_count>
#Include, <HasVal>
#Include, <Base64PNG_to_HICON>
#Include, <script>
#Include, <enableGuiDrag>
#Include, <Quote>
#Include, <ttip>
#Include, <OK_TF>
#Include, <DynamicArguments>
#Include, <SRC_ImageConverter>
#Include, <ObsidianHTML>
#Include, <writeFile>
#Include, <RScript>
#Include, <RegexMatchAll>
#Include, <Deref>
#Include, <OnError>
#Include, <OnExit>
#Include, <Log>
