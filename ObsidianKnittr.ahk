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
                    ,version      : FileOpen(A_ScriptDir "\version.ini","r").Read()
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

md_path:=main()
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
    OnExit("fRemoveTempDir")
    ; 0
    if !script.load()
    {
        InitialSettings=
        (LTrim
        [Config]
searchroot=
obsidianhtml_configfile=
Destination=0
RScriptPath=C:\Program Files\R\R-4.2.0\bin\Rscript.exe
version=1.3.0
)
        script.load()
    }
    ;, script.Update()  ;DO NOT ACTIVATE THISLINE UNTIL YOU DUMBO HAS FIXED THE DAMN METHOD. God damn it.
    ;Conf:=ini(script.config)

    ; 2.2
    out:=guiShow()
    output_type:=out.1
    if (output_type="Both")
        output_type:=["word_document","html_document"]
    manuscriptpath:=out.2

    ; 3. 
    obsidianhtml_configfile:=script.config.config.obsidianhtml_configfile
    manuscriptpath_q:=quote(manuscriptpath)
    SplitPath, % manuscriptpath, OutFileName, manuscriptLocation
    ; cmd =
    ; (Join&
    ; obsidianhtml run -f "%manuscriptpath%" -i "%obsidianhtml_configfile%"
    ; ) ;; figure out how to use these.
    cmd =
    (Join%A_Space%
    obsidianhtml run 
    -f "%manuscriptpath%" 
    -i "%obsidianhtml_configfile%"
    ) ; -i "%obsidianhtml_configfile%" ;; not doable if you use 
    ;-i "%obsidianhtml_configfile%" 
    ; -v
    ; cmd:=Quote(cmd)
    Clipboard:=input:=cmd
    RunWait, % A_ComSpec " /K " input, , , CMD_PID

    ; 4
    ttip("Please copy the path of the md-output, then close the window")
    WinWaitClose, % "ahk_pid " CMD_PID
    md_Path:=Clipboard

    ; 5, 6
    rmd_Path:=ConvertMDToRMD(md_Path,"index")

    ; 7
    rmd_Path:=CopyBack(rmd_Path,script.config.Destination,manuscriptpath)
    script_contents:=BuildRScriptContent(rmd_Path,output_type)
    RunRScript(rmd_Path,output_type,script_contents,script.config.config.RScriptPath)

    return md_Path
}

RunRScript(Path,output_type,script_contents,RScript_Path:="")
{
    SplitPath, % Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    FileDelete, % OutDir "\build.R"
    FileAppend, % script_contents, % OutDir "\build.R"
    if (RScript_Path="")
        run, % "C:\Program Files\R\R-4.2.0\bin\Rscript.exe" A_Space OutDir "\build.R", % OutDir
    else
        run, % RScript_Path A_Space OutDir "\build.R", % OutDir
}

