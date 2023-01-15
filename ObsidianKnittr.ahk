#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
#MaxHotkeysPerInterval, 99999999
#Warn All, Outputdebug
;#Persistent 
 ;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
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

main()
ExitApp, 
return

main()
{

    /*
        Steps:
        Obsidian-Sided:
        0. Load Config
        1. Finish manuscript (must contain csl, bib, conforming includes/image formats) * 
        2. Insert `output: word_document|html_document|...` into the frontmatter and save
        2.2 get manuscript's path

        AHK-script sided: 
        3. run obsidianhtml (get manuscript's path) ;; TODO: check if 'max_note_depth' is correctly applied by making a chain of 20 notes including into each other.

        loop, 20
        FileAppend, % "![[" A_Index "]]", % "D:\Dokumente neu\Obsidian NoteTaking\The Universe\000 Start here\MaxInclusionTest\" A_Index ".md"
        4. get output path from cmd-log ;; TODO: automate this step so I don't have to do the complicated clipboard stuff.
        5. rename to .rmd
        6. open r at that location
        7. load BuildRScriptContent ;; TODO: automate properly, instead of using R Studio.
        8. set pwd 
        9. BuildRScriptContent at location
        10. Copy resulting output to predefined output folder
        11. open output folder




        * until https://github.com/obsidian-html/obsidian-html/issues/520 is not fixed

    */
    ; OnExit("fRemoveTempDir").Bind(md_path)
    ; 0
    if !script.load()
    {
        InputBox, given_obsidianhtml_configfile, % script.name " - Initiate settings","Please give the path of your configfile for obsidianhtml."
        InputBox, given_searchroot, % script.name " - Initiate settings","Please give the path of your configfile for obsidianhtml."
        InputBox, given_rscriptpath, % script.name,% "Please give the absolute path of your installed 'Rscript.exe'-file you wish to use.`nIf you don't want to use this step, leave this empty and continue.",  , , , , , , , % "C:\Program Files\R\R-MAJORVERSION.MINORVERSION.PATCH\bin\Rscript.exe"
        InitialSettings=
        (LTrim
        [Config]
        bundleAHKRecompileStarter
        Destination=0
        FullLogOnSuccess=0
        obsidianhtml_configfile=%given_obsidianhtml_configfile%
        RScriptPath=%given_rscriptpath%
        searchroot=%given_searchroot%
        [Version]
        version=1.5.0
        [LastRun]
        FullLog=0
        last_output_type=
        manuscriptpath=
        Verbose=0
        [GuiPositioning]
        H=
        W=
        X=
        Y=
        )
        FileAppend, % InitialSettings, % script.configfile
        script.load()
    }
    script.version:=script.config.Version.Version

    ; 2.2
    out:=guiShow()
    output_type:=out.1
    if (output_type="All") || output_type.HasVal("All")
        output_type:=["html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document"]
    manuscriptpath:=out.2

    ; 3. 
    obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    manuscriptpath_q:=quote(manuscriptpath)
    SplitPath, % manuscriptpath, OutFileName, manuscriptLocation
    bVerboseCheckbox:=out.3
    bFullLogCheckbox:=out.4
    Verbose:=(bVerboseCheckbox?" -v ":" ")
    cmd =
    (Join%A_Space%
    
    obsidianhtml run 
    -f "%manuscriptpath%" 
    -i "%obsidianhtml_configfile%"
    %Verbose%
    ) 
    ttip("Running ObsidianHTML",5)
    ; if (script.config.config.RetrieveFromCMD || true)
        obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
        GeneralInfo:="Execution: " A_Now "| " A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min "`n`n"
    
        ObsidianKnittr_Info:=script.name ":`nVerbose:" bVerboseCheckbox "`nFull Log:" (script.config.config.FullLogOnSuccess || bFullLogCheckbox)

        Result.=ComObjCreate("WScript.Shell").Exec(cmd).StdOut.ReadAll()
        if RegExMatch(Result, "md: (?<MDPath>.*)(\s*)html: (?<HTMLPath>.*)", v)
        {
            ObsidianHTML_Info:="`nObsidianHTML:`nVersion: " ComObjCreate("WScript.Shell").Exec("obsidianhtml version").StdOut.ReadAll()  "`nInput:`n" manuscriptpath "`nOutput Folder:`n" vMDPath "`nConfig:`n" obsidianhtml_configfile "`nCustom Config contents:`n" ReadObsidianHTML_Config(obsidianhtml_configfile).2 "`n---`n"
            if FileExist(vMDPath)
            {
                ObsidianKnittr_Info.= "`nOutput Folder: " GetOutputPath(ConvertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).1 "`nRaw input copy:" GetOutputPath(ConvertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).2 "`n"
                FileDelete, & vMDPath "\Executionlog.txt"
                if (script.config.config.FullLogOnSuccess || bFullLogCheckbox)
                    FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command:`n" Cmd "`n---`n`nCommand Line output below:`n`n" result, % vMDPath "\Executionlog.txt"
                else
                    FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command:`n" Cmd "`n---`n", % vMDPath "\Executionlog.txt"
                md_Path:=vMDPath
            }
            Else
            {
                Clipboard:=result
                FileDelete, % A_ScriptDir "\Executionlog.txt"
                FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command:`n" Cmd "`n---`n`nCommand Line output below:`n`n" result, % A_ScriptDir "\Executionlog.txt"
                run, % A_ScriptDir "\Executionlog.txt"
                MsgBox 0x40010, % script.name, % "File  md_Path does not seem to exist. Please check manually."
            }
        }
        else
        {
            ObsidianKnittr_Info.= "`nOutput Folder: " GetOutputPath(ConvertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).1 "`nRaw input copy:" GetOutputPath(ConvertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).2 "`n"
            ObsidianHTML_Info:="`nObsidianHTML:`nVersion: " ComObjCreate("WScript.Shell").Exec("obsidianhtml version").StdOut.ReadAll() "`nInput:`n" manuscriptpath "`nOutput Folder:`n" vMDPath "`nConfig:`n" obsidianhtml_configfile "`n---`n"
            Clipboard:=result
            FileDelete, % A_ScriptDir "\Executionlog.txt"
            FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command:`n" Cmd "`n---`n`nCommand Line output below:`n`n" result, % A_ScriptDir "\Executionlog.txt"
            run, % A_ScriptDir "\Executionlog.txt"
            MsgBox, 0x40010, % script.name " - Output could not be parsed.", % "DO NOT CONTINUE WITHOUT FULLY READING THIS!`n`nThe command line output of obsidianhtml does not contain the required information.`nThe output has been copied to the clipboard, and written to file under '" A_ScriptDir "\Executionlog.txt" "'`n`nTo carry on, find the path of the md-file and copy it to your clipboard.`nONLY THEN close this window."
        }
    ; 4
    ttip("Converting to .rmd-file",5)
    ; 5, 6
    rmd_Path:=ConvertMDToRMD(md_Path,"index")
    ttip("Moving to output folder",5)
    ; 7

    rmd_Path:=CopyBack(rmd_Path,script.config.Destination,manuscriptpath)
    ttip("Creating R-BuildScript",5)
    script_contents:=BuildRScriptContent(rmd_Path,output_type)
    ttip("Executing R-BuildScript",5)
    RunRScript(rmd_Path,output_type,script_contents,script.config.config.RScriptPath)
    OpenFolder(rmd_Path)
    fRemoveTempDir(md_Path)
    return
}
ReadObsidianHTML_Config(configpath)
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
            conf[Key]:=Value
            confstr.= Key "=" Value "`n"
        }
    }
    if (confstr="")
        return "E03: Config file contains no valid YAML config found in provided file."
    return [conf,confstr]
}
OpenFolder(Path)
{
    SplitPath, % Path,, OutDir
    run, % OutDir
}

