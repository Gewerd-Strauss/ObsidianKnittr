/*
script() - class for common script management.
This is based on the example script-class written by RaptorX (https://github.com/RaptorX/ScriptObj),
since that project does not have a license attached to it.
*/
class script {
    static DBG_NONE     := 0
        ,DBG_ERRORS   := 1
        ,DBG_WARNINGS := 2
        ,DBG_VERBOSE  := 3

    static name       := ""
        ,version      := ""
        ,author       := ""
        ,authorID	  := ""
        ,authorlink   := ""
        ,email        := ""
        ,credits      := ""
        ,creditslink  := ""
        ,crtdate      := ""
        ,moddate      := ""
        ,homepagetext := ""
        ,homepagelink := ""
        ,ghtext 	  := ""
        ,ghlink       := ""
        ,doctext	  := ""
        ,doclink	  := ""
        ,forumtext	  := ""
        ,forumlink	  := ""
        ,donateLink   := ""
        ,resfolder    := ""
        ,iconfile     := ""
        ,vfile_local  := ""
        ,vfile_remote := ""
        ,config       := ""
        ,configfile   := ""
        ,configfolder := ""
        ,icon         := ""
        ,systemID     := ""
        ,dbgFile      := ""
        ,rfile		  := ""
        ,vfile		  := ""
        ,dbgLevel     := this.DBG_NONE
        ,versionScObj := "0.21.3"
        ,versionAHK   := "1.1"
    About() {
        /**
        Function: About
        Shows a quick HTML Window based on the object's variable information

        Parameters:
        scriptName   (opt) - Name of the script which will be
        shown as the title of the window and the main header
        version      (opt) - Script Version in SimVer format, a "v"
        will be added automatically to this value
        author       (opt) - Name of the author of the script
        credits 	 (opt) - Name of credited people
        ghlink 		 (opt) - GitHubLink
        ghtext 		 (opt) - GitHubtext
        doclink 	 (opt) - DocumentationLink
        doctext 	 (opt) - Documentationtext
        forumlink    (opt) - forumlink
        forumtext    (opt) - forumtext
        homepagetext (opt) - Display text for the script website
        homepagelink (opt) - Href link to that points to the scripts
        website (for pretty links and utm campaing codes)
        donateLink   (opt) - Link to a donation site
        email        (opt) - Developer email

        Notes:
        - Intended to be used after calling the methods .loadCredits() and .loadMeta()
        - these output a raw file-string to this.credits and this.meta respectively
        but do not format it.
        - Values from this.<Field> take precedence over values created by this.credits
        if they already exist when this method is called.
        The function will try to infer the paramters if they are blank by checking
        the class variables if provided. This allows you to set all information once
        when instatiating the class, and the about GUI will be filled out automatically.

        */
        static doc, aboutClose, Butt
        /*

        html =
        (
        <!DOCTYPE html>
        <html lang="en" dir="ltr">
        <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <style media="screen">
        .top {
        text-align:center;
        }
        .top h2 {
        color:#2274A5;
        margin-bottom: 5px;
        }
        .donate {
        color:#E83F6F;
        text-align:center;
        font-weight:bold;
        font-size:small;
        margin: 20px;
        }
        p {
        margin: 0px;
        }
        </style>
        </head>
        <body>
        <div class="top">
        <h2>scriptName</h2>
        <p>vversion</p>
        <hr>
        <p>by author</p>

        )
        */
        if this.HasKey("metadata") {
            Lines:=strsplit(this.metadata,"`n")
            MetadataArray:={}
            for _, Line in Lines {
                Key:=Trim(strsplit(Line, " - ",,2).1)
                    , Value:=Trim(strsplit(Line," - ",,2).2)
                if RegexMatch(Value,"http(s)?:\/\/") {
                    Value:=RegexReplace(Value,"http(s)?:\/\/")
                }
                MetadataArray[Key]:=RegexReplace(Value,"\r")
            }
            ;; what an abomination
            MetadataArray.Scriptname:=(MetadataArray.Scriptname!=""
                ? MetadataArray.Scriptname :( regexreplace(A_ScriptName, "\.\w+")))
            MetadataArray.version:=(MetadataArray.version!=""
                ? MetadataArray.version :( this.version))
            MetadataArray.author :=(MetadataArray.author!=""
                ? MetadataArray.author :( author ? author : this.author))
            MetadataArray.credits :=(MetadataArray.credits!=""
                ? MetadataArray.credits :( credits ? credits : this.credits))
            MetadataArray.ghtext :=(MetadataArray.ghtext!=""
                ? MetadataArray.ghtext :( ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")))
            MetadataArray.ghlink :=(MetadataArray.ghlink!=""
                ? MetadataArray.ghlink :( ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")))
            MetadataArray.doctext :=(MetadataArray.doctext!=""
                ? MetadataArray.doctext :( doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")))
            MetadataArray.doclink :=(MetadataArray.doclink!=""
                ? MetadataArray.doclink :( doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")))
            MetadataArray.offdoclink :=(MetadataArray.offdoclink!=""
                ? MetadataArray.offdoclink :( offdoclink ? offdoclink : this.offdoclink))
            MetadataArray.forumtext :=(MetadataArray.forumtext!=""
                ? MetadataArray.forumtext :( forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")))
            MetadataArray.forumlink :=(MetadataArray.forumlink!=""
                ? MetadataArray.forumlink :( forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")))
            MetadataArray.homepagetext :=(MetadataArray.homepagetext!=""
                ? MetadataArray.homepagetext :( homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")))
            MetadataArray.homepagelink :=(MetadataArray.homepagelink!=""
                ? MetadataArray.homepagelink :( homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")))
            MetadataArray.donateLink :=(MetadataArray.donateLink!=""
                ? MetadataArray.donateLink :( donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")))
            MetadataArray.email :=(MetadataArray.email!=""
                ? MetadataArray.email :( email ? email : this.email))
            ;for Key, Value in MetaDataArray {
            ;    html:=strreplace(html, Key, Trim(Value))
            ;    Value=%Value%
            ;    %key%:=Value ;; please forgive me, for this is a sin. but need them for testing rn
            ;
            ;}
            Key:=Value:=""
            ;m(html)
            ;;#todo: mirror the html template below to an external file, and insert a <creditshere>-thingie to ingest the credits-loop content itself.

        } else {
            scriptName := scriptName ? scriptName : this.name
                , version := version ? version : this.version
                , author := author ? author : this.author
                , credits := credits ? credits : this.credits
                , creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
                , ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
                , ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
                , doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
                , doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
                , offdoclink := offdoclink ? offdoclink : this.offdoclink
                , forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
                , forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
                , homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
                , homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
                , donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
                , email := email ? email : this.email
        }
        About_template:=""

        gui aboutScript:new, +HWNDscriptAbout +alwaysontop +toolwindow, % "About " this.name
        gui margin, 2
        gui color, white
        gui add, activex, w600 r29 vdoc, htmlFile
        hasKey:=this.HasKey("AboutPath")
        FE:=FileExist(this.AboutPath)
        if (this.HasKey("AboutPath") && !FileExist(this.AboutPath)) || !this.HasKey("AboutPath") {

            if (MetadataArray.creditslink and MetadataArray.credits) || IsObject(MetadataArray.credits) || RegexMatch(MetadataArray.credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
            {
                credits:=MetadataArray.credits
                if RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
                {
                    CreditsLines:=strsplit(credits,"`n")
                    Credits:={}
                    for _,v in CreditsLines
                    {
                        if ((InStr(v,"author1") && InStr(v,"snippetName1") && InStr(v,"URL1")) || (InStr(v,"snippetName2|snippetName3")) || (InStr(v,"author2,author3") && Instr(v, "URL2,URL3")))
                            continue
                        val:=strsplit(strreplace(v,"`t"," ")," - ")
                            , Credits[Trim(val.2)]:=Trim(val.1) "|" Trim((strlen(val.3)>5?val.3:""))
                    }
                }
                ; Clipboard:=html
                if IsObject(credits)
                {
                    if (credits.Count()>0)
                    {
                        CreditsAssembly:="credits for used code:<br>`n"
                        for Author,v in credits
                        {
                            if (Author="")
                                continue
                            if (strsplit(v,"|").2="")
                                CreditsAssembly.="<p>" Author " - " strsplit(v,"|").1 "`n`n"
                            else
                            {
                                Name:=strsplit(v,"|").1
                                    , Credit_URL:=strsplit(v,"|").2
                                if Instr(Author,",") && Instr(Credit_URL,",")
                                {
                                    tmpAuthors:=""
                                        , AllCurrentAuthors:=strsplit(Author,",")
                                    for s,w in strsplit(Credit_URL,",")
                                    {
                                        currentAuthor:=AllCurrentAuthors[s]
                                            , tmpAuthors.="<a href=" """" w """" ">" trim(currentAuthor) "</a>"
                                        if (s!=AllCurrentAuthors.MaxIndex())
                                            tmpAuthors.=", "
                                    }
                                    ;CreditsAssembly.=Name " - <p>" tmpAuthors "</p>"  "`n" ;; figure out how to force this to be on one line, instead of the mess it is right now.
                                    CreditsAssembly.="<p>" Name " - " tmpAuthors "</p>" "`n" ;; figure out how to force this to be on one line, instead of the mess it is right now.
                                }
                                else
                                    CreditsAssembly.="<p><a href=" """" Credit_URL """" ">" Author " - " Name "</a></p>`n"
                            }
                        }
                        ; Clipboard:=html
                    }
                }
                else
                {
                    CreditsAssembly=
                    (
                                <p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
                                <hr>
                    )
                }
                MetadataArray.CreditsAssembly:=CreditsAssembly
                ; Clipboard:=html
            }

            if !FileExist(A_ScriptDir "\res\script_templates\_template.html") {
                SplitPath % A_LineFile,, LibPath ;; then in directory of the class `script` itself
                LibPath.="\script_templates\"
                if !FileExist(LibPath "\_template.html") {
                    LibPath .= "\res\script_templates\"

                } else {
                }
            } else {
                LibPath :=A_ScriptDir "\res\script_templates\"
            }
            for metadata_type, metadata_element in MetaDataArray {
                if (metadata_element="") {
                    continue
                }
                ;; search for html formatting files,
                ;; first in ScriptDir
                metadata_element:=Trim(metadata_element)
                ;#Include, % A_LineFile "\script_templates\test.ahk"

                ; if (MetadataArray.some_other_property) {
                ;     FileRead html, % "some_other_property.html"
                ;     html := script_FormatEx(html, MetadataArray)
                ;     template := StrReplace(template, "<!-- $some_other_property -->", html)
                ; }

                ; ; Or a donation link:
                ; if (MetadataArray.donate) {
                ;     FileRead html, % "p-donate.html"
                ;     html := script_FormatEx(html, MetadataArray)
                ;     template := StrReplace(template, "<!-- $donate -->", html)
                ; }
                if (About_template="") {

                    LibPath:=strreplace(LibPath,"\\","\")
                        , About_template_path:=LibPath (InStr(LibPath,"\_template.html")?"":"\_template.html")
                        , About_template_path:=Strreplace(About_template_path,"\\","\")
                    FileRead About_template, % About_template_path
                }
                ;MetadataArray := {ghLink: "anonymous1184/some-repo", ghText: "Some Repo (from anonymous1184)", donate: "https://example.com"}

                ; Have a full HTML About_template, in it you can have HTML comments
                ;  where other smalls parts will be inserted if the exist.

                ; Say a link-back to GitHub:
                ; metadata_type
                ; metadata_element

                if !FileExist(A_ScriptDir "\res\script_templates\" metadata_type ".html") {
                    SplitPath % A_LineFile,, About_type_path ;; then in directory of the class `script` itself
                    About_type_path.="\script_templates\"

                    if !FileExist(strreplace(About_type_path "\_template.html","\\","\")) {
                        About_type_path .= "\res\script_templates\"

                    } else {
                    }
                } else {
                    About_type_path :=A_ScriptDir "\res\script_templates\" metadata_type ".html"
                }
                About_type_path:=strreplace(About_type_path,"\\","\")

                if FileExist(About_type_path) {

                    FileRead html, % About_type_path
                    ;html := script_FormatEx(html, MetadataArray)
                    ;m(About_template)
                    About_template := StrReplace(About_template, "<!-- $" metadata_type " -->", html)
                    ;m(About_template)

                }
            }
            if (IsDebug()) {
                clipboard:=About_template
            }
            About_template := script_FormatEx(About_template, MetadataArray)
            if (IsDebug()) {
                clipboard:=About_template
            }
            AHKVARIABLES:={"A_ScriptDir":A_ScriptDir,"A_ScriptName":A_ScriptName,"A_ScriptFullPath":A_ScriptFullPath,"A_ScriptHwnd":A_ScriptHwnd,"A_LineNumber":A_LineNumber,"A_LineFile":A_LineFile,"A_ThisFunc":A_ThisFunc,"A_ThisLabel":A_ThisLabel,"A_AhkVersion":A_AhkVersion,"A_AhkPath":A_AhkPath,"A_IsUnicode":A_IsUnicode,"A_IsCompiled":A_IsCompiled,"A_ExitReason":A_ExitReason,"A_YYY":A_YYY,"A_MM":A_MM,"A_DD":A_DD,"A_MMMM":A_MMMM,"A_MMM":A_MMM} ;"A_DDDD","A_DDD","A_WDay","A_YDay","A_YWeek","A_Hour","A_Min","A_Sec","A_MSec","A_Now","A_NowUTC","A_TickCount","A_IsSuspended","A_IsPaused","A_IsCritical","A_BatchLines","A_ListLines","A_TitleMatchMode","A_TitleMatchModeSpeed","A_DetectHiddenWindows","A_DetectHiddenText","A_AutoTrim","A_StringCaseSense","A_FileEncoding","A_FormatInteger","A_FormatFloat","A_SendMode","A_SendLevel","A_StoreCapsLockMode","A_KeyDelay","A_KeyDuration","A_KeyDelayPlay","A_KeyDurationPlay","A_WinDelay","A_ControlDelay","A_MouseDelay","A_MouseDelayPlay","A_DefaultMouseSpeed","A_CoordModeToolTip","A_CoordModePixel","A_CoordModeMouse","A_CoordModeCaret","A_CoordModeMenu","A_RegView","A_IconHidden","A_IconTip","A_IconFile","A_IconNumber","A_TimeIdle","A_TimeIdlePhysical","A_TimeIdleKeyboard","A_TimeIdleMouse","A_DefaultGUI","A_DefaultListView","A_DefaultTreeView","A_Gui","A_GuiControl","A_GuiWidth","A_GuiHeight","A_GuiX","A_GuiY","A_GuiEvent","A_GuiControlEvent","A_EventInfo","A_ThisMenuItem","A_ThisMenu","A_ThisMenuItemPos","A_ThisHotkey","A_PriorHotkey","A_PriorKey","A_TimeSinceThisHotkey","A_TimeSincePriorHotkey","A_EndChar","A_ComSpec","A_Temp","A_OSType","A_OSVersion","A_Is64bitOS","A_PtrSize","A_Language","A_ComputerName","A_UserName","A_WinDir","A_ProgramFiles","A_AppData","A_AppDataCommon","A_Desktop","A_DesktopCommon"]
                , About_template := script_FormatEx(About_template,AHKVARIABLES)
            if (IsDebug()) {
                clipboard:=About_template
            }
            ;clipboard:=About_template

            fo:=FileOpen(this.AboutPath, 0x1, "UTF-8-RAW").Write(About_template)
            fo.close()
        } else if (this.HasKey("AboutPath")) {
            FileRead About_template, % this.AboutPath
        }

        doc.write(About_template)

        ;clipboard:=About_template
        children := doc.body.children
            , maxBottom := 0
        Loop % children.length {
            rect := children[A_Index - 1].getBoundingClientRect()
            (rect.bottom > maxBottom && maxBottom := rect.bottom)
        }

        maxBottom *= 96/A_ScreenDPI
        maxBottom += 15 ; some value you want for the padding-bottom
        maxBottomClose:=maxBottom+9
        maxBottom:=maxBottom+35
        GuiControl Move, doc, h%maxBottom%
        gui add, button, w75 x300 y%maxBottomClose% hidden hwndAboutCloseButton gcloseAboutScript, % "&Close"
        Hotkey IfWinActive, % "ahk_id " scriptAbout
        Hotkey Escape, closeAboutScript
        hotkey if
        gui Show,
        WinGetPos x,y,w,h, % "Ahk_id" scriptAbout
        ControlGetPos cx,cy,cw,ch,, % "Ahk_id" AboutCloseButton
        SysGet cyborder, 8
        SysGet sizeframe, 33
        SysGet title, 31
        GuiControl move, % AboutCloseButton, % "x" w/2-(cw/2+sizeframe)
        Return

        closeAboutScript:
        gui aboutScript:destroy
        return
    }

    setIcon(Param:=true) {

        /*
        Function: SetIcon
        TO BE DONE: Sets iconfile as tray-icon if applicable

        Parameters:
        Option - Option to execute
        Set 'true' to set this.res "\" this.iconfile as icon
        Set 'false' to hide tray-icon
        Set '-1' to set icon back to ahk's default icon
        Set 'pathToIconFile' to specify an icon from a specific path
        Set 'dll,iconNumber' to use the icon extracted from the given dll - NOT IMPLEMENTED YET.

        Examples:
        script.SetIcon(0) 									;; hides icon
        ttip("custom from script.iconfile",5)
        script.SetIcon(1)										;; custom from script.iconfile
        ttip("reset ahk's default",5)
        script.SetIcon(-1)									;; ahk's default icon
        ttip("set from path",5)
        script.SetIcon(PathToSpecificIcon)					;; sets icon specified by path as icon

        */
        if (!Instr(Param,":/")) { ;; assume not a path because not a valid drive letter
            script_TraySetup(Param)
        }
        else if (Param=true)
        { ;; set script.iconfile as icon, shows icon
            Menu Tray, Icon,% this.resfolder "\" this.iconfile ;; this does not work for unknown reasons
            menu tray, Icon
            ; menu, tray, icon, hide
            ;; menu, taskbar, icon, % this.resfolder "/" this.iconfilea
        }
        else if (Param=false)
        { ;; set icon to default ahk icon, shows icon

            ; ttip_ScriptObj("Figure out how to hide autohotkey's icon mid-run")
            menu tray, NoIcon
        }
        else if (Param=-1)
        { ;; hide icon
            Menu Tray, Icon, *

        }
        else ;; Param=path to custom icon, not set up as script.iconfile
        { ;; set "Param" as path to iconfile
            ;; check out GetWindowIcon & SetWindowIcon in AHK_Library
            if !FileExist(Param)
            {
                try
                    throw exception("Invalid Icon-Path '" Param "'. Check the path provided.","script.SetIcon()","T")
                Catch, e
                    msgbox 8240,% this.Name " > scriptObj - Invalid ressource-path", % e.Message "`n`nPlease provide a valid path to an existing file. Resuming normal operation."
            }

            Menu Tray, Icon,% Param
            menu tray, Icon
        }
        return
    }
    loadCredits(Path:="\credits.txt") {
        /*
        Function: readCredits
        helper-function to read a credits-file in supported format into the class

        Parameters:
        Path -  Path to the credits-file.
        If the path begins with "\", it will be relative to the script-directory (aka, it will be processed as %A_ScriptDir%\%Path%)
        */
        if (SubStr(Path,1,1)="\") {
            Path:=A_ScriptDir . Path
        }
        FileRead text, % Path
        this.credits:=text
    }
    loadMetadata(Path:="\credits.txt") {
        /*
        Function: readCredits
        helper-function to read a credits-file in supported format into the class

        Parameters:
        Path -  Path to the credits-file.
        If the path begins with "\", it will be relative to the script-directory (aka, it will be processed as %A_ScriptDir%\%Path%)
        */
        if (SubStr(Path,1,1)="\") {
            Path:=A_ScriptDir . Path
        }
        FileRead text, % Path
        this.metadata:=text
    }

    __Init() {

    }
    requiresInternet(URL:="https://autohotkey.com/boards/",Overwrite:=false) { 	;-- Returns true if there is an available internet connection
        if ((this.reqInternet) || Overwrite) {
            return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
        }
        else { ;; we don't care about internet connectivity, so we always return true
            return TRUE

        }
    }
    Load(INI_File:="", bSilentReturn:=0)
    {
        if (INI_File="")
            INI_File:=this.configfile
        Result := []
            , OrigWorkDir:=A_WorkingDir
        if (d_fWriteINI_st_count(INI_File,".ini")>0)
        {
            INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ;; reduce number of ".ini"-patterns to 1
            if (d_fWriteINI_st_count(INI_File,".ini")>0)
                INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ;		 and remove the last instance
        }
        if !FileExist(INI_File ".ini") ;; create new INI_File if not existing
        {
            if !bSilentReturn
                msgbox 8240,% this.Name " > scriptObj -  No Save File found", % "No save file was found.`nPlease reinitialise settings if possible."
            return false
        }
        SplitPath INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
        if !Instr(d:=FileExist(INI_File_Dir),"D:")
            FileCreateDir % INI_File_Dir
        if !FileExist(INI_File_File ".ini") ;; check for ini-file file ending
            FileAppend,, % INI_File ".ini"
        SetWorkingDir INI-Files
        IniRead SectionNames, % INI_File ".ini"
        for _, Section in StrSplit(SectionNames, "`n") {
            IniRead OutputVar_Section, % INI_File ".ini", %Section%
            for __, Haystack in StrSplit(OutputVar_Section, "`n")
            {
                If (Instr(Haystack,"="))
                {
                    RegExMatch(Haystack, "(.*?)=(.*)", $)
                        , Result[Section, $1] := $2
                }
                else
                    Result[Section, Result[Section].MaxIndex()+1]:=Haystack
            }
        }
        if A_WorkingDir!=OrigWorkDir
            SetWorkingDir %OrigWorkDir%
        this.config:=Result
        return (this.config.Count()?true:-1) ; returns true if this.config contains values. returns -1 otherwhise to distinguish between a missing config file and an empty config file
    }
    Save(INI_File:="")
    {
        if (INI_File="")
            INI_File:=this.configfile
        SplitPath INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
        if (d_fWriteINI_st_count(INI_File,".ini")>0)
        {
            INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
            if (d_fWriteINI_st_count(INI_File,".ini")>0)
                INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
        }
        if !Instr(d:=FileExist(INI_File_Dir),"D:")
            FileCreateDir % INI_File_Dir
        if !FileExist(INI_File_File ".ini") ; check for ini-file file ending
            FileAppend,, % INI_File ".ini"
        for SectionName, Entry in this.config
        {
            Pairs := ""
            for Key, Value in Entry
            {
                WriteInd++
                if !Instr(Pairs,Key "=" Value "`n")
                    Pairs .= Key "=" Value "`n"
            }
            IniWrite %Pairs%, % INI_File ".ini", %SectionName%
        }
    }
}

; --uID:3703205295
script_FormatEx(FormatStr, Values*) {
    replacements := []
    clone := Values.Clone()
    for i, part in clone
        IsObject(part) ? clone[i] := "" : Values[i] := {}
    FormatStr := Format(FormatStr, clone*)
    index := 0
    replacements := []
    for _, part in Values {
        for search, replace in part {
            replacements.Push(replace)
                , FormatStr := StrReplace(FormatStr, "{" search "}", "{"++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}

script_TraySetup(IconString) {
    hICON := script_Base64PNG_to_HICON( IconString ) ; Create a HICON for Tray
    menu tray, nostandard
    Menu Tray, Icon, HICON:*%hICON% ; AHK makes a copy of HICON when * is used
    Menu Tray, Icon
    f:=Func("setupdefaultconfig")
    Menu Tray, Add, Restore default config, % f
    f2:=Func("script_reload")
    menu tray, Add, Reload, % f2
    DllCall( "DestroyIcon", "Ptr",hICON ) ; Destroy original HICON
    return
}
script_reload() {
    reload
}

; #region:script_Base64PNG_to_HICON (2942823315)
; #region:Metadata:
; Snippet: script_Base64PNG_to_HICON;  (v.1.0)
; --------------------------------------------------------------
; Author: SKAN
; License: Custom public domain/conditionless right of use for any purpose
; LicenseURL: https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/
; Source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36636
; (03.09.2017)
; --------------------------------------------------------------
; Library: Libs
; Section: 23 - Other
; Dependencies: Windows VISTA and above
; AHK_Version: 1.0
; --------------------------------------------------------------
; Keywords: Icon Base64
; #endregion:Metadata

; #region:Description:
; Parameters Width and Height are optional. Either omit them (to load icon in original dimensions) or specify both of them.
; PNG decompression for Icons was introduced in WIN Vista
; ICONs needn't be SQUARE
; Passing fIcon parameter as false to CreateIconFromResourceEx() function, should create a hCursor (not tested)
; Thanks to @Helgef and @just me me in ask-for-help topic: Anybody using Menu, Tray, Icon, HICON:%hIcon% ?
; Thanks to @jeeswg for providing the formula to calculate Base64 data size.
; Related:
;     Base64 encoder/decoder for Binary data - https://autohotkey.com/boards/viewtopic.php?t=35964
;     Base64ToComByteArray() :: Include image in script and display it with WIA 2.0 - https://autohotkey.com/boards/viewtopic.php?t=36124
;
;
; #endregion:Description

; #region:Example
; #NoEnv
; #SingleInstance, Force
;
; Base64PNG := "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAflBMVEXOgwD///+AUQDz5NSTXQD"
; . "j3NSliWe7dwCnagDGtaPnx6Pbp2eGVQDt1rz6+PXRjSTJgADCewCycQCeZADkwJbhuIf58ur06t/qzrDesHirb"
; . "QDw3ci0nILYn1TVlj+KYSSiZwCYYQCOWgDVyby+q5acfFSTbz/u4dTc08jNv7D3Mcn0AAACq0lEQVR42uzaXW/"
; . "aMBSA4WMn4JAQyAff0A5o123//w/OkSallUblSDm4qO9759zYfo4vI0RERERERERERERERERERERERB97Kva5L"
; . "3lX6deroljKXVoWxcpvWCbv2vkP++JJdFvud8nCfFZSrlQP8bwqE/NZiyTfa82hOJqgNrkotd6YoI6FKFSa4LY"
; . "qM1huTXCljN7aGIX9dSbgW8vYJWZIopAZUgIAAADEBHCuigvwy9VRAawvbQ91NICJP8A8zZoqIkDXPIsG8K+Li"
; . "wngu1ZRAXxtXADbxgawTVwAGx0gBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgI8BDBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAD6AFOFHgrAKgQAAAAAAAAAADwegBuphwX4ln+KAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA1AY5mQAsNgIUZ0O/RAQozoJkGQ"
; . "G4GNB0dQNbhE/hjNQBkF/4CT3Z8AFmutkGbv/y0OgDyvNuYgLavP6wGQGdQ5GVy+xCTyezU3V4LoDNY50lyG3/"
; . "yMpt2t1cB6EunvtOsr1u/2RuJQm9T36zv1S/7m+sD2CGJQva/AQDAnQAudkBzUWhuB3SRsXN2QJkolNkBORm9J"
; . "nwCZ1HpHP4CG1GoOlyDNm9rUao+Bw3heqhEqcplbXr7EGmaNbWoVjdZmt7GT9vMVaKf8zVZn/PVcsdq58v6Ds5"
; . "XCRERERER/W0PDgkAAAAABP1/bfQEAAAAAAAL2VmKC7LwdTIAAAAASUVORK5CYII="
;
; Gui, Add, Picture,, % "HICON:" script_Base64PNG_to_HICON(Base64PNG)
; Gui, Show,, script_Base64PNG_to_HICON() DEMO
; Return
;
; ; Copy and paste script_Base64PNG_to_HICON() below
;
; #endregion:Example

; #region:Code
script_Base64PNG_to_HICON(Base64PNG, W:=0, H:=0) {     ;   By SKAN on D094/D357 @ tiny.cc/t-36636
    Local BLen:=StrLen(Base64PNG), Bin:=0,     nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)
    Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1
        ,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)
        ? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt"
        ,0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0
}

; #endregion:Code

; #region:License
; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/'
;
; #endregion:LicenseWarning: Dependency 'Windows VISTA and above' may not be included. In that case, please search for it separately, or refer to the documentation.

; #endregion:script_Base64PNG_to_HICON (2942823315)

d_fWriteINI_st_removeDuplicates(string, delim="`n")
{ ; remove all but the first instance of 'delim' in 'string'
    ; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
    /*
    RemoveDuplicates
    Remove any and all consecutive lines. A "line" can be determined by
    the delimiter parameter. Not necessarily just a `r or `n. But perhaps
    you want a | as your "line".

    string = The text or symbols you want to search for and remove.
    delim  = The string which defines a "line".

    example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
    output:  aaa|bbb|ccc|ddd
    */
    delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
    Return RegExReplace(string, "(" delim ")+", "$1")
}
d_fWriteINI_st_count(string, searchFor="`n")
{ ; count number of occurences of 'searchFor' in 'string'
    ; copy of the normal function to avoid conflicts.
    ; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
    /*
    Count
    Counts the number of times a tolken exists in the specified string.

    string    = The string which contains the content you want to count.
    searchFor = What you want to search for and count.

    note: If you're counting lines, you may need to add 1 to the results.

    example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
    output:  4
    */
    StringReplace string, string, %searchFor%, %searchFor%, UseErrorLevel
    return ErrorLevel
}