BuildRScriptContent(Path,output_type)
{
    ; Str:="setwd(""C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa"")`n"
    Path2:=strreplace(Path,"\","\\")
    Str=
    (LTRIM
    getwd()
    #setwd("%Path2%")
    getwd()

    )
    if IsObject(output_type)
    {
        for k,format in output_type
        {
            Str2=
            (LTRIM
            
            rmarkdown::render(`"index.rmd`",`"%format%`")`n
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
CopyBack(Source,Destination,manuscriptpath)
{
    SplitPath, Source, OutFileName, Dir, 
    SplitPath, % manuscriptpath ,  , ,,manuscriptname, 
    if Destination
    {
        if FileExist(Destination "\" manuscriptname "\") ;; make sure the output is clean
            FileRemoveDir, % Destination "\" manuscriptname "\", true
        FileCopyDir, % Dir, % Output_Path:=Destination "\" manuscriptname "\", true
        run, % "Explorer " Destination "\" manuscriptname "\"
    }
    else
    {
        if FileExist(A_Desktop "\TempTemporal\" manuscriptname "\") ;; make sure the output is clean
            FileRemoveDir, % A_Desktop "\TempTemporal\" manuscriptname "\", true
        FileCopyDir, % Dir, % Output_Path:= A_Desktop "\TempTemporal\" manuscriptname "\" , true
        run, % "Explorer " A_Desktop "\TempTemporal\" manuscriptname "\"
    }
    return Output_Path  OutFileName
}
ConvertMDToRMD(md_Path,notename)
{
    ;C:\Users\Claudius Main\AppData\Local\Temp\obshtml_97ghbf1f\md
    FileCopy, % md_Path "\" notename ".md", % md_Path "\" notename ".rmd",true
    ;run, % md_Path
    return md_Path "\" notename ".rmd"
}
guiCreate()
{
    global
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
    gui, add, ddl, vDDLval, Both||html_document|word_document|
    Gui, add, button, gChooseFile, Choose Manuscript
    Gui, Font, s7 cWhite, Verdana
    gui, add, button, gguiSubmit, Submit
    Gui, Add, Text,x25,% " Version: " script.version " Author: " script.author
    return
}
guiShow()
{
    global
    while (manuscriptpath="")
    {
        guiCreate()
        gui, show,, % script.name " - Choose manuscript"
        WinWaitClose, % script.name " - Choose manuscript"
    }
    return [DDLval,manuscriptpath]
}
guiEscape()
{
    gui, destroy
    return
}
guiSubmit()
{
    global
    gui, submit
    gui, destroy
    return [DDLval,manuscriptpath]  
}

ChooseFile()
{
    global
    ttip(Clipboard)
    
    if CF_bool:=FileExist(Clipboard)
        manuscriptpath:=(CF_bool?Clipboard:script.config.searchroot)
    else
    {
        FileSelectFile, manuscriptpath, 3, % (FileExist(Clipboard)?Clipboard:script.config.config.searchroot)  , % "Choose manuscript file", *.md
    }
        return manuscriptpath
}

fRemoveTempDir()
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


; --uID:4291014243
 ; Metadata:
  ; Snippet: Ini.ahk  ;  (v.2022.07.01.1)
  ; --------------------------------------------------------------
  ; Author: anonymous1184
  ; Source: https://gist.github.com/anonymous1184/737749e83ade98c84cf619aabf66b063
  ; 
  ; --------------------------------------------------------------
  ; Library: Personal Library
  ; Section: 23 - Other
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: config handling

 ;; Description:
  ;; Desc

 ;;; Example:
  ;;; https://gist.github.com/anonymous1184/737749e83ade98c84cf619aabf66b063
  ;;; https://www.reddit.com/r/AutoHotkey/comments/s1it4j/automagically_readwrite_configuration_files/

 
 ; Version: 2022.11.08.1
 ; Usages and examples: https://redd.it/s1it4j
 
 Ini(Path, Sync:=true) {
     return new Ini_File(Path, Sync)
 }
 
 ; Version: 2022.11.08.1
 
 class Object_Proxy {
 
     ;region Public
 
     Clone() {
         clone := new Object_Proxy()
         clone.__data := this.__data.Clone()
         return clone
     }
 
     Count() {
         return this.__data.Count()
     }
 
     Delete(Parameters*) {
         return this.__data.Delete(Parameters*)
     }
 
     GetAddress(Key) {
         return this.__data.GetAddress(Key)
     }
 
     GetCapacity(Parameters*) {
         return this.__data.GetCapacity(Parameters*)
     }
 
     HasKey(Key) {
         return this.__data.HasKey(Key)
     }
 
     Insert(Parameters*) {
         throw Exception("Deprecated.", -1, A_ThisFunc)
     }
 
     InsertAt(Parameters*) {
         this.__data.InsertAt(Parameters*)
     }
 
     Length() {
         return this.__data.Length()
     }
 
     MaxIndex() {
         return this.__data.MaxIndex()
     }
 
     MinIndex() {
         return this.__data.MinIndex()
     }
 
     Pop() {
         return this.__data.Pop()
     }
 
     Push(Parameters*) {
         return this.__data.Push(Parameters*)
     }
 
     Remove(Parameters*) {
         throw Exception("Deprecated.", -1, A_ThisFunc)
     }
 
     RemoveAt(Parameters*) {
         return this.__data.RemoveAt(Parameters*)
     }
 
     SetCapacity(Parameters*) {
         return this.__data.SetCapacity(Parameters*)
     }
     ;endregion
 
     ;region Private
 
     _NewEnum() {
         return this.__data._NewEnum()
     }
     ;endregion
 
     ;region Meta
 
     __Get(Parameters*) ; Key[, Key...]
     {
         return this.__data[Parameters*]
     }
 
     __Init() {
         ObjRawSet(this, "__data", {})
     }
 
     __Set(Parameters*) ; Key, Value[, Value...]
     {
         value := Parameters.Pop()
         this.__data[Parameters*] := value
         return value
     }
     ;endregion
 
 }
 
 
 class Ini_File extends Object_Proxy {
 
     ;region Public
 
     Persist() {
         IniRead buffer, % this.__path
         sections := {}
         for _,name in StrSplit(buffer, "`n")
             sections[name] := true
         for name in this.__data {
             this[name].Persist()
             sections.Delete(name)
         }
         for name in sections
             IniDelete % this.__path, % name
     }
 
     Sync(Set:="") {
         if (Set = "")
             return this.__sync
         for name in this
             this[name].Sync(Set)
         return this.__sync := !!Set
     }
     ;endregion
 
     ;region Overload
 
     Delete(Name) {
         if (this.__sync)
             IniDelete % this.__path, % Name
     }
     ;endregion
 
     ;region Meta
 
     __New(Path, Sync) {
         ObjRawSet(this, "__path", Path)
         ObjRawSet(this, "__sync", false)
         IniRead buffer, % Path
         for _,name in StrSplit(buffer, "`n") {
             IniRead data, % Path, % name
             this[name] := new Ini_Section(Path, name, data)
         }
         this.Sync(Sync)
     }
 
     __Set(Key, Value) {
         isObj := IsObject(Value)
         base := isObj ? ObjGetBase(Value) : false
         if (isObj && !base)
         || (base && base.__Class != "Ini_Section") {
             path := this.__path
             sync := this.__sync
             this[Key] := new Ini_Section(path, Key, Value, sync)
             return obj ; Stop, hammer time!
         }
     }
     ;endregion
 
 }
 
 class Ini_Section extends Object_Proxy {
 
     ;region Public
 
     Persist() {
         IniRead buffer, % this.__path, % this.__name
         keys := {}
         for _,key in StrSplit(buffer, "`n") {
             key := StrSplit(key, "=")[1]
             keys[key] := true
         }
         for key,value in this {
             keys.Delete(key)
             value := StrLen(value) ? " " value : ""
             IniWrite % value, % this.__path, % this.__name, % key
         }
         for key in keys
             IniDelete % this.__path, % this.__name, % key
     }
 
     Sync(Set:="") {
         if (Set = "")
             return this.__sync
         return this.__sync := !!Set
     }
     ;endregion
 
     ;region Overload
 
     Delete(Key) {
         if (this.__sync)
             IniDelete % this.__path, % this.__name, % key
     }
     ;endregion
 
     ;region Meta
 
     __New(Path, Name, Data, Sync:=false) {
         ObjRawSet(this, "__path", Path)
         ObjRawSet(this, "__name", Name)
         ObjRawSet(this, "__sync", Sync)
         if (!IsObject(Data))
             Ini_ToObject(Data)
         for key,value in Data
             this[key] := value
     }
 
     __Set(Key, Value) {
         if (this.__sync) {
             Value := StrLen(Value) ? " " Value : ""
             IniWrite % Value, % this.__path, % this.__name, % key
         }
     }
     ;endregion
 
 }
 
 ;region Auxiliary
 
 Ini_ToObject(ByRef Data) {
     info := Data, Data := {}
     for _,pair in StrSplit(info, "`n") {
         pair := StrSplit(pair, "=",, 2)
         Data[pair[1]] := pair[2]
     }
 }
 ;endregion
 


; --uID:4291014243

; --uID:4179423054
 ; Metadata:
  ; Snippet: Quote  ;  (v.1)
  ; --------------------------------------------------------------
  ; Author: u/anonymous1184
  ; Source: https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
  ; 
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 05 - String/Array/Text
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: apostrophe

 ;; Description:
  ;; Quotes a string

 ;;; Example:
  ;;; Var:="Hello World"
  ;;; msgbox, % Quote(Var . " Test")
  ;;; 

 Quote(String)
 	{ ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
 		return """" String """"
 	}


; --uID:4179423054