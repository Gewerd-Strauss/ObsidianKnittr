;; main GUI
guiCreate(runCLI,CLIArgs) {
    global
    gui destroy
    if (!FileExist(A_ScriptDir "\INI-Files\DynamicArguments.ini")) {
        setupDefaultDA(A_ScriptDir "\INI-Files\DynamicArguments.ini")
    }
    ret:=getDefinedOutputFormats(A_ScriptDir "\INI-Files\DynamicArguments.ini")
        , PotentialOutputs:=ret[1]
        , filesuffixes:=ret[2]
        , inputsuffixes:=ret[3]
    if (CLIArgs.count()) {
        return [filesuffixes,inputsuffixes]
    }
    Gui Margin, 16, 16
    Gui +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC +hwndOKGui
    Gui Color, 1d1f21, 373b41,
    Gui Font, s11 cWhite, Segoe UI
    gui add, text,xm ym, ObsidianKnittr - automate Obsidian.md conversion
    WideControlWidth:=330
    gui add, listview,% "vvLV1 LV0x8 w" WideControlWidth " h245 checked NoSortHdr " , % "Chooses an output Type"
    gui add, Groupbox, % "xm" " yp" + 248 " w" WideControlWidth " h170", Execution Directories
    for each, File in script.config.DDLHistory {
        if (!FileExist(File)) {
            script.config.DDLHistory.RemoveAt(each,1)
        }
    }
    DDLRows:=(script.config.Config.HistoryLimit>25?25:script.config.Config.HistoryLimit)
    gui add, text, % "yp+25 xp+10 w" WideControlWidth -  3*5, % "Choose execution directory for Quarto/R"
    gui add, Radio,% "vExecutionDirectory Checked",% "&1. OHTML-Output-Dir"
    gui add, Radio,,% "&2. subfolder of note-location in vault"
    ;gui add, DDL,% "yp+20 xp w" WideControlWidth -  4*5 " vExecutionDirectory hwndExeDir r" DDLRows, % ExecutionDirectories
    gui add, Groupbox, % "xm" " yp" + 78 " w" WideControlWidth " h70", Last execution
    SplitPath % script.config.LastRun.manuscriptpath ,, OutDir,, OutNameNoExt
    SplitPath % OutDir,,,, OutDir,
    gui add, text, % "yp+20 xp+5", % "LM: " OutNameNoExt " (" OutDir ")"
    gui add, text, % "yp+20 xp", % "LL: " script.config.LastRun.LastRelativeLevel (script.config.LastRun.LastRelativeLevel=0?" (manuscript-folder)":"") " DL: " script.config.Config.defaultRelativeLevel
    gui add, text, % "ym xm" + WideControlWidth + 5,% " via Obsidian-HTML, RMarkdown and Quarto"
    populateLV(script.config.LastRun.last_output_type,PotentialOutputs)
    HistoryString:=""
    for each, File in script.config.DDLHistory {
        if (!FileExist(File)) {
            script.config.DDLHistory.RemoveAt(each,1)
        }
    }
    for each, File in script.config.DDLHistory {
        if (FileExist(File)) {
            SplitPath % File,, OutDir,, FileName
            SplitPath % OutDir,OutFileName
            HistoryString.=((each=1)?"":"|") FileName "(" OutFileName ")" " -<>- " File
            if (each=1) {
                HistoryString.="|"
            }
        }
    }
    if (!CLIArgs.Count()) { ;; only change config when running in GUI mode
        script.config.LastRun.manuscriptpath:=StrReplace(script.config.LastRun.manuscriptpath, "/","\")
        script.save()
    }
    Gui add, button, gChooseFile, &Choose Manuscript
    DDLRows:=(script.config.Config.HistoryLimit>25?25:script.config.Config.HistoryLimit)
    gui add, DDL,% "w" WideControlWidth " vChosenFile hwndChsnFile r" DDLRows " ggetPotentialWorkDir", % HistoryString
    gui add, Groupbox, % "w" WideControlWidth " h150", Obsidian HTML
    ;; OHTML
    gui add, checkbox,% "xp+10 yp+20" " vbConvertInsteadofRun", % "!!Use verb 'Convert' for OHTML-call?"
    gui add, checkbox,% "xp yp+20" " vbUseOwnOHTMLFork", % "!!!Use the personal fork? *CAUTION*"
    gui add, checkbox,% "xp yp+20" " vbRemoveObsidianHTMLErrors", % "!Purge OHTML-Error-strings?"
    gui add, checkbox,% "xp yp+20" " vbVerboseCheckbox", % "Set OHTML's Verbose-Flag?"
    gui add, checkbox,% "xp yp+20" " vbRestrictOHTMLScope", % "Limit scope of OHTML?"

    ;; post-processing
    gui add, Groupbox, % "xm" +WideControlWidth + 5 " yp" + 55 " w" WideControlWidth " h170", General configuration
    gui add, checkbox, % "xp+10 yp+20" " vbRemoveHashTagFromTags", % "Remove '#' from tags?"
    gui add, checkbox, % "xp yp+20" " vbStripLocalMarkdownLinks", % "Strip local markdown links?"
    gui add, checkbox, % "xp yp+20" " vbKeepFilename", % "Keep Filename?"
    gui add, checkbox, % "xp yp+20" " vbRendertoOutputs", % "Render manuscripts to chosen outputs?"
    gui add, checkbox, % "xp yp+20" " vbBackupOutput", % "Backup Output files before rendering?"

    gui add, Groupbox, % "xm" +WideControlWidth + 5 " yp" + 75 " w" WideControlWidth " h70", Engine-Specific Stuff
    gui add, checkbox, % "xp+10 yp+20" " vbRemoveQuartoReferenceTypesFromCrossrefs", % "Remove ""figure""/""table""/""equation"" from`ninline references in quarto-documents?"
    gui add, text,xp yp+20 w0
    Gui Font, s7 cWhite, Verdana
    gui add, button, gGCSubmit yp+38 xp-10, &Submit
    gui add, button, gGCAutoSubmit yp xp+60, &Full Submit
    onOpenConfig:=Func("EditMainConfig").Bind(script.configfile)
    gui add, button, hwndOpenConfig yp xp+81, Edit General Config
    gui add, button, gGCAbout hwndAbout yp xp+122, &About
    GuiControl +g,%OpenConfig%, % onOpenConfig
    Gui Add, Text,x15 yp,% script.name " v." regexreplace(script.config.version.ObsidianKnittr_Version,"\s*","") " | Obsidian-HTML v." strreplace(script.config.version.ObsidianHTML_Version,"commit:")
    Gui Add, Text,x15 yp+15,% "Quarto-cli" " v." regexreplace(quartogetVersion(),"\s*","") " | Using " (script.config.config.useQuartoCLI?"quarto-cli":"quarto's R-package")
    script.version:=script.config.version.ObsidianKnittr_Version
    if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="") {
        SplitPath % script.config.lastrun.manuscriptpath,, OutDir
        SplitPath % OutDir, OutFileName, OutDir,
        guicontrol,, bVerboseCheckbox, % (script.config.LastRun.Verbose)
        guicontrol,, bRestrictOHTMLScope, % (script.config.LastRun.RestrictOHTMLScope)
        guicontrol,, bKeepFilename, % (script.config.LastRun.KeepFileName)
        guicontrol,, bRendertoOutputs, % (script.config.LastRun.RenderToOutputs)
        guicontrol,, bBackupOutput, % (script.config.LastRun.BackupOutput)
        guicontrol,, bRemoveHashTagFromTags, % (script.config.LastRun.RemoveHashTagFromTags)
        guicontrol,, bConvertInsteadofRun, % (script.config.LastRun.ConvertInsteadofRun)
        guicontrol,, bRemoveObsidianHTMLErrors, % (script.config.LastRun.RemoveObsidianHTMLErrors)
        guicontrol,, bStripLocalMarkdownLinks, % (script.config.LastRun.bStripLocalMarkdownLinks)
        guicontrol,, bUseOwnOHTMLFork, % (script.config.LastRun.UseOwnOHTMLFork)
        guicontrol,, bRemoveQuartoReferenceTypesFromCrossrefs, % (script.config.LastRun.RemoveQuartoReferenceTypesFromCrossrefs)
        guicontrol,, Button2, % (script.config.LastRun.LastExecutionDirectory=1?1:0)
        guicontrol,, Button3, % (script.config.LastRun.LastExecutionDirectory=1?0:1)
    }
    return [filesuffixes,inputsuffixes]
}
guiShow(runCLI:=FALSE,CLIArgs:="") {
    global
    ret:=guiCreate(runCLI,CLIArgs)
        , filesuffixes:=ret[1]
        , inputsuffixes:=ret[2]
        , x:=(script.config.GuiPositioning.X!=""?script.config.GuiPositioning.X:200)
        , y:=(script.config.GuiPositioning.Y!=""?script.config.GuiPositioning.Y:200)
        , bAutoSubmitOTGUI:=false
        , guiWidth:=2*WideControlWidth + 32
        , guiHeight:=595
        , currentMonitor:=MWAGetMonitor()+0
    SysGet MonCount, MonitorCount
    if (MonCount>1) {
        SysGet Mon, Monitor,% currentMonitor
        SysGet MonW,MonitorWorkArea, % currentMonitor
    } else {
        SysGet Mon, Monitor, 1
        SysGet MonW,MonitorWorkArea, 1
    }
    MonWidth:=(MonLeft?MonLeft:MonRight)
    MonWidth:=MonRight-MonLeft
    if SubStr(MonWidth, 1,1)="-" {
        MonWidth:=SubStr(MonWidth,2)
    }
    CoordModeMouse:=A_CoordModeMouse
    CoordMode Mouse,Screen
    MouseGetPos MouseX,MouseY
    CoordMode Mouse, %CoordModeMouse%
    ; guiHeight:=guiHeight+25
    if ((MouseY+guiHeight)>MonWBottom) {
        if ((MouseY-guiHeight)<MonWTop) {
            y:=0
        } Else {
            y:=MonWBottom-guiHeight
        }
    } else {
        y:=MouseY
    }
    if ((MouseX+guiWidth)>MonRight) {
        x:=MonRight-guiWidth
    } Else {
        x:=MouseX
    }
    if (!CLIArgs.count()) {
        gui 1: show,x%x% y%y% w%guiWidth% h%guiHeight%, % script.name " - Choose manuscript"
        enableGuiDrag(1)
        WinWaitClose % script.name " - Choose manuscript"
    } else {
        bAutoSubmitOTGUI:=true
        gui 1: submit
        if (IsObject(CLIArgs.format)) {
            sel:=CLIArgs.format
        } else {
            sel:=[CLIArgs.format]
        }
        /*
        CLI-FLAGS OVERVIEW
        RestrictOHTMLScope                          always true, only the level is set to -1 if - default: true (setting 'false' will do nothing, in that case it is internally set to 'true' and the actual vault-root is selected)
        KeepFileName                                --keepFilename                              - default: true (output formats are generated with the name of the note, instead of e.g. 'index.html'.)
        BackupOutput                                --noBackup                                  - default: true (by default, do backup,e.g. by absence of flag)
        RemoveHashTagFromTags                       --INTER.stripHashesfromTags                 - default: false (in markdown-text, `#tag` & `#tag/nested` will be transformed to `tag` and  tag/nested` respectively)
        ConvertInsteadofRun                         --OHTML.Convert / --OHTML.Run               - default: convert (true) (ObsidianHTML will deprecate the verb `run` in upcoming  v4.0.1.++. At that point, the option will be deprecated out of this program. However, it is already strongly advised not to use `run`, and this program is not extensively checked to work reliably when using `run` instead of `convert`)
        RemoveObsidianHTMLErrors                    --OHTML.TrimErrors                          - default: false
        StripLocalMarkdownLinks                     --INTER.stripLocalMDLinks                   - default: false
        UseOwnOHTMLFork                             --OHTML.UseCustomFork                       - default: false
        RemoveQuartoReferenceTypesFromCrossrefs     --Quarto.TrimRefTypes                       - default: false
        RenderToOutputs                             --noRender                                  - default: false
        SourceNameIndex                             --sourcenameIndex                           - default: true
        */
        bVerboseCheckbox := (CLIArgs.Verbose?1:0)
            , bRestrictOHTMLScope := (CLIArgs.RestrictOHTMLScope?1:0)
            , bKeepFilename := (CLIArgs.KeepFileName?1:0)
            , bBackupOutput := (CLIArgs.BackupOutput?1:0)
            , bRemoveHashTagFromTags := (CLIArgs.StripHashesfromTags?1:0)
            , bConvertInsteadofRun := (CLIArgs.Convert?1:0)
            , bRemoveObsidianHTMLErrors := (CLIArgs.RemoveObsidianHTMLErrors?1:0)
            , bStripLocalMarkdownLinks := (CLIArgs.StriplocalMDLinks?1:0)
            , bUseOwnOHTMLFork := (CLIArgs.UseCustomFork?1:0)
            , bRemoveQuartoReferenceTypesFromCrossrefs := (CLIArgs.RemoveQuartoReferenceTypesFromCrossrefs?1:0)
            , bRendertoOutputs := (CLIArgs.RenderToOutputs?1:0)
    }
    Outputformats:={}
    for _, format in sel {
        ot:=new ot(format,A_ScriptDir "\INI-Files\DynamicArguments.ini","-<>-")
        if bAutoSubmitOTGUI {
            ot.SkipGUI:=bAutoSubmitOTGUI
        }
        ot.GenerateGUI(x,y,TRUE,"ParamsGUI:",1,1,674,1)
        if (CLIArgs.count()) {
            for param,value in CLIArgs {
                if !InStr(param,format) {
                    continue
                }
                param_:=strreplace(param,format ".") 
                if ot.Arguments.HasKey(param_) {
                    ot.Arguments[param_].Value:=value
                }
            }
        }
        ot.AssembleFormatString()
        Outputformats[format]:=ot
    }
    /*
    BUG: fix the logic between executiondirectory and lastexecutiondirectory (is the mapping flipped? WHY?!?!?)
    in copyback: make the value a bool, and make destination always a path. 
    in copyback: do not hard-ref A_Desktop, but ref the configured output dir.

    overview::

    lastexecutiondirectories= 1 → subfolder of vault
    "                       = 2 → ohtml-output dir (desktop) (defaUlt)


    executiondirectory      = 1 → ohtml-output desktop
    "                       = 2 → subfolder of vault
    */
    if (!CLIArgs.count()) {
        atmp:=getPotentialWorkDir(ChosenFile,ExecutionDirectory)
            , ExecutionDirectory:=(atmp.relativeToNote=1?script.config.config.OHTML_OutputDir:atmp.ExecutionDirectories)
            , script.config.LastRun.LastExecutionDirectory:=atmp.relativeToNote
            , ExecutionDirectory:=ExecutionDirectory . (SubStr(ExecutionDirectory,0)!="\"?"\":"") 
    } else {
        if (CLIArgs.noMove) {
            SplitPath % CLIArgs.path,, OutDir
            atmp:=getPotentialWorkDir(CLIArgs.Path,CLIArgs.LastExecutionDirectory)
                , ExecutionDirectory:=OutDir . (SubStr(OutDir,0)!="\"?"\":"")
        } else {
            /*
            BUG: Why does this get flagged to create ozaan a subfolder of the vault? Which cliarg-flag is set wrong here?
            */

            /*
            path:="D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\Submission\BE28 Internship Report.md"
            if !CliArgs.NoMove
            LastExecutionDirectory = NA  → forced to 1 → "C:\Users\Claudius Main\Desktop\TempTemporal\"
            LastExecutionDirectory = 0   → forced to 1 → "C:\Users\Claudius Main\Desktop\TempTemporal\"
            LastExecutionDirectory = 1   → forced to 1 → "C:\Users\Claudius Main\Desktop\TempTemporal\"
            LastExecutionDirectory = 2   → remains   2 → "D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\Submission\ObsidianKnittr_output\"
            LastExecutionDirectory = 3 + → forced to 1 → "C:\Users\Claudius Main\Desktop\TempTemporal\"
            */
            atmp:=getPotentialWorkDir(CLIArgs.Path,CLIArgs.LastExecutionDirectory)
            ExecutionDirectory:=(atmp.relativeToNote=1?script.config.config.OHTML_OutputDir:atmp.ExecutionDirectories)
                , ExecutionDirectory:=ExecutionDirectory . (SubStr(ExecutionDirectory,0)!="\"?"\":"")
        }
    }
    if (manuscriptpath!="") && !ot.bClosedNoSubmit {
        SplitPath % manuscriptpath,,manuscriptdir,, manuscriptName
        return {"sel":sel
                ,"manuscriptpath":manuscriptpath
                ,"manuscriptdir":manuscriptdir
                ,"manuscriptname":manuscriptName
                ,Settings:{"bVerboseCheckbox":bVerboseCheckbox + 0
                    ,"bKeepFilename":bKeepFilename + 0
                    ,"bBackupOutput":bBackupOutput + 0
                    ,"bRendertoOutputs":bRendertoOutputs + 0
                    ,"bRemoveHashTagFromTags":bRemoveHashTagFromTags + 0
                    ,"bRemoveQuartoReferenceTypesFromCrossrefs":bRemoveQuartoReferenceTypesFromCrossrefs + 0
                    ,"bConvertInsteadofRun":bConvertInsteadofRun + 0
                    ,"bRemoveObsidianHTMLErrors":bRemoveObsidianHTMLErrors + 0
                    ,"bRestrictOHTMLScope":bRestrictOHTMLScope + 0
                    ,"bStripLocalMarkdownLinks":bStripLocalMarkdownLinks + 0
                    ,"ExecutionDirectory":ExecutionDirectory
                    ,"bAutoSubmitOTGUI":bAutoSubmitOTGUI + 0
                    ,"bUseOwnOHTMLFork":bUseOwnOHTMLFork + 0}
                ,"Outputformats":Outputformats
                ,"inputsuffixes":inputsuffixes
                ,"filesuffixes":filesuffixes}
    } Else {
        ttip("Exiting",5)
        sleep 1300
        ExitApp 2
    }
}
guiEscape() {
    gui destroy
    return
}
guiSubmit() {
    global
    gui 1: default
    sel:=getSelectedLVEntries()
    gui submit
    gui destroy
    if Instr(ChosenFile,"-<>-") {
        ChosenFile:=Trim(StrSplit(ChosenFile,"-<>-").2)
    }
    ChosenFile:=strreplace(ChosenFile,"/","\")
        , manuscriptpath:=ChosenFile
    if (script.config.LastRun.manuscriptpath!="") && (manuscriptpath="") {
        manuscriptpath:=script.config.LastRun.manuscriptpath
            , bVerboseCheckbox:=bVerboseCheckbox+0
    }
    if (manuscriptpath="") && (sel.count()=0) {
        if (script.config.LastRun.manuscriptpath!="") && (script.config.LastRun.last_output_type!="") {
            if IsObject(strsplit(script.config.LastRun.last_output_type,", ")) {
                sel:=strsplit(script.config.lastrun.last_output_type,", ")
            } else {
                sel:=script.config.lastrun.last_output_type
            }
            manuscriptpath:=script.config.lastrun.manuscriptpath
                , bVerboseCheckbox:=script.config.LastRun.Verbose+0
        }
    }
    if !FileExist(manuscriptpath) {
        manuscriptpath:=chooseFile()
    }
    if (!CLIArgs.Count()) { ;; only change config when running in GUI mode
        script.config.LastRun.path_lastmanuscript:=StrReplace(script.config.LastRun.manuscriptpath, "/","\")
            , script.config.LastRun.manuscriptpath:=StrReplace(manuscriptpath, "/","\")
            , script.config.LastRun.last_output_type:=""
            , script.config.LastRun.Verbose:=bVerboseCheckbox+0
            , script.config.LastRun.RestrictOHTMLScope:=bRestrictOHTMLScope+0
            , script.config.LastRun.KeepFileName:=bKeepFilename+0
            , script.config.LastRun.RenderToOutputs:=bRendertoOutputs+0
            , script.config.LastRun.BackupOutput:=bBackupOutput+0
            , script.config.LastRun.RemoveHashTagFromTags:=bRemoveHashTagFromTags+0
            , script.config.LastRun.ConvertInsteadofRun:=bConvertInsteadofRun+0
            , script.config.LastRun.RemoveObsidianHTMLErrors:=bRemoveObsidianHTMLErrors+0
            , script.config.LastRun.bStripLocalMarkdownLinks:=bStripLocalMarkdownLinks+0
            , script.config.LastRun.UseOwnOHTMLFork:=bUseOwnOHTMLFork+0
            , script.config.LastRun.RemoveQuartoReferenceTypesFromCrossrefs:=bRemoveQuartoReferenceTypesFromCrossrefs+0
            , script.config.DDLHistory:=buildHistory(script.config.DDLHistory,script.config.Config.HistoryLimit,script.config.LastRun.manuscriptpath)
        for each,_output_type in sel {
            script.config.LastRun.last_output_type.=_output_type
            if (each<sel.count()) {
                script.config.LastRun.last_output_type.=", "
            }
        }
        script.save()
    }
    return [DDLval,manuscriptpath,sel]
}
;; wrappers
GCAutoSubmit() {
    global bAutoSubmitOTGUI:=True
    return guiSubmit()
}
GCAbout() {
    script.About()
}
GCEscape() {
    guiEscape()
}
GCSubmit() {
    return guiSubmit()
}
;; helpers
getSelectedLVEntries() {
    vRowNum:=0
        , sel:=[]
    loop {
        vRowNum:=LV_GetNext(vRowNum,"C")
        if not vRowNum {
            break ; The above returned zero, so there are no more selected rows.
        }
        LV_GetText(sCurrText1,vRowNum,1)
            , sel.push(sCurrText1)
    }
    return sel
}
populateLV(last_output,PotentialOutputs) {
    for _,potential_output_type in PotentialOutputs {
        Cond:=Instr(last_output,potential_output_type)
        if Cond {
            Options:="Check"
                , last_output:=strreplace(last_output,potential_output_type)
        } else {
            Options:="-Check"
        }
        if (filesuffixes.HasKey(potential_output_type)) {
            Options.=" cGreen"
        } else {
            Options.=" cRed"
        }
        LV_Add(Options,potential_output_type)
    }
    return
}
