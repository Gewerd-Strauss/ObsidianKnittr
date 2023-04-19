#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Requires AutoHotkey v1.1.36+ ;; version at which script was written.
#SingleInstance,Force
#MaxHotkeysPerInterval, 99999999
#Warn All, Outputdebug
;#Persistent 
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
                    ,ghlink       : "https://github.com/Gewerd-Strauss/ObsidianScripts"
                    ,doctext	  : ""
                    ,doclink	  : ""
                    ,forumtext	  : ""
                    ,forumlink	  : ""
                    ,donateLink	  : ""
                    ,resfolder    : A_ScriptDir "\res"
                    ,iconfile	  : ""
;					  ,reqInternet: false
					,rfile  	  : "https://github.com/Gewerd-Strauss/OBSIDIANSCRIPTS/archive/refs/heads/main.zip"
					,vfile_raw	  : "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/main/version.ini" 
					,vfile 		  : "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/main/version.ini" 
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
    fTraySetup()
        
    if !script.load()
    {
        InputBox, given_obsidianhtml_configfile, % script.name " - Initiate settings","Please give the path of your configfile for obsidianhtml."
        InputBox, given_searchroot, % script.name " - Initiate settings","Please give the path of your configfile for obsidianhtml."
        InputBox, given_rscriptpath, % script.name,% "Please give the absolute path of your installed 'Rscript.exe'-file you wish to use.`nIf you don't want to use this step, leave this empty and continue.",  , , , , , , , % "C:\Program Files\R\R-MAJORVERSION.MINORVERSION.PATCH\bin\Rscript.exe"
        InitialSettings=
        (LTrim
        [Config]
        bundleAHKRecompileStarter=0
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
    /*
        1 sel
        2 manuscriptpath
        3 Toggles
            .1  Verbose
            .2  FullLog
            .3  SRCConverterVersion
            .4  KeepFilename
            .5  RenderRMD
            .6  RemoveHashTagFromTags
            .7  UseCustomTOC
            .8  bForceFixPNGFiles
            .9  bInsertSetupChunk
            .10 bUseConvertInsteadOfRun
        4 Outputformats
    */
    ; [sel,manuscriptpath,[bVerboseCheckbox + 0,bFullLogCheckbox + 0,bSRCConverterVersion + 0,bKeepFilename + 0,bRenderRMD + 0,bRemoveHashTagFromTags + 0,bUseCustomTOC + 0],Outputformats]

    for each,format in out.4
        if format.HasKey("Error") && (format.Error.ID=0)
        {
            Reload
            ExitApp ;; fucking weird bug. DO NOT remove this exitapp below the reload-command. for some reason, removing it results in the script just ignoring the reload and continuing on as normal under certain situations
        }
    output_type:=out.1
    if (output_type="All") || HasVal(output_type,"All")
        output_type:=["html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document"] ;; todo:: add bookdown format support
    if (HasVal(output_type,"First in YAML"))
        output_type:=""
    manuscriptpath:=out.2
    bVerboseCheckbox:=out.3.1
    bFullLogCheckbox:=out.3.2
    bSRCConverterVersion:=out.3.3
    bKeepFilename:=out.3.4
    bRenderRMD:=out.3.5
    bRemoveHashTagFromTags:=out.3.6
    bUseCustomTOC:=out.3.7
    bForceFixPNGFiles:=out.3.8
    bInsertSetupChunk:=out.3.9
    bConvertInsteadofRun:=out.3.10
    bRemoveObsidianHTMLErrors:=out.3.11
        ; 3. 
    obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    SplitPath, % manuscriptpath, OutFileName, manuscriptLocation,, manuscriptName
    Verbose:=(bVerboseCheckbox?" -v ":" ")
    
    tmpconfig:=createTemporaryObsidianHTML_Config(manuscriptpath, obsidianhtml_configfile,Verbose)
    
    
    ttip("Running ObsidianHTML",5)
    if (obsidianhtml_configfile="")
        obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    GeneralInfo:="Execution ObsidianHTML > " A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec "`n"
    CodeTimer("Timing ComObjTime, Verb: " (bConvertInsteadofRun?"Convert":"Run"))
    ObsidianKnittr_Info:=script.name ":`nVerbose:" bVerboseCheckbox "`nFull Log:" (script.config.config.FullLogOnSuccess || bFullLogCheckbox) "`nUsed Verb:'" ((tmpconfig[1] && bConvertInsteadofRun)?"Convert":"Run") "'`nSRC_Converter: " (bSRCConverterVersion?"V2 Conversion (no universal decoding employed, can output '' to "")":"V4 Conversion (should convert everything cleanly)") "`n" A_Tab "Document Settings`n" 
    if (tmpconfig[1] && bConvertInsteadofRun) {
        ret:=ObsidianHtml(,tmpconfig[1],Verbose)
    } else {
        ret:=ObsidianHtml(manuscriptpath,tmpconfig[1],Verbose)

    }
    t:=CodeTimer("Timing ComObjTime, Verb: " (bConvertInsteadofRun?"Convert":"Run"))
    GeneralInfo.="Execution ObsidianHTML < " A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec 
    d:= ret.obsidianHTML_Version
    e:= ret["obsidianHTML_Version"]
    GeneralInfo.="`n                                      " strreplace(strreplace(strreplace(t[3],"h"),"m"),"s") "`n`n"
    OutputDebug, % "`n`n" GeneralInfo
    if RegExMatch(Ret["stdOut"], "md: (?<MDPath>.*)(\s*)", v)
    {
        script.config.version.ObsidianHTML_Version:=ret.obsidianhtml_Version
        ObsidianHTML_Info:="`nObsidianHTML:`nVersion: " ret.obsidianHTML_Version "`nObsiidanHTML-Path:" ret.obsidianhtml_path "`nInput:`n" manuscriptpath "`nOutput Folder:`n" vMDPath "`nConfig:`n" obsidianhtml_configfile "`nCustom Config contents:`n" readObsidianHTML_Config(obsidianhtml_configfile).2 "`n---`n"
        if FileExist(vMDPath)
        {
            ObsidianKnittr_Info.= "`nOutput Folder: " getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).1 "`nRaw input copy:" getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).2 "`n"
            FileDelete, & vMDPath "\Executionlog.txt"
            if (script.config.config.FullLogOnSuccess || bFullLogCheckbox)
                FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n`nCommand Line output below:`n`n" ret["stdout"], % vMDPath "\Executionlog.txt"
            else
                FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n", % vMDPath "\Executionlog.txt"
            md_Path:=vMDPath
        }
        Else
        {
            FileDelete, % A_ScriptDir "\Executionlog.txt"
            FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n`nCommand Line output below:`n`n" ret["stdout"], % A_ScriptDir "\Executionlog.txt"
            run, % A_ScriptDir "\Executionlog.txt"
            MsgBox 0x40010, % script.name, % "File  md_Path does not seem to exist. Please check manually."
        }
    }
    else
    {
        if RegExMatch(Ret["stdOut"], "Created empty output folder path (?<MDPath>.*)(\s*)", v)
        {
            script.config.version.ObsidianHTML_Version:=ret.obsidianhtml_Version
            ObsidianHTML_Info:="`nObsidianHTML:`nVersion: " ret.obsidianHTML_Version "`nObsiidanHTML-Path:" ret.obsidianhtml_path  "`nInput:`n" manuscriptpath "`nOutput Folder:`n" vMDPath "`nConfig:`n" obsidianhtml_configfile "`nCustom Config contents:`n" readObsidianHTML_Config(obsidianhtml_configfile).2 "`n---`n"
            
            if FileExist(vMDPath)
            {
                ObsidianKnittr_Info.= "`nOutput Folder: " getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).1 "`nRaw input copy:" getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).2 "`n"
                FileDelete, & vMDPath "\Executionlog.txt"
                if (script.config.config.FullLogOnSuccess || bFullLogCheckbox)
                    FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n`nCommand Line output below:`n`n" ret["stdout"], % vMDPath "\Executionlog.txt"
                else
                    FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n", % vMDPath "\Executionlog.txt"
                md_Path:=vMDPath
            }
            Else
            {
                FileDelete, % A_ScriptDir "\Executionlog.txt"
                FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n`nCommand Line output below:`n`n" ret["stdout"], % A_ScriptDir "\Executionlog.txt"
                run, % A_ScriptDir "\Executionlog.txt"
                MsgBox 0x40010, % script.name, % "File  md_Path does not seem to exist. Please check manually."
            }
        }
        else
        {
            script.config.version.ObsidianHTML_Version:=ret.obsidianhtml_Version
            ObsidianKnittr_Info.= "`nOutput Folder: " getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).1 "`nRaw input copy:" getOutputPath(convertMDToRMD(vMDPath,"index"),script.config.Destination,manuscriptpath).2 "`n"
            ObsidianHTML_Info:="`nObsidianHTML:`nVersion: " ret.obsidianHTML_Version "`nObsiidanHTML-Path:" ret.obsidianhtml_path "`nInput:`n" manuscriptpath "`nOutput Folder:`n" vMDPath "`nConfig:`n" obsidianhtml_configfile "`n---`n"
            FileDelete, % A_ScriptDir "\Executionlog.txt"
            FileAppend, % GeneralInfo ObsidianKnittr_Info ObsidianHTML_Info "`n`nIssued Command (Execution time " t[3] "):`n" ret["CMD"] "`n---`n`nCommand Line output below:`n`n" ret["stdout"], % A_ScriptDir "\Executionlog.txt"
            run, % A_ScriptDir "\Executionlog.txt"
            MsgBox, 0x40010, % script.name " - Output could not be parsed.", % "DO NOT CONTINUE WITHOUT FULLY READING THIS!`n`nThe command line output of obsidianhtml does not contain the required information.`nThe output has been copied to the clipboard, and written to file under '" A_ScriptDir "\Executionlog.txt" "'`n`nTo carry on, find the path of the md-file and copy it to your clipboard.`nONLY THEN close this window."
            md_Path:=Clipboard
        }
    }
    ; 4
    
    ttip("Converting to .rmd-file",5)
    rmd_Path:=convertMDToRMD(md_Path,"index",true)
    ; 5, 6
    ttip("Moving to output folder",5)
    rmd_Path:=copyBack(rmd_Path,script.config.Destination,manuscriptpath)
    ; 7
    ttip("Converting Image SRC's")
    Clipboard:=NewContents:=ConvertSRC_SYNTAX_V4(rmd_Path,bDontInsertSetupChunk,bRemoveObsidianHTMLErrors)
    ttip("Processing Tags",5)
    NewContents:=processTags(NewContents,bRemoveHashTagFromTags)
    ttip("Processing Abstract",5)
    NewContents:=processAbstract(NewContents)
    ; NewContents:=ProcessHorizontalBreaks(NewContents)
    FileDelete, % rmd_Path 
    ; Current_FileEncoding:=A_FileEncoding
    ; FileEncoding, UTF-8
    writeFile(rmd_Path,Clipboard:=NewContents,"UTF-8",,true)
    ; FileAppend, % Clipboard:=NewContents,% rmd_Path
    ; FileEncoding, % Current_FileEncoding
    ttip("Creating R-BuildScript",5)
    if bKeepFilename
        tmp:=buildRScriptContent(rmd_Path,output_type,manuscriptName,out)
    else
        tmp:=buildRScriptContent(rmd_Path,output_type,,out)
    script_contents:=tmp.1
    format:=tmp.2
    if (format!="")
    {
        ExecutionLog_Path:=MD_ModTime:=SD_ModTime:=""
        format:=tmp.2
		SplitPath, % rmd_Path,, OutDir
		if FileExist(ExecutionLog_Path:=OutDir "\ExecutionLog.txt")
		{
			FileRead,ExecutionLog, % ExecutionLog_Path
            FileDelete, % ExecutionLog_Path
            ExecutionLog:=OK_TF_Replace(ExecutionLog,"Document Settings","Document Settings`n" A_Tab strreplace(format,"`n","`n" A_Tab A_Tab))
            FileAppend, % ExecutionLog,  %  ExecutionLog_Path
        }
    }
    if bRenderRMD
    {

        FileRead,ExecutionLog, % ExecutionLog_Path
        FileDelete, % ExecutionLog_Path
        t:=CodeTimer("Timing R-Script-Execution")
        ExecutionLog:=OK_TF_Replace(ExecutionLog,"`n`nObsidianKnittr:`n","`nExecution RBuildScript > " A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec "`n`nObsidianKnittr:`n")
        OutputDebug, % "`n`n" ExecutionLog
        ;m(clipboard:=Executionlog)
        
        
        ttip("Executing R-BuildScript",5)
        runRScript(rmd_Path,output_type,script_contents,script.config.config.RScriptPath)
        t:=CodeTimer("Timing R-Script-Execution")
        ExecutionLog:=OK_TF_Replace(ExecutionLog,"`n`nObsidianKnittr:`n","`nExecution RBuildScript < " A_DD "." A_MM "." A_YYYY " - " A_Hour ":" A_Min ":" A_Sec "`n                                      " strreplace(strreplace(strreplace(t[3],"h"),"m"),"s") "`n`nObsidianKnittr:`n")
        OutputDebug, % "`n`n" ExecutionLog
        ;m(clipboard:=Executionlog)
        FileAppend, % ExecutionLog,  %  ExecutionLog_Path
        OutputDebug, % t[3]

    }
    Else
    {
        ttip("Opening RMD-File",5)
        SplitPath, % rmd_Path, OutFileName, OutDir
        FileDelete, % OutDir "\build.R"
        WriteFile(OutDir "\build.R",script_contents,"UTF-8-RAW",,true)
        ; FileAppend, % script_contents, % OutDir "\build.R"
        run, % rmd_Path
    }
    ttip("Building AHK-Starterscript",5)
    BuildAHKScriptContent(rmd_Path,script_contents,script.config.config.RScriptPath)
    OpenFolder(rmd_Path)
    fRemoveTempDir(md_Path)
    script.save()
    return
}