BuildRScriptContent(Path,output_type)
{
    ; Str:="setwd(""C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa"")`n"
    SplitPath, % Path, , Path2
    Path2:=strreplace(Path2,"\","\\")
    Str=
    (LTRIM
    getwd()
    setwd("%Path2%")
    getwd()

    )
    if IsObject(output_type)
    {
        bDoPDFLast:=false
        for k,format in output_type
        {
            if (format="pdf_document")
            {
                bDoPDFLast:=true
                continue
            }
            Str2=
            (LTRIM
            
            rmarkdown::render(`"index.rmd`",`"%format%`")`n
            )
            Str.=Str2
        }
        if bDoPDFLast
        {
            Str2=
            (LTrim
            
            rmarkdown::render(`"index.rmd`",`"pdf_document`")`n
            )
            Str.=Str2
        }
    }
    else
    {
        Str2=
        (LTRIM

        rmarkdown::render(`"index.rmd`",`"%output_type%`")`n
        )
        Str.=Str2
    }
    return Str
}

RunRScript(Path,output_type,script_contents,RScript_Path:="")
{
    SplitPath, % Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    FileDelete, % OutDir "\build.R"
    FileAppend, % script_contents, % OutDir "\build.R"
    if (RScript_Path="")
        RScript_Path:="C:\Program Files\R\R-4.2.0\bin\Rscript.exe"
    CMD:=quote(RScript_Path) A_Space quote(strreplace(OutDir "\build.R","\","\\"))
    run, % CMD, % OutDir
    if script.config.config.bundleAHKStarter && (RScript_Path!="")
    {
        RSCRIPT_PATH:=RScript_Path
        BUILD_RPATH:=strreplace(OutDir "\build.R","\","\\")
        OUTDIR_PATH:=OutDir
        Ahk_build=
        (Join`s LTRIM

            `nrun, `% `"`"`"%RSCRIPT_PATH%"""
            A_Space """%BUILD_RPATH%"""
            , `% "%OUTDIR_PATH%"
        )
        if FileExist(OutDir "\AHK_build.ahk")
            FileDelete, % OutDir "\AHK_build.ahk"
        FileAppend, % Ahk_build, % OutDir "\AHK_build.ahk"
    }
    
}

CopyBack(Source,Destination,manuscriptpath)
{
    SplitPath, Source, OutFileName, Dir, 
    SplitPath, % manuscriptpath ,  , ,,manuscriptname, 
    if Destination
    {
        if FileExist(Destination "\" manuscriptname "\") ;; make sure the output is clean
            FileRemoveDir, % Destination "\" manuscriptname "\", true
        FileCopyDir, % Dir, % Output_Path:=Destination "\" manuscriptname "\", true
        FileCopy, % manuscriptpath, % Output_Path "\" manuscriptname "_vault.md", 1
    }
    Else
    {
        if FileExist(A_Desktop "\TempTemporal\" manuscriptname "\") ;; make sure the output is clean
            FileRemoveDir, % A_Desktop "\TempTemporal\" manuscriptname "\", true
        FileCopyDir, % Dir, % Output_Path:= A_Desktop "\TempTemporal\" manuscriptname "\" , true
        FileCopy, % manuscriptpath, % Output_Path "\" manuscriptname "_vault.md ", 1
    }
    return Output_Path  OutFileName
}

GetOutputPath(Source,Destination,manuscriptpath)
{
    SplitPath, Source, OutFileName, Dir, 
    SplitPath, % manuscriptpath ,  , ,,manuscriptname, 
    if Destination
    {
        Output_Path:=Destination "\" manuscriptname "\"
        Raw_InputFile:=Output_Path "\" manuscriptname "_vault.md"
    }
    else
    {
        Output_Path:= A_Desktop "\TempTemporal\" manuscriptname 
        Raw_InputFile:=Output_Path "\" manuscriptname "_vault.md "
    }
    return [Output_Path,Raw_InputFile]
}

ConvertMDToRMD(md_Path,notename)
{
    FileCopy, % md_Path "\" notename ".md", % md_Path "\" notename ".rmd",true
    return md_Path "\" notename ".rmd"
}

fRemoveTempDir(md_Path)
{
    global 
    SplitPath, md_Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    FileRemoveDir, % OutDir,1
    if FileExist(OutDir)
    {
        MsgBox, % "Error occured - Directory '" OutDir "' could not be removed"
        Run, % "explorer " OutDir
    }
    return
}


guiCreate()
{
    global
    gui, destroy
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
    gui, add, text,xm ym, Choose output type:
    gui, add, listview,  vvLV1 cWhite checked, % "Type"
    for k,v in PotentialOutputs
    {
        
        Options:=((Instr(script.config.lastrun.last_output_type,v))?"Check":"-Check")
        LV_Add(Options,v)
    }
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
    guiCreate()
    w:=script.config.GuiPositioning.W
    h:=script.config.GuiPositioning.H
    x:=(script.config.GuiPositioning.X!=""?script.config.GuiPositioning.X:200)
    y:=(script.config.GuiPositioning.Y!=""?script.config.GuiPositioning.Y:200)
    gui,1: show,x%x% y%y%, % script.name " - Choose manuscript"
    enableGuiDrag(1)
    WinWaitClose, % script.name " - Choose manuscript"
    if (manuscriptpath!="")
        return [sel,manuscriptpath,bVerboseCheckbox + 0,bFullLogCheckbox + 0]
    Else
        ExitApp
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
    sel:=f_GetSelectedLVEntries()
    gui, submit
    gui, destroy
    if (script.config.LastRun.manuscriptpath!="") && (manuscriptpath="")
    {
        manuscriptpath:=script.config.LastRun.manuscriptpath
        bVerboseCheckbox:=bVerboseCheckbox+0
        bFullLogCheckbox:=bFullLogCheckbox+0  
    }
    if (manuscriptpath="") && (sel.count()=0)
    {
        if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="")
        {
            if IsObject(strsplit(script.config.LastRun.last_output_type,", "))
                sel:=strsplit(script.config.lastrun.last_output_type,", ")
            else
                sel:=script.config.lastrun.last_output_type
            manuscriptpath:=script.config.lastrun.manuscriptpath
            bVerboseCheckbox:=script.config.LastRun.Verbose+0
            bFullLogCheckbox:=script.config.LastRun.FullLog+0  
        }
    }
    script.config.LastRun.manuscriptpath:=manuscriptpath
    script.config.LastRun.last_output_type:=""
    script.config.LastRun.Verbose:=bVerboseCheckbox+0
    script.config.LastRun.FullLog:=bFullLogCheckbox+0
    for k,v in sel
    {
        
        script.config.LastRun.last_output_type.=v
        if (k<sel.count())
            script.config.LastRun.last_output_type.=", "

    }
    script.save()
    return [DDLval,manuscriptpath,sel]  
}

f_GetSelectedLVEntries()
{
    vRowNum:=0
    sel:=[]
    loop
    {
        vRowNum:=LV_GetNext(vRowNum,"C")
        if not vRowNum  ; The above returned zero, so there are no more selected rows.
            break
        LV_GetText(sCurrText1,vRowNum,1)
        sel.push(sCurrText1)
    }
    return sel
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
#Include, <ScriptObj/ScriptObj>
#Include, <enableGuiDrag>
#Include, <Quote>
#Include, <ttip>