openFolder(Path)
{
    SplitPath, % Path, OutFileName, OutDir
    SplitPath, % OutDir, OutFileName, OutDir2
    if (WinExist(OutFileName " ahk_exe explorer.exe"))
    {
        WinActivate
        return
    }
    if script.config.config.OpenParentfolderInstead
        run, % OutDir2
    Else
        run, % OutDir
    return
}


buildAHKScriptContent(Path,script_contents,RScript_Path:="")
{
    SplitPath, % Path, OutFileName, OutDir
    ;FileDelete, % OutDir "\build.R"
    ;FileAppend, % script_contents, % OutDir "\build.R"
    if (RScript_Path="")
        RScript_Path:="C:\Program Files\R\R-4.2.0\bin\Rscript.exe"
    if script.config.config.bundleAHKStarter && (RScript_Path!="")
    {
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
        if FileExist(OutDir "\build.ahk")
            FileDelete, % OutDir "\build.ahk"
        writeFile(OutDir "\build.ahk",AHK_Build,"UTF-8",,true)
        ; FileAppend, % AHK_Build, % OutDir "\build.ahk"
    }
    return
}
copyBack(Source,Destination,manuscriptpath)
{
    SplitPath, Source, OutFileName, Dir, 
    SplitPath, % manuscriptpath ,  , ,,manuscriptname, 
    if Destination
    {
        if FileExist(Destination "\" manuscriptname "\") ;; make sure the output is clean
            FileRemoveDir, % Destination "\" manuscriptname "\", true
        FileCopyDir, % Dir, % Output_Path:=Destination "\" manuscriptname "\", true
        writeFile(Output_Path "\index.md",Clipboard:=manuscriptcontent,,,true)
        ; FileAppend,% Clipboard:=manuscriptcontent, % Output_Path "\index.md"
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
getOutputPath(Source,Destination,manuscriptpath)
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
convertMDToRMD(md_Path,notename,bConvertSRC:=false)
{
    FileCopy, % md_Path "\" notename ".md", % md_Path "\" notename ".rmd",true
    return md_Path "\" notename ".rmd"
}
removeTempDir(md_Path)
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
processAbstract(Contents)
{
    if (FileExist(Contents))
        FileRead Contents, % Contents
    Lines:=Strsplit(Contents,"`r`n")
    , Rebuild:=""
    for index, Line in Lines
    {
        if (st_count(Rebuild,"`n")>1)
        {
            Rebuild.="`n" Line
            continue
        }
        if (!Instr(Rebuild,"abstract"))
            Rebuild.=((Index=1)?Line:"`n" Line)
        else
            Rebuild.=((SubStr(Line,1,2)="  ")?A_Space LTrim(Line):"`n" Line)
    }
    return Rebuild
}
; processHorizontalBreaks(Contents)
; {
;     Rebuild:=""
;     Clipboard:=Contents
;     Lines:=strsplit(Contents,"`n")
;     YAMLCount:=0
;     for Index,Line in Lines
;     {
;         if (Line="---")
;             YAMLCount++
;         ; Len:=Len+StrLen(Line)
;         if Lines[1]="---" && YAMLCount<2
;         {
;             Rebuild.=Line "`n"
;             continue
;         }
;         Rebuild.=RegExReplace(Line,"^[-]{3,}","`n---`n") "`n"
;     }
;     return Rebuild
; }
processTags(Contents,bRemoveHashTagFromTags)
{
    if (FileExist(Contents))
        FileRead Contents, % Contents
    AlreadyReplaced:=""
    if Instr(Contents,"_obsidian_pattern")
    {
        Tags:=Strsplit(Contents,"tags:").2

        ;; eliminate duplicates
        Lines:=strsplit(Tags,"`r`n")
        Tags:=""
        for ind, Line in Lines
        {
            if SubStr(Line,1,2)="- " && !Instr(Tags,Line)
                Tags.=Line "`r`n"
            if SubStr(Line,1,2)="- "
                OrigTags.=Line "`r`n"
            if SubStr(LIne,1,3)="---"
                break
        }
        if (Tags="")
        {
            Tag:=Trim(Lines[1])
            Needle:="``{_obsidian_pattern_tag_" Tag "}``"
            if bRemoveHashTagFromTags
            {
                Contents:=Strreplace(Contents,Needle,Tag)
                if Instr(Contents,Tag) && !Instr(Contents,Needle)
                    Tags:=""
            }
            else
            {
                Contents:=Strreplace(Contents,Needle,"#" Tag)
                if Instr(Contents,"#" Tag)
                    Tags:=""
            }
            AlreadyReplaced.=Tag "`n"
        }
        else
        {
            Tags:=Trim(Tags)
            Tags:=Strsplit(Tags,"`r`n")
            for ind,Tag in Tags
            {
                if (SubStr(Tag,1,1)="-")
                    Tags[ind]:=SubStr(Tag,3)
                else
                {
                    Cap:=Tags.Remove(Ind)
                    continue
                }
            }

            for ind, Tag in Tags
            {
                loop, Parse, % script.config.Config.obsidianTagEndChars
                {
                    Tags[ind]:=(InStr(Tags[ind],A_LoopField)?StrSplit(Tags[ind],A_LoopField).1:Tags[ind])
                }
            }
            for ind, Tag in Tags
            {
                if (Tag="") && !Instr(AlreadyReplaced,Tag)
                    continue
                Needle:="``{_obsidian_pattern_tag_" Tag "}``"
                if bRemoveHashTagFromTags
                {
                    if !Instr(Contents,Needle)
                        continue
                    Contents:=Strreplace(Contents,Needle,Tag)
                    if Instr(Contents,Tag) && !Instr(Contents,Needle)
                        Tags[Ind]:=""
                }
                else
                {
                    if !Instr(Contents,Needle)
                        continue
                    Contents:=Strreplace(Contents,Needle,"#" Tag)
                    if Instr(Contents,"#" Tag)
                        Tags[Ind]:=""
                }
                AlreadyReplaced.=Tag "`n"
            }
            rebuild:="`r`n"
            for ind, Tag in Tags
            {
                if (Tag="")
                    continue
                rebuild.="- " Tag "`r`n"
            }
            ;rebuild.="---"
            Contents:=strreplace(Contents,OrigTags,rebuild)
            Contents:=StrReplace(Contents,"---`r`n---", "`r`n---`r`n",,1)
            Contents:=StrReplace(Contents,"`r`n`r`n", "`r`n",,1)
        }
    }
    
    return Contents
}
guiCreate()
{
    global
    gui, destroy
    PotentialOutputs:=["First in YAML" , "html_document" , "pdf_document" , "word_document" , "odt_document" , "rtf_document" , "md_document" , "powerpoint_presentation" , "ioslides_presentation" , "tufte::tufte_html" , "github_document" , "All"]
    gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
    Gui, Margin, 16, 16
    Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC +hwndOKGui
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
    WideControlWidth:=330
    gui, add, listview,  vvLV1 cWhite w%WideControlWidth% checked, % "Type"
    for k,v in PotentialOutputs
    {
        Options:=((Instr(script.config.lastrun.last_output_type,v))?"Check":"-Check")
        LV_Add(Options,v)
    }
    HistoryString:=""
    for each, File in script.config.DDLHistory
    {
        SplitPath, % File, , OutDir, , FileName
        SplitPath, % OutDir,OutFilename
        HistoryString.=((each=1)?"":"|") FileName "(" OutFileName ")" " -<>- " File
        if (each=1)
            HistoryString.="|"
    }
    ; gui, add, ddl, vDDLval, All||html_document|word_document|odt_document|rtf_document|md_document|
    Gui, add, button, gChooseFile, &Choose Manuscript
    DDLRows:=script.config.Config.HistoryLimit
    gui, add, DDL, w%widecontrolwidth% vChosenFile hwndChsnFile r%DDLRows%, %  HistoryString
    ; gui, add, edit, w%widecontrolwidth% vChosenFile hwndChsnFile disabled
    gui, add, checkbox, vbVerboseCheckbox, Set OHTML's Verbose-Flag?
    gui, add, checkbox, vbFullLogCheckbox, Full Log on successful execution?
    
    ; gui, add, checkbox, vbSRCConverterVersion, Use V2 conversion?
    gui, add, checkbox, vbKeepFilename, Keep Filename?
    gui, add, checkbox, vbRenderRMD, Render RMD to chosen outputs?
    gui, add, checkbox, vbRemoveHashTagFromTags, % "Remove '#' from tags?"
    gui, add, checkbox, vbForceFixPNGFiles, Double-convert png-files pre-conversion?
    gui, add, checkbox, vbInsertSetupChunk, !Insert Setup-Chunk?
    gui, add, checkbox, vbConvertInsteadofRun, !!Use verb 'Convert' for OHTML-call?
    gui, add, checkbox, vbRemoveObsidianHTMLErrors, !Purge OHTML-Error-strings?
    Gui, Font, s7 cWhite, Verdana
    gui, add, button, gGCSubmit, &Submit
    gui, add, button, gGCAutoSubmit yp xp+60, &Full Submit
    onOpenConfig:=Func("EditMainConfig").Bind(script.configfile)
    gui, add, button,  hwndOpenConfig yp xp+81, Edit General Configuration
    gui, add, button, gGCAbout hwndAbout yp xp+157, &About
    GuiControl, +g,%OpenConfig%, % onOpenConfig
    ;     ; gui, add, button, yp xp+60 hwndEditConfig, Edit Configuration
    ;     ; onEditConfig:=ObjBindMethod(this, "EditConfig")
    Gui, Add, Text,x25,% "v." script.version " | Author: " script.author " | Obsidian-HTML: " script.config.version.ObsidianHTML_Version

    ; script.config.lastrun.last_output_type:=["html_document","word_document"]
    if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="")
    {
        SplitPath, % script.config.lastrun.manuscriptpath, , OutDir, , manuscriptname,
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
    }
    return
}
GCAutoSubmit()
{
    global bAutoSubmitOTGUI:=True
    return guiSubmit()
}

guiShow()
{
    global
    guiCreate()
    w:=script.config.GuiPositioning.W
    h:=script.config.GuiPositioning.H
    x:=(script.config.GuiPositioning.X!=""?script.config.GuiPositioning.X:200)
    y:=(script.config.GuiPositioning.Y!=""?script.config.GuiPositioning.Y:200)
    bAutoSubmitOTGUI:=false
    gui,1: show,x%x% y%y%, % script.name " - Choose manuscript"
    enableGuiDrag(1)
    WinWaitClose, % script.name " - Choose manuscript"
    Outputformats:={}
    for each, format in sel
    {
        ot:=new ot(format,A_ScriptDir "\INI-Files\DynamicArguments.ini","-<>-")
        if bAutoSubmitOTGUI
            ot.SkipGUI:=bAutoSubmitOTGUI
        ot.GenerateGUI(x,y)
        ot.AssembleFormatString()
        Outputformats[format]:=ot
    }
    if IsObject(ot.Errors) && ot.Errors.HasKey(-1)
    {

    }
    if (manuscriptpath!="") && !ot.bClosedNoSubmit
        return [sel,manuscriptpath,[bVerboseCheckbox + 0,bFullLogCheckbox + 0,bSRCConverterVersion + 0,bKeepFilename + 0,bRenderRMD + 0,bRemoveHashTagFromTags + 0,bUseCustomTOC + 0,bForceFixPNGFiles + 0, bInsertSetupChunk + 0, bConvertInsteadofRun + 0, bRemoveObsidianHTMLErrors + 0],Outputformats]
    Else
        ExitApp
}
GCAbout()
{
    script.About()
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
    sel:=getSelectedLVEntries()
    gui, submit
    gui, destroy
    if Instr(ChosenFile,"-<>-")
        ChosenFile:=Trim(StrSplit(chosenFile,"-<>-").2)
    manuscriptpath:=ChosenFile
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
    if !FileExist(manuscriptpath)
        manuscriptpath:=chooseFile()
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
    script.config.DDLHistory:=buildHistory(script.config.DDLHistory,script.config.Config.HistoryLimit,script.config.LastRun.manuscriptpath)
    
    for k,v in sel
    {
        
        script.config.LastRun.last_output_type.=v
        if (k<sel.count())
            script.config.LastRun.last_output_type.=", "

    }
    script.save()
    return [DDLval,manuscriptpath,sel]  
}
buildHistory(History,NumberOfRecords,manuscriptpath:="")
{
    if (manuscriptpath!="")
    {
        if HasVal(History,manuscriptpath)
            History.RemoveAt(HasVal(History,manuscriptpath),1)
        History.InsertAt(1,manuscriptpath)
    }
    if (History.Count()>NumberOfRecords)
        History.Delete(NumberOfRecords+1,History.Count())
    return History
}
getSelectedLVEntries()
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
editMainConfig(configfile)
{
    static
    gui, Submit, NoHide
    RunWait, % configfile,,,PID
    WinWaitClose, % "ahk_PID" PID
    Gui +OwnDialogs
    OnMessage(0x44, "DA_OnMsgBox")
    MsgBox 0x40044, %  this.ClassName " > " A_ThisFunc "()", You modified the configuration for this class.`nReload?
    OnMessage(0x44, "")
    IfMsgBox Yes, {
        reload
    } Else IfMsgBox No, {
    }
}
chooseFile()
{
    global
    if FileExist(r:=strreplace(Clipboard,"/","\"))
        Clipboard:=strreplace(Clipboard,"/","\")
    else if FileExist(r:=strreplace(Clipboard,"/","\"))
        Clipboard:=strreplace(Clipboard,"/","\")
	else
		ttip("Clipboard does not contain a valid path.")
    SplitPath, % Clipboard, , , Ext
    if CF_bool:=FileExist(Clipboard) && (Ext="md") && !GetKeyState("LShift","P")
        manuscriptpath:=(CF_bool?Clipboard:script.config.searchroot)
    else
    {
        if script.config.config.SetSearchRootToLastRunManuscriptFolder
        {
            SplitPath, % script.config.Lastrun.manuscriptpath,, LastRunDir
            FileSelectFile, manuscriptpath, 3, % (FileExist(Clipboard)?Clipboard:LastRunDir)  , % "Choose &manuscript file", *.md
        }
        else
            FileSelectFile, manuscriptpath, 3, % (FileExist(Clipboard)?Clipboard:script.config.config.searchroot)  , % "Choose &manuscript file", *.md
        if (manuscriptpath="")
            return
    }
    SplitPath, % manuscriptpath, , OutDir, , manuscriptname,
    SplitPath, % OutDir, OutFileName,
    
    script.config.DDLHistory:=buildHistory(script.config.DDLHistory,script.config.Config.HistoryLimit,manuscriptpath)
    HistoryString:=""
    for each, File in script.config.DDLHistory
    {
        SplitPath, % File, , OutDir, , FileName
        SplitPath, % OutDir,OutFilename
        HistoryString.=((each=1)?"":"|") FileName "(" OutFileName ")" " -<>- " File
        if (each=1)
            HistoryString.="|"
    }
    GuiControl,, ChosenFile, |
    guicontrol,, ChosenFile, % HistoryString
    return manuscriptpath
}



fTraySetup()
{
    b64QuickIcon_64x64 := "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAABlFSURBVHhe1VsJeE3X9r+JKYMgEkNQKaE1JyQiIUIkkoiIKaMkMojUFEMoQWZBZELEFKqpMTw6PGqq0kGLp2iK0j9qKJGipoRoi/XWWufsc8+9Lv++V31t1/et78xnr99vr7X22vvcq/kTpM727dubV1dXtzl+/Lj9wYMHnY6cOOHw9OnTNjt37mxha2trIt/39xcAqHn27Nkul69eHXP79u1Vd+7c+bSqqupCZVVV5a+PHz95/PgxCKVjvFZVWVn5/d27dz9DXV1eXj7u5MmT9viqWtIb/yZiojFxbdX4tcXvb9t+Bkn4XfLLL79A1YMH3924cWNpWVlZb7mJv57YODqa1Te2jnNu2/+orcXrUF9jDc3MX4XREWPh25PfynAAnjx9Ck+ePFH0sazqc2pVy1PU+/fvn7h69eq4tLS0unLTf7oYY/yOnxA18btGxi1hoEsMeHULhhZmbaCexgpqaEygUe1mMOmNqfD9ue8lJChMhKz4PKsgR02Iel8tDx48OH/t2rVJ2H5NyYw/QTA+PaofVR96WFUNbRu3g45NXSDQawIM6fMGeDoEwStIgqWmETRANdLUgeb1bCFjVhZUlP8ow8BeFeARoNj+v4r3Cbl3795X3377rbds0v9Mal2/fr2AkhfJm2OToLbGAjzsgyAhJgfiQ9PB23EEekIItDBtjQRYg7XGhj3CSFMbWjd6HXLn5MP9e5X8PInWA17sBWKftzIR9GxFRcWywMBAU9m+P06OHDnyGmbzL7hllO/O/B9Y1m4ErzXsBoOx52dPKYaUxGLw7xkNvs6R4NU1GJozCVZgbWTDRNTVWLJH2Ns5QvGS1VBd/Uh+m0yEHlhDStfEdSHoDUf/9a9/dZJNffmC43YfjL2bcnss8WHjGIxbhwCIHjIT5sx8h/WNsAzoZx8Mfi5RMgl2iidI2hRMNfVAgx7h3LEXlK7dzOCFPH36LGD1MalOyMjPon13z5w54yOb/PLk9NmzQ6ofPXpIjVCDJF8f+wYsjC2hlUUHGNAjAhJH50NmUgmkv/kW61D0CK+uoUhCDHgiCepwsDZqyh5hhfsmSAQlS48e/eGDrdv53UKoreeBZwJYpXN0H8mjR49+OX/+fJhs+u+Xc+fODf7555/57dQINs0NjRgUhb1fC5zbeENw/wRIn76GgadNWw1Z6AUTY7IxGYaCT/cImYQQaG5GnoDhgMAJPHkCaUPU2hpzqKUxgwF9A+CjXfu4DSHUriBCC1ybQAUBggTavhQSjh075o6MKj1PSvL5gS/QhS3gFdO24InJbuyIDHZ9Ak9KRGTOKIEgJMYTvUAiIVoiwbSVlgT0BEnJK4iUJkiCOXvFUN8gbOcgtydEABfgmRQ+lmxT24jl9q84Uv334YB1uh2+5Cd6mWCXGiXxdxsMxhi/DrbuMKh3HMxKWAoZ6AGCANLMpHcgMX4h9McRwdspXEUC5gQzCoeGDJ48gLxBIQP3LZGImugN5nhPWEAkfHnwELcrep+2Yl/nWLZTkPDw4cP7mLg7ypB+uzg6OtbCbH+YXiJeSkqy8/3d6K5m0KTWK9CnyzCIDHgT5iBYNXg1CWF+k6GfQwgT4O0UgfkiGofIUCyWRDgILyAyBBHoEcbN8LgZJsqaqBrIL8jn9tXgxb44VhMg7MXRoWzKlCn/2RCJ5eYieli8lJQaobG/Txcv7B1TaN/ECQa4jIQpcXmc/PTBp0wt5vNJ44sYvPAEUiKBwqGFuUSClVETCTQRgGpthODx2MzYAoyMjZiAzp07sx3CLh3wso2kggBWvEaCdcsKCdlvkK++/trtKT5MIl4o2Ny87h8I3oSzeK/2/pz8yPVF8pN0FaROXQXzkjdBwdx/wsKsHRAXmM6FkiBAImGkVCyZt8G5gxwOCLoR9noDI2uoZVwbNMYaMDKSCKDtV199xXYoHaNHgLr3xb6Q02VlnhLCF0tNnIoepwfULyOpflgNzq+7cba2a9CRe3Rs+BzO+AI8AU9DXZC+FQoX7IbF83dC4fxdMHdmKfj1xHkCJkQtCSOQhChOkuQJlvIQWde4HoI1Bo2RBoyNjVkFCTNnzmRbdHpfRYBQYbu4ToITqVMJvr51JJjPkYsXL46lm+khfRZXLXmLix5LTWNwsvOEwe6jYdakZdz7qXKvp01dDXkZ26AwezcsQvBEwOL5H8KCtC0QG5gMHl2EF6jDgYqlEGhs2hxHALnX5Z7XJ6Bjx45KhygE0MAsAxUeYeiY5PLly1MkpAYEp5gmlZWVl+lGNZskWGGBw6vdcXiygOYmraAvJr9RgSmQm74NCZCGPSIgF3t+idzzi7N3wcJ5OyBz5jpIw3uSp6yEgeQF3cIU8EIH9YwD+zZuiqsL0BT/agJIDx3SjggMFG0U+8o5A+dJcFQoLyoqMjyVvnDhwii+C0X/wWX5K7j3KVY72jiDT49IyEraBquLTsDS3IPo7vsgP+sD7PldCnjygHmzN/LcgMJjzsy18EZ4pkECfLuP5JAyrW3OIJWeF0TIStcSExPZJrSO7Xtez6tVjeXSpUsTGLCeGOFw8Q2/mG6m3pcfuHf3HnRoZg9mmvqcrV1f94WY4XNg/aorsG7VRVhTdAaK8j6BRSrwlPzmp5TCfCQgc/rbHCIiUQ52j4f+TAINi1oS/F1HQWubjjoEiN5XE2BnZwdYmbJtAhip8Fj1OX0luV95/zt8j+46AmZXF+HuzJr8IpKF8wrl2G8Ereq1h/5OoZCTshe2rLsKpW+Xw/ri72F5wUHscex1BE+eMD95I4PP5u16Bk+agrPFALdR3NuiLpAIwCIJh8ZenQYpoA2RgKayHjhwgG0TwMheka/UvS72xbGQEydO9GXgQipu3CiiC8pDMhl3bt+F9jb2YIGu35CSX+t+MLzfBOz1MigtIQIqoHRNOZQsO8VekDfnfQS/QQa/SSZiE44C65iA2ZOWw0DXaCSAKsNIJkFsBQmNGzR/1gv0SEhISGD7FAJUEyImAVVg0d4jKcnNW7dWMXCS+Pj4WjhEXKAL6gdI0mZnYIO1eXhqYdIGx/LhED00Gd3/DKxffQEJuA6bSypg41tXoCh3P8b8BrnXJQLE/nw8n5W0FpISirh4ol7XEqBVf5dY6Nq2D4N8kRe0atWKEhrbqAA0QIC+0nkSxPsDJX0m4PDhw/a//vorXxA3klRUVED9BvVxqloHq7Om0KV5T+y5UJgcuxBKik9DyYpTsAFJ2FxyHcPgPORlvo8ErMdex55n0FIIEBH5mVKCnDVpJQKVYl6fADpHyZA8wdyU1goM5wI6T7p79262U7eXZQJwqz0nqdgnIaKOHj3qTPg1V65eHUcn6RI/RAco06ZNU3qiYY3G4NF5GBoYDsmTV0HBvO043O2DNUvL4J3lp2HlwsOQm/Eu9zT3OoaBAJ+NRCycuwNWLPoMZ4gbEKB2cmTICwa5xsFrLRwkArBtBo/DoSBAkDBuHJutBYqgCBipck5W9T3CC8rLyxMJP8V/CZ3gm+WLp06dAjMzM4Xt5tatwa97FE5vJ0B22ias9DZDdmopLJr7ISya9yGC38bHEmhtzyv7OCIsydmLz73PJbC3yAFOssrgvVFpntDHYRjUrFFLal8FXE2Ara0tPFCFgSCAtvrgxTmhJD/++GMpvkejuXP3Lk+6xcMkW7duVcCT1q9rxeN3qO8krPHXIyB0c9aNXPNz4mOVAJMnSN5AJGyCebPWc1GUwwRg5dc9FLx6BIOnrN7dySu0XkBDIpHO7T+HANJdu3axvWS3mgABXiFAbOXrJJgHjmr8/f3N7ldWXlG/hOTatWtgYWHBjYgGndv1h4HYO4nxBZAxg8b2tyALgVHvzkPQuRlbuRKkYS8v813IxxGBwBMpeXhtecEB9JJ3wcslCEEHgrczgkb1cg4FTzrnHIzeIBEwEJOhc3tvmQDJBiNlqyVh9OjRbK+6d/WBi331MQlWvdc16OotMZtW0wk1ASR9+/blRigGaduyyWvg6zQSIgZNxfK2BKe7WNzgTJB6ekHaZqwGpUKIK0Ish4tyP8Ze3wkFOBtchnVCceGXMHXiYujnFAg+jqK3RQhEgqdrIJJB6waRmGsi2VMsLRpx22rgagJatGjBZTqJAKmvjEtOikyAjBGLqceamzdvvo4jAFNCF9iF8GaSWbNmSY3L8/E6tU3Bs1sw+GM9n5SwFOv7NZCMZW4W9vjibJz1IWjK9NIWCcjZBysWfgnFi7+Ct5adhAIkKH5kKpIYyYmQRgPh8kI9XYZjOEjnKQzs7Xq/kADSnTt3sr2GgWu36msktLah+fzzzx1ph0QhAJWEXiwaEQ3ShGUADlWxQckYBiU87c2b8x4ClmZ+Yga4ZMFeHhmKFx+CVUXHYQ0SkJm6HibHF/JHE28cTiUCVCSg+1NeULzAWaoXzEy0oaivdD5ulDSFYdCyCgLUW7Ev8NF9mv379/eiCyQEXk0AZkmoX7++DgHWDWxgABrm3ysG5uLwtjT3I2X2R+BJC0llTyjK+ZgrxOUFn0JGcimkvPkxhPrlM3BvLKkV8IIABC8IoHM0S3ztlW4vJKB58+b0BZlt1u9phQyxVeEjoSJIxwNIiQQhffpqqzLaGhsZQ89OA2CI2wxInbwDlubtUYArHiCDL8BckJ26BeZioizI+idkJm+DNye+B6NHfABhA+ZyjGvrgQiOe88eQeDlpCWAhkSPrkFQq1YdgyTQOVJ1GBBYoQoRiEm6psVHx8/kAKF0kSQlJUWnYdq3bfo6DHWfCmNCKPax92X3Z+CoSxbswcJnu7JGkI6jBa0N5szZA2PjVkFc2LsQPXgpBHrMQALCZAIQsHM4ePQYpkyUhPpjYfSqTXuDBAiboqKi2F6y+hnwpAKbvE/COeD06dO21fLHObqghAHeSELjLDXAKjdmUtsMk2EgDOqVgCC3oBfs5aSXk74NR4e1MD91M68SS+DFUlkxesNWmDBqEQz3y4SowUsgsN9MzAVh3PME3tN1KNYHIXKRpPUM+uTu1plmiTUMkkDnbGxsoKqqim0WoNUE8JZwyUpCH3s0ERER5vjgD8qDejfdunULrKysdBqmfQc7Nx7KooenwbL8fTj/3y6vC67SLo/J4IVmJr0NY0ZkYYxHQIDnePBzjwPP7lJN0Nd5CE6SwmBwzygGLY0EUhjQdqDLKGhqZSvboUsCnSN93mjAuFRb0blYCP2Iz2k0uPOleJCAqxMhibe3VJCoG7Su3wz8nKMwU0dA8pTVWBCt49XhqfH5MDku55mPJKT05Wh0SBp4OoRAf3T9fk7DoV/3QNwGYWKNgKE9o1FHQoCrmC3KocFeYKgw0iUhOjqa7dUHra8CG+I+hs9pNDdu3VhHJ+gBAV4oSVZWlkSAPCOjfUqG5Jbe3cIhelgSu7z0KWw8jA3PwOMSdn/KA2oCRgWlMAEEilzfl7cR2PMjYQjqYJdICOn3BoT7JXLpLQigWSKtFTyvMKJzTRo3po8gbDMDFYDlrVpJbty48Q98TqO5dv3aRPVD+gTQ6gs1QCpmZrRv16wTz9/9XKMgLXEVTB9XiAksDBLjpK/E6t4XBEQPTUICsORFUJKG4zsiueeJgACXCAj1GguzJi7lBVR1QqRkaG/n/lwCSHfs2ME2v6j36RrJ9evXp+MzGs3Ro2XdDBVDgoCffvrJYB4wrVMXXRlr+a5hMD4iC2KGzeSvPTPGF/JcwRABIwOmyQRgHYAqub4EnnRQj3AY4T0eh861EE+/MZC9hXQAhhyFhrmp4cKIzsXExLDNOqBlFfsktP3mm29c8RmNJiEhoU5lVdUluqCMAvKWHiLx9PR8plE6dmjbBydIMVwY0UrPgB6R/K1g7ux1PE/QEvAWh0W4f6JCAIEajPGuQwBOjkb6TVa+NQ7pE88E070UBlQd1jfX7Qy1PU2bNqXYZpsFaH0lwYlQeVpamhk+I8nNW7eK6YJ+DhBekJ6ertOoGBIbW7aAga6x2DM0nZXclYymX4ikJK7kr0b86QzBZKJXhA6YxF5CvU+uL4CrCYgZNI1DiJR+Y0Bfk+i9lAP62A+FGjWePxySbty0iW0WgA15AI5ua/FerZSVlbmLh9ReIAjAkllpQN0g5YTeXQazcWQkaf9uoei6OGnqFQtxwSn8QSQLXZrICPFBAtCtyfWH4JCnS0AUEhAGcRhKRFrG9BIMhXXS12V7fB9OjhzaGM4BQunamDFj2GaCqg9egg9g6JdlNe7ev3+WLup7Acndu3ehUaNnMzAdt7LpyMapixcmAhMYETEQwyMuOBlSkYgQnwTu0cGYOCUCBAnSvn/3EVhhpsH8lM28xLY4ewfOOEsgoPc4JrlV0w7PJYDOk256gQeQ3Lt//2JQUFBtvFdXrly5MkE8KEigrXhQvx4QjVJl2A+nyTRJksCLAoY0XCYiBKfRsZzZ/bH3hynAdT3Av3sYJETM5+UzWmorzCb9FEnBEQY9q2G9JooN+itFdN7a2hpu377N9goC1Epy6dKlN/HeZ2X16tUWlQ8elNNNArzYkog8oG1YhIQGenfGMHCO5qmur2ppS61ERH/M4uT+gzj+o3QSIGkA5oBI/2m8irwkh9YVdsLcpI3oAW+Ah0Mg1KllohCgr3Q+NDSUbSWoauDkASQPHz68+d577zXAew3LxcuX+cMbPaAOBZJ9+/ZJBCgGSPutbDpgQqMQwLEae5li3Kub7oRGVyMxCdKwJo0Cw3pFM3giw79HBPTrGgyhvokY/6WQk7oNwnwmc8Hl2sGPq8DnVYKkpaWlbKtweQGetiRXr16djfc9X+hjAVZT/Ctv4f6CAJw5QoMGDRQCaGtmUo/HZjIwEOv7VMz84yOzsMfi+FO4NIRRSKjDQlIigdYABuLQSQTQqCBdC+fcETZgCowOTsdRI4xzTHtbZ6VtfaXz9erVo+qObRXghZLgUH9+7dq15njvi+Xrkyd9xEuEFwhxdXXVIaBrWw8sXuIwPkdwBUjjf27GZsz4a2HyqAIkYjT07RKoU9ZKqt0nIqgcNpRESYlgIqCZ1YtXiQMCAmQrJdup54Xrk5w5cyYA7/ttUlFR8TY9JEJAkJCbmysZgdrMqhXGMoLHHooeNovHbQI+D4e83IwtsHzRAcjNfB8mIRH8RRjBaAHqewQdk+qSIE2K6PxIsDC35HZ1gKsIKCnhzxsKeLElQe/dhPf8dlm5cqUZhsIpepi8QCRC+h7n4CB9taGMTDNCcv8xI+ZIn8Vmb+APoTkZW2FJ7h5Ymr8fSlaWYXVYgmN5oArcswT49YhV9kmlL8dSCezexXABJAqyunXrUnyzjQI8KQlWfefXrVtXj3D9R3Lo2LEuCJgX28gDxAuPHDmiGEOfsOhTFhmcNH4J5KZtgXkzN6AXbOCvRcvyPoXVRcchO3W7lCu4R9XAtTrQJR5L3RjcF70uztMHU2mJXt3rCgl43seHo5ZFEEBSXV39y+HDh10Iz38lWDH5P3r0iLtfJEUSsWRew7gGTosDMIajOPFlYgW3IHUzfyWmym9x9h5eFS6YuwdrgFg5DLTgRC/Tvp/LaNR45Zq4j0aY1jadFAL0lc6vWLmC7VL3PNl79uzZEMLxu+T8+fPSghuKyAXILLTvIFVllhZNeIHTxykWp7uZ2Nvyl2EkYmn+Z1C85DjkYVUX6DWOfxGmJUDtDVgf8NR6DO5LISBIoBCwqtf0GQKE+5uamsLlK/xxSwFPQj/4IvtfiuDLYsQPpgUJez/aywaQtrN1hCFuE2CETwFMiloMhTkY/3n7YVnBZ1CU+wnkpG/mP1J4qKa3WpBCabYn5hQSCQSe6oLnFUB0zsvLi+0RQlP7y5cvvzzwQs6cOxcgcgI6GjcWGxvLRtCXXHf7ABiKJIR4zoD0qRuhuPAL9IBPeGk8O2UjzMAcwcOaCqAuEeqttE8Los7tXrwUVlhYyLaQYLj+fP7ixVCy9w+RY8eOOeF8m39MRUKFR7Nm9HteDVjVb8qhMLxPAoT7zIKctA9gEZaytEBKy2Up8s/kpJ/HyEDl+H+WBElp/G/3iiO/3xD4OnXqkKuzLVVVVWdPnDjRi+z8Q2XBggUWWCes4VZRNmzYIPUQaruWjhDkMQlC+ydBVEAKTmmlH0fR4gZNcYO8aDYovgWg8u8DxL68VTyAVoNjwcbqVRUBWiLonL+/P9tw586djWiHJZ7738k5DAkcY0+TAcHBwWwQDY8e3YIg1Gs6JzxaJqPiSCyJ0d9qaK4gVX4EOpInT9rhUe0JVAvQEpj0cxkBXK1JSUlnMfEFskF/htA/tR4+ejQTR4ofWrZsyYZSxqbk5YPGUwk8eVQeg6dlrglR83lFiGeMoveFyqCFJ9D8361TgPJ5nra8KCuBL8f9VDz/1/gDJfZCQ3d396m4exYVQ6EbBPSUyl//XqOkVSH0BEqE9G8yH8wDEgmkBFzsS+BJKf672PXSAY96Do+TUK1R/5JCKy2+NWvUfMeti/8V+tcYAYwalATZyaVcHA3rO0ZaN0AiaKFzgOz2vPaPwyDFPVWXQ3uPA9sm7YiAH7DH12N4+eP+3+ff5Y3QPXs7+PV0dxw23a1DwJYx4eknUqeX/Bjim/ikv4OcCOXYp48kSMqTft1Cb2Du+NrDIWhrnx4hSTaWrd3wVRbSG1+2aDT/BtnUHzfcnqz7AAAAAElFTkSuQmCC"
    hICON := Base64PNG_to_HICON( b64QuickIcon_64x64 )  ; Create a HICON for Tray

    Menu, Tray, Icon, HICON:*%hICON%                      ; AHK makes a copy of HICON when * is used
    Menu, Tray, Icon
    DllCall( "DestroyIcon", "Ptr",hICON  )                ; Destroy original HICON
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
#Include, <ScriptObj/ScriptObj>
#Include, <enableGuiDrag>
#Include, <Quote>
#Include, <ttip>
#Include, <OK_TF>
#Include, <DynamicArguments>
#Include, <SRC_ImageConverter>
#Include, <ObsidianHTML>
#Include, <writeFile>
#Include, <RScript>
#Include, <CMDret_RunReturn>
