Class ot {
    __New(Format:="",ConfigFile:="",DDL_ParamDelimiter:="-<>-",SkipGUI:=FALSE,StepsizedGuiShow:=FALSE) {
        this.type:=Format
            , this.ClassName.= Format ")"
            , this.DDL_ParamDelimiter:=DDL_ParamDelimiter
            , this.SkipGUI:=SkipGUI
            , this.StepsizedGuiShow:=StepsizedGuiShow
        if FileExist(ConfigFile) {
            this.ConfigFile:=ConfigFile
        } else {
            ID:=-1
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'") "'" ConfigFile "'" (this.Errors[ID].HasKey("EndString")?this.Errors[ID].EndString:"Fatal: Undefined Error with ID '" ID "'")
            ExitApp -1
            return
        }

        FileRead Text, % ConfigFile
        Lines:=strsplit(Text,Format "`r`n").2
            , Lines:=strsplit(Lines,"`r`n`r`n").1
            , Lines:=strsplit(Lines,"`r`n")
        if !Lines.Count() {
            this.Result:=this.type:=Format "()"
                , ID:=+2
                , this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        for _, Line in Lines {
            Count:=1
                , p := 1
                , regex:="(?<Key>\w+\:)(?<Val>[^|]+)" ;; does not support keys a la 'toc-depth' (as required by quarto)
                , regex:="(?<Key>(\-|\w)+\:)(?<Val>[^|]+)"
            if (SubStr(Trim(Line),1,1)=";") {
                continue
            }
            if (RegexMatch(Line,"^\s+\S+")) {
                while (p := RegExMatch(Line, regex, match, p)) {
                    ; do stuff
                    if !InStr(Line,"|") { ;; not a parameter being defined. This occurs on lines like `bookdown::word_document2` which should define a new output format instead
                        p+=StrLen(Match)
                    } else {
                        matchKey:=SubStr(matchKey,1,StrLen(matchKey)-1) ;; remove the doublepoint.
                        if (Count<2) { ;; initiate Parameter-Object
                            if (InStr(Line,"renderingpackage")) {
                                This[matchKey]:=StrSplit(Line,"Value:").2
                                    , p+=StrLen(Match)
                                    , Count++
                                continue
                            } else {
                                CurrentParam:=matchKey
                                    , ObjRawSet(This.Arguments,matchKey,{})
                                    , ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                            }
                        }
                        if !(InStr(Line,"renderingpackage")) {
                            ObjRawSet(This.Arguments[CurrentParam],matchKey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
                        }
                        p+=StrLen(Match)
                            , Count++
                    }
                }
            } else { ;; we reached the first line of the next output format, indicated by its `package::format`-line
                break
            }
        }
        this.AssumeDefaults()
        this._Adjust()
    }
    __Init() {
        this.Errors:={ ;; negative errors are hard failures, which will not let the program continue. positive errors are positive, and allow limited continuation. Functionality may be limited

                -1:{String:"Provided Configfile does not exist:`n`n",EndString:"`n`n---`nExiting Script",Criticality:-100,ID:-1}
                ,0:{String:"Gui got cancelled",EndString:"`n`n---`nReturning to General Selection",Criticality:0,ID:0}
                ,+2:{String:"Format not defined.`nCheck your configfile.`n`nReturning default 'outputformat()'",Criticality:20,ID:+2}}
            , this.ClassName:="ot ("
            , this.GUITitle:="Define output format - "
            , this.Version:="0.1.a"
            , this.type:=""
            , this.ConfigFile:=""
            , this.bClosedNoSubmit:=false
            , ObjRawSet(this,"type","")
            , ObjRawSet(this,"Arguments",{})
    }
    __Get(Param*) {
        ret:={}
        for _,key in Param {
            ret[key]:=this.Arguments[key].Value
        }
        return ret
    }

    _Adjust() {
        This.AdjustMinMax()
        This.AdjustDDLs()
        This.AdjustBools()
        This.AdjustIntegers()
        This.AdjustNulls()
        return This
    }
    AssembleFormatString() {
        if this.HasKey("renderingpackage_start") {
            if !this.HasKey("renderingpackage_end") {
                MsgBox 0x40031, % "output_type: " this.type " - faulty meta parameter", % "The meta parameter`n'renderingpackage_end'`ndoes not exist. Exiting. Please refer to documentation and fix the file 'DynamicArguments.ini'."
            }
            Str:=this.renderingpackage_start
        } else {

            if InStr(this.type,"::") { ;; start string
                Str:=this.type "(`n" ;; check if format is from a specific package or not
            } else {
                Str:="rmarkdown::" this.type "(`n"  ;; assume rmarkdown-package if not the case
            }
        }
        this._Adjust()
        for Parameter, Value in this.Arguments {
            if Value.Control="meta" {
                continue
            }
            if Value.Value="" && Value.Default="" {
                continue
            }
            if InStr(Parameter,"___") {
                Parameter:="'" StrReplace(Parameter,"___", "-") "'"
            } else if InStr(Parameter,"-") {
                Parameter:="'" Parameter "'"
            }
            if (Parameter="toc_depth" && !this.Arguments["toc"].Value) {
                continue
            }
            if (Value.Type="String") && (Value.Value!="") && (Value.Default!="NULL") {
                Value.Value:=DA_Quote(Value.Value)
            }
            if (InStr(Parameter,"reference_docx") || InStr(Parameter,"reference-doc"))  {
                ParamBackup:=Value.Value
                if Instr(Value.Value,this.DDL_ParamDelimiter) {
                    ParamString:=strsplit(Value.Value,this.DDL_ParamDelimiter).2
                } else {
                    ParamString:=Value.Value
                }
                if Instr(ParamString,"(") {
                    ParamString:=strsplit(ParamString,"(").2
                        , ParamString:=Trim(ParamString,"""")
                    if SubStr(ParamString,0)=")" {
                        tpl_Len:=StrLen(ParamString)-1
                            , ParamString:=SubStr(ParamString, 1, tpl_Len)
                    }
                }
                ParamString:=StrReplace(ParamString, "\", "/")
                    , Value.Value:=DA_Quote(ParamString)
                if (ParamString="") {
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                }
                if Instr(ParamBackup,this.DDL_ParamDelimiter) {
                    ParamBackup:=Trim(StrSplit(ParamBackup, this.DDL_ParamDelimiter).2)
                }
                if !FileExist(Value.Value) && !FileExist(strreplace(ParamBackup,"\","/")) {
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                }
                if !FileExist(Trim(Value.Value,"""")) && !FileExist(strreplace(ParamBackup,"\","/")) {
                    MsgBox 0x40031, % "output_type: " this.type " - faulty reference_docx", % "The given path to the reference docx-file`n'" Value.Value "'`ndoes not exist. Returning."
                    return
                }

            }
            Str.= Parameter " = " Value.Value ",`n"
        }
        for Parameter, Value in this.Arguments {
            if Value.Control="meta" {
                this.Arguments.Remove(Parameter)
                continue
            }
        }
        Str:=SubStr(Str,1,StrLen(Str)-2)
        Str.=(Instr(Str,"`n")?"`n)":"")
        if InStr(Str,this.renderingpackage_start) {
            if this.HasKey("renderingpackage_end") {

                Str:=strreplace(Str,"`n)",this.renderingpackage_end)
            }
        }
        this.AssembledFormatString:=Str
        return
    }

    AdjustDDLs() {
        for Parameter,Value in this.Arguments {
            if (Value.Control!="DDL") && (Value.Control!="DropDownList") {
                continue
            }
        }
    }
    AdjustBools() {
        for Parameter, Value in this.Arguments {
            if (Value.Type="Integer" || Value.Type="Number" || Value.Type="Boolean") {
                Value.Value:=Value.Value+0
            }
            if (Value.Type="boolean") {
                Value.Value:=(Value.Value?"TRUE":"FALSE")
            }
        }
    }
    AdjustIntegers() {
        for Parameter, Value in this.Arguments {
            if (Value.Type="Integer") {
                Value.Value:=Floor(Value.Value)
            }
        }
    }
    AdjustMinMax() {
        for Parameter, Value in this.Arguments {
            if RegexMatch(Value.Other,"Max\:(?<Max>\d*)",v_) {
                Value.Max:=v_Max+0
            }
            if RegexMatch(Value.Other,"Min\:(?<Min>\d*)",v_) {
                Value.Min:=v_Min+0
            }
            if Value.HasKey("Max") && Value.Value>Value.Max {
                Value.Value:=Value.Max+0
            }
            if Value.HasKey("Min") && Value.Min>Value.Value {
                Value.Value:=Value.Min+0
            }
            if (Value.HasKey("Max") && Value.HasKey("Max")) {
                if !((Value.Value<=Value.Max) && (Value.Min<=Value.Value)) {
                    Value.Value:=Value.Default
                }
            }
        }
    }
    AdjustNulls() {
        for _, Value in this.Arguments {
            if Value.Value="NULL" {
                Value.Value:=strreplace(Value.Value,"""")
            }
        }
    }
    AssumeDefaults() {
        for _, Value in this.Arguments {
            if Value.HasKey("SearchPath") {
                Value.SearchPath:=strreplace(Value.SearchPath,"""","")
            }
            Value.String:=strreplace(Value.String,"""","")
            if (Value.Type="String") {
                Value.Default:=strreplace(Value.Default,"""","")
            }
            if (Value.Value="") {
                if (Value.Control="File") {
                    if !FileExist(Value.SearchPath Value.Default) {
                        MsgBox 0x40031, % "output_type: " this.type, % "The default File`n'" Value.SearchPath Value.Default "'`ndoes not exist. No default set."
                    } else {
                        Value.Value:=Value.SearchPath Value.Default
                    }
                } else {
                    Value.Value:=Value.Default
                }
            }
        }
    }

    ChooseFile(VarName) {
        VarName:=strreplace(VarName,"___","-")
        FileSelectFile Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% default
        SplitPath % Chosen,,,,ChosenName
        if (Chosen!="") {
            ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:44:47 AM ; case sensitivity
            guicontrol %GUI_ID%,v%VarName%, % ChosenName A_Space this.DDL_ParamDelimiter A_Space Chosen
        }
    }

    OpenFileSelectionFolder(Path) {
        SplitPath % Path,, OutDir
        run % OutDir
    }

    GenerateGUI(x:="",y:="",AttachBottom:=true,GUI_ID:="ParamsGUI:",destroyGUI:=true,xpos_control:=false,Tab3Width:=674,ShowGui:=false) {
        global ;; this cannot be made static or this.SubmitDynamicArguments() will not receive modified values (aka it will always assemble the default)
        if (destroyGUI) {
            gui %GUI_ID% destroy
        }
        this.GUI_ID:=GUI_ID
        if this.HasKey("Error") {
            ID:=strsplit(this.Error,A_Space).2
            if !(SubStr(ID,1,1)="-") {
                return this
            }
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        if (destroyGUI) {
            gui %GUI_ID% new, +AlwaysOnTop -SysMenu -ToolWindow +caption +Border +LabelotGUI_ +hwndotGUI_
        }
        gui font, s8
        TabHeaders:={}
        for Parameter, Value in this.Arguments {
            if Value.HasKey("Tab3Parent") {
                TabHeaders[Value.Tab3Parent]:={Height:0}
            } else {
                this.Arguments[Parameter,"Tab3Parent"]:="Other"
                    , TabHeaders[Value.Tab3Parent]:={Height:0}
            }
        }
        Tab3String:=""
            , ind:=0
            , HiddenHeaders:={}
        for Header,_  in TabHeaders {
            HeaderFound:=false
            for Parameter, Value in this.Arguments {
                if (Value.Tab3Parent=Header) {
                    if Value.Control!="meta" {
                        HeaderFound:=true
                            , HiddenHeaders[Header]:=false
                        break
                    } else {
                        HiddenHeaders[Header]:=true
                    }
                }
            }
            if (HeaderFound) {

                Tab3String.=Header
                    , ind++
                if (ind<TabHeaders.Count()) || (ind=1) {
                    Tab3String.="|"
                }
            }
        }
        gui %GUI_ID% add, Tab3,% "vvTab3 h900 w" Tab3Width, % Tab3String
        if (this.StepsizedGuishow) {
            gui %GUI_ID% show
        }
        for Tab, _ in TabHeaders {
            if HiddenHeaders[Tab] {
                continue
            }
            if (this.StepsizedGuishow) {
                gui %GUI_ID% show
            }
            TabHeight:=0
            gui %GUI_ID% Tab, % Tab,, Exact
            GuiControl Choose, vTab3, % Tab
            for Parameter, Value in this.Arguments {
                if Value.Control="meta" {
                    this[Parameter]:=Value.Value
                    continue
                }
                if InStr(Parameter,"-") {
                    Parameter:=strreplace(Parameter,"-","___") ;; fix "toc-depth"-like formatted parameters for quarto syntax when displaying. Three underscores are used to differentiate it from valid syntax for other packages.
                }
                if !InStr(Value.String,strreplace(Parameter,"___","-")) {
                    Value.String:= "" strreplace(Parameter,"___","-") "" ":" A_Space Value.String
                }
                ControlHeight:=0
                if (Tab=Value.Tab3Parent) {
                    Control:=Value.Control
                    if (Options="") {
                        Options:=""
                    }
                    if (Value.Control="Edit") {
                        GuiControl Choose, vTab3, % Tab
                        if Value.HasKey("Link") {
                            gui %GUI_ID%  add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,h20, % Value.String
                        }
                        ControlHeight+=20
                        if (Value.ctrlOptions="Number") {
                            if (Value.Max!="") && (Value.Min!="") {
                                Value.ctrlOptions.= A_Space
                                gui %GUI_ID% add, Edit,
                                gui %GUI_ID% add, UpDown, % "h20 w80 Range" Value.Min "-" Value.Max " vv" Parameter, % Value.Default + 0
                                ControlHeight+=20
                                GuiControl %GUI_ID% Move, vTab3, % "h" TabHeight + ControlHeight + 16
                                TabHeight+=ControlHeight
                                GuiControl %GUI_ID% Move, vTab3, % "h" TabHeight + 16
                                if (this.StepsizedGuishow) {
                                    gui %GUI_ID% show
                                }
                                continue
                            }
                        }
                        if !RegexMatch(Value.ctrlOptions,"w\d*") {
                            Value.ctrlOptions.= " w120"
                        }
                        if RegexMatch(Value.ctrlOptions,"h(?<vH>\d*)",v) {
                            ControlHeight+=vvH + 15
                        } else if !RegexMatch(Value.ctrlOptions,"h(?<vH>\d*)",v) {
                            Value.ctrlOptions.= " h35"
                            ControlHeight+=35
                        }
                        gui %GUI_ID% add, % Value.Control, % Value.ctrlOptions " vv" Parameter, % (Value.Value="NULL"?:Value.Value)
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight + 32
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                        ;GuiControl Move, vTab3, % "h" TabHeight
                    } else if (Value.Control="File") {
                        if Value.HasKey("Link") {
                            gui %GUI_ID%  add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,TabHeight+20, % Value.String
                        }
                        ControlHeight+=20
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, edit, % Value.ctrlOptions " vv" Parameter " disabled w200 yp+30 h60", % Value.Value
                        ControlHeight+=90
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, button, yp+70 hwndSelectFile, % "Select &File"
                        ControlHeight+=30
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, button, yp xp+77 hwndOpenFileSelectionFolder, % "Open File Selection Folder"
                        onOpenFileSelectionFolder:=ObjBindMethod(this, "OpenFileSelectionFolder", Value.SearchPath)
                        onSelectFile := ObjBindMethod(this, "ChooseFile",Parameter)
                        GuiControl %GUI_ID% +g, %SelectFile%, % onSelectFile
                        GuiControl %GUI_ID% +g, %OpenFileSelectionFolder%, % onOpenFileSelectionFolder
                        gui %GUI_ID% add,text, w0 h0 yp+20 xp-77
                        ControlHeight+=20
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                    } else if (Value.Control="DDL") || (Value.Control="ComboBox") {
                        if Value.HasKey("Link") {
                            gui %GUI_ID%  add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,h20, % Value.String
                        }
                        if Instr(Value.ctrlOptions,",") && !Instr(Value.ctrlOptions,"|") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,",","|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default) {
                            Value.ctrlOptions.=((SubStr(Value.ctrlOptions,-1)="|")?"":"|") Value.Default
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "|") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,Value.Default,Value.Default "|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "||") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,Value.Default,Value.Default "|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "||") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,Value.ctrlOptions "|")
                        }
                        Threshold:=5
                            , tmpctrlOptions:=LTrim(RTrim(strreplace(Value.ctrlOptions,"||","|"),"|"),"|")
                            , tmpctrlOptions_arr:=strsplit(tmpctrlOptions,"|")
                            , Count:=tmpctrlOptions_arr.Count()
                            , shown_rows:=(Count<=1?1:(Count>Threshold?Threshold:Count))
                        gui %GUI_ID% add, % Value.Control, % "  vv" Parameter " r" shown_rows , % Value.ctrlOptions
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                        ControlHeight+=75
                    } else if (Value.Control="DateTime"){
                        if Value.HasKey("Link") {
                            gui %GUI_ID%  add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,h20, % Value.String
                        }
                        AHKVARIABLES := { "A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}

                        gui %GUI_ID%  add, DateTime, % Value.ctrlOptions " h30 vv" Parameter, % "dd.MM.yyyy"
                        guicontrol %GUI_ID%,v%Parameter%,% DA_DateParse(DA_FormatEx(Value.Value, AHKVARIABLES))
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                    } else {
                        if Value.HasKey("Link") {
                            if (Value.Control="Checkbox") { 
                                gui %GUI_ID% add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space
                                gui %GUI_ID% add, % Value.Control, % Value.ctrlOptions "yp-8 xp+8 h30 vv" Parameter, % Value.String
                                gui %GUI_ID% add, text, h0 w0 xp-8 yp+20
                                if (this.StepsizedGuishow) {
                                    gui %GUI_ID% show
                                }
                            }
                        } else {
                            gui %GUI_ID% add, % Value.Control, % Value.ctrlOptions " h30 vv" Parameter, % Value.String
                            if (this.StepsizedGuishow) {
                                gui %GUI_ID% show
                            }
                        }
                        ControlHeight+=30
                    }
                    if (Value.Control="Checkbox") {
                        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:49:09 AM ; case sensitivity
                        guicontrol %GUI_ID% ,v%Parameter%, % Value.Default
                    }

                    if (Control="Edit") {
                        ; V.String:=tmp
                    }
                    if InStr(Parameter,"pandoc") {
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                    } else {
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight + 16
                    }
                    TabHeight+=ControlHeight + 3
                }
                GuiControl Move, vTab3, % "h" TabHeight + 32
                ;gui show
            }
            TabHeaders[Tab].Height+=TabHeight+=32
        }
        maxTabHeight:=0
        for _, Tab in TabHeaders {
            if HiddenHeaders[Tab] {
                continue
            }
            if (Tab.Height>maxTabHeight) {
                maxTabHeight:=Tab.Height + 80
            }
        }
        GuiControl Move, vTab3, % "h" maxTabHeight
        ;guicontrol hide,vTab3
        ttip(maxTabHeight)
        maxTabHeight+=25
        ;gui show,
        GuiControl Choose, vTab3, 1
        gui %GUI_ID% Tab
        if (AttachBottom) {
            gui %GUI_ID% add, button,y%maxTabHeight% xp hwndSubmitButton,&Submit
            onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
            GuiControl %GUI_ID% +g,%SubmitButton%, % onSubmit
            gui %GUI_ID% add, button, yp xp+60 hwndEditConfig, Edit Configuration
            onEditConfig:=ObjBindMethod(this, "EditConfig")
            GuiControl %GUI_ID% +g,%EditConfig%, % onEditConfig
            onEscape:=ObjBindMethod(this,"otGUI_Escape2")
            Hotkey IfWinActive, % "ahk_id " otGUI_
            Hotkey Escape,% onEscape
            guiWidth:=692
            guiHeight:=maxTabHeight+40
        } else {
            guiWidth:=692
            guiHeight:=maxTabHeight

        }
        ;if (!x || (x="")) {
        currentMonitor:=MWAGetMonitor()+0
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
        MouseGetPos MouseX
        CoordMode Mouse, %CoordModeMouse%
        if ((x+guiWidth)>MonRight) {
            x:=MonRight-guiWidth
        } Else {
            x:=MouseX
        }
        if (this.StepsizedGuishow) || ShowGui {
            if (!this.SkipGUI) {
                if (x!="") && (y!="") {
                    gui %GUI_ID% Show,x%x% y%y% w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
                } else {
                    gui %GUI_ID% Show,w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
                }
                WinWait % GUIName
            }
            if this.SkipGUI {
                this.SubmitDynamicArguments() ;; auto-submit the GUI
            } Else {
                WinWaitClose % GUIName
            }
        }
        return this
    }
    EditConfig() {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID%  Submit, NoHide
        RunWait % this.ConfigFile,,,PID
        WinWaitClose % "ahk_PID" PID
        Gui +OwnDialogs
        OnMessage(0x44, "DA_OnMsgBox")
        MsgBox 0x40044, % this.ClassName " > " A_ThisFunc "()", You modified the configuration for this class.`nReload?
        OnMessage(0x44, "")

        IfMsgBox Yes, {
            reload
        } Else IfMsgBox No, {

        }

    }
    SubmitDynamicArguments() {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% Default
        gui %GUI_ID% Submit
        for Parameter,_ in this.Arguments {
            ;@ahk-neko-ignore 1 line; at 4/28/2023, 9:49:42 AM ; https://github.com/CoffeeChaton/vscode-autohotkey-NekoHelp/blob/main/note/code107.md
            Parameter:=strreplace(Parameter,"-","___")
            ;k=v%Parameter% ;; i know this is jank, but I can't seem to fix it. just don't touch for now?
            ;a:=%k%
            GuiControlGet val,, v%Parameter%
            Parameter:=strreplace(Parameter,"___","-")
                , this["Arguments",Parameter].Value:=val
        }
        gui %GUI_ID% destroy
        return this
    }
    otGUI_Escape2() {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% Submit
        gui %GUI_ID% destroy
        ID:=0
            , this.Error:=this.Errors[ID]
        return this
    }
}

; #region:DA_Quote (4179423054)

; #region:Metadata:
; Snippet: DA_Quote;  (v.1)
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
; #endregion:Metadata

; #region:Description:
; Quotes a string
; #endregion:Description

; #region:Example
; Var:="Hello World"
; msgbox, % DA_Quote(Var . " Test")
;
; #endregion:Example

; #region:Code
DA_Quote(String) { ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
    return """" String """"
}
; #endregion:Code

; #endregion:DA_Quote (4179423054)

DA_OnMsgBox() {
    DetectHiddenWindows On
    Process Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Continue with old
    }
}


; #region:DateParse (3465982675)

; #region:Metadata:
; Snippet: DateParse;  (v.1.05)
; --------------------------------------------------------------
; Author: polythene
; License: GNU GPL2
; LicenseURL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
; Source: https://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/?p=124324
; NOTE Gewerd Strauss:: I could track down polythene's linked post above as the oldest found 
; post mentioning this post, wherein the need to link to their ahknet-site is required.
; However, since ahknet has been offline long before I needed to use this.
; (01 August 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 26 - Date or Time
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: date, parsing, iso, YYYYMMDDHH24MISS
; #endregion:Metadata


; #region:Description:
; convert almost any date format to a YYYYMMDDHH24MISS value.
; Parameters:
; 	str - a date/time stamp as a string
; Returns:
; 	A valid YYYYMMDDHH24MISS value which can be used by FormatTime, EnvAdd and other time commands.
; License:
; 	- Version 1.05 <http://www.autohotkey.net/~polyethene/#dateparse>
; 	- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
; #endregion:Description

; #region:Example
; time := DateParse("2:35 PM, 27 November, 2007")
; #endregion:Example


; #region:Code
/*

*/
DA_DateParse(str) {
    static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
    str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
    If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
        . "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
        . "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
    d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
    Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
        RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?(?:\s*([ap]m))?", t)
        , RegExMatch(str, e2, d)
    f = %A_FormatFloat%
    SetFormat Float, 02.0
    d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
        . ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0
        ? d2 + 0.0 : A_MM) . ((d1 += 0.0) ? d1 : A_DD) . t1
        + (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "am" ? 0.0 : 12.0) . t2 + 0.0 . t3 + 0.0
    SetFormat Float, %f%
    Return, d
}

; #endregion:Code




; #region:License
;                     GNU GENERAL PUBLIC LICENSE
;                        Version 2, June 1991
; 
;  Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
;  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
;  Everyone is permitted to copy and distribute verbatim copies
;  of this license document, but changing it is not allowed.
; 
;                             Preamble
; 
;   The licenses for most software are designed to take away your
; freedom to share and change it.  By contrast, the GNU General Public
; License is intended to guarantee your freedom to share and change free
; software--to make sure the software is free for all its users.  This
; General Public License applies to most of the Free Software
; Foundation's software and to any other program whose authors commit to
; using it.  (Some other Free Software Foundation software is covered by
; the GNU Lesser General Public License instead.)  You can apply it to
; your programs, too.
; 
;   When we speak of free software, we are referring to freedom, not
; price.  Our General Public Licenses are designed to make sure that you
; have the freedom to distribute copies of free software (and charge for
; this service if you wish), that you receive source code or can get it
; if you want it, that you can change the software or use pieces of it
; in new free programs; and that you know you can do these things.
; 
;   To protect your rights, we need to make restrictions that forbid
; anyone to deny you these rights or to ask you to surrender the rights.
; These restrictions translate to certain responsibilities for you if you
; distribute copies of the software, or if you modify it.
; 
;   For example, if you distribute copies of such a program, whether
; gratis or for a fee, you must give the recipients all the rights that
; you have.  You must make sure that they, too, receive or can get the
; source code.  And you must show them these terms so they know their
; rights.
; 
;   We protect your rights with two steps: (1) copyright the software, and
; (2) offer you this license which gives you legal permission to copy,
; distribute and/or modify the software.
; 
;   Also, for each author's protection and ours, we want to make certain
; that everyone understands that there is no warranty for this free
; software.  If the software is modified by someone else and passed on, we
; want its recipients to know that what they have is not the original, so
; that any problems introduced by others will not reflect on the original
; authors' reputations.
; 
;   Finally, any free program is threatened constantly by software
; patents.  We wish to avoid the danger that redistributors of a free
; program will individually obtain patent licenses, in effect making the
; program proprietary.  To prevent this, we have made it clear that any
; patent must be licensed for everyone's free use or not licensed at all.
; 
;   The precise terms and conditions for copying, distribution and
; modification follow.
; 
;                     GNU GENERAL PUBLIC LICENSE
;    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
; 
;   0. This License applies to any program or other work which contains
; a notice placed by the copyright holder saying it may be distributed
; under the terms of this General Public License.  The "Program", below,
; refers to any such program or work, and a "work based on the Program"
; means either the Program or any derivative work under copyright law:
; that is to say, a work containing the Program or a portion of it,
; either verbatim or with modifications and/or translated into another
; language.  (Hereinafter, translation is included without limitation in
; the term "modification".)  Each licensee is addressed as "you".
; 
; Activities other than copying, distribution and modification are not
; covered by this License; they are outside its scope.  The act of
; running the Program is not restricted, and the output from the Program
; is covered only if its contents constitute a work based on the
; Program (independent of having been made by running the Program).
; Whether that is true depends on what the Program does.
; 
;   1. You may copy and distribute verbatim copies of the Program's
; source code as you receive it, in any medium, provided that you
; conspicuously and appropriately publish on each copy an appropriate
; copyright notice and disclaimer of warranty; keep intact all the
; notices that refer to this License and to the absence of any warranty;
; and give any other recipients of the Program a copy of this License
; along with the Program.
; 
; You may charge a fee for the physical act of transferring a copy, and
; you may at your option offer warranty protection in exchange for a fee.
; 
;   2. You may modify your copy or copies of the Program or any portion
; of it, thus forming a work based on the Program, and copy and
; distribute such modifications or work under the terms of Section 1
; above, provided that you also meet all of these conditions:
; 
;     a) You must cause the modified files to carry prominent notices
;     stating that you changed the files and the date of any change.
; 
;     b) You must cause any work that you distribute or publish, that in
;     whole or in part contains or is derived from the Program or any
;     part thereof, to be licensed as a whole at no charge to all third
;     parties under the terms of this License.
; 
;     c) If the modified program normally reads commands interactively
;     when run, you must cause it, when started running for such
;     interactive use in the most ordinary way, to print or display an
;     announcement including an appropriate copyright notice and a
;     notice that there is no warranty (or else, saying that you provide
;     a warranty) and that users may redistribute the program under
;     these conditions, and telling the user how to view a copy of this
;     License.  (Exception: if the Program itself is interactive but
;     does not normally print such an announcement, your work based on
;     the Program is not required to print an announcement.)
; 
; These requirements apply to the modified work as a whole.  If
; identifiable sections of that work are not derived from the Program,
; and can be reasonably considered independent and separate works in
; themselves, then this License, and its terms, do not apply to those
; sections when you distribute them as separate works.  But when you
; distribute the same sections as part of a whole which is a work based
; on the Program, the distribution of the whole must be on the terms of
; this License, whose permissions for other licensees extend to the
; entire whole, and thus to each and every part regardless of who wrote it.
; 
; Thus, it is not the intent of this section to claim rights or contest
; your rights to work written entirely by you; rather, the intent is to
; exercise the right to control the distribution of derivative or
; collective works based on the Program.
; 
; In addition, mere aggregation of another work not based on the Program
; with the Program (or with a work based on the Program) on a volume of
; a storage or distribution medium does not bring the other work under
; the scope of this License.
; 
;   3. You may copy and distribute the Program (or a work based on it,
; under Section 2) in object code or executable form under the terms of
; Sections 1 and 2 above provided that you also do one of the following:
; 
;     a) Accompany it with the complete corresponding machine-readable
;     source code, which must be distributed under the terms of Sections
;     1 and 2 above on a medium customarily used for software interchange; or,
; 
;     b) Accompany it with a written offer, valid for at least three
;     years, to give any third party, for a charge no more than your
;     cost of physically performing source distribution, a complete
;     machine-readable copy of the corresponding source code, to be
;     distributed under the terms of Sections 1 and 2 above on a medium
;     customarily used for software interchange; or,
; 
;     c) Accompany it with the information you received as to the offer
;     to distribute corresponding source code.  (This alternative is
;     allowed only for noncommercial distribution and only if you
;     received the program in object code or executable form with such
;     an offer, in accord with Subsection b above.)
; 
; The source code for a work means the preferred form of the work for
; making modifications to it.  For an executable work, complete source
; code means all the source code for all modules it contains, plus any
; associated interface definition files, plus the scripts used to
; control compilation and installation of the executable.  However, as a
; special exception, the source code distributed need not include
; anything that is normally distributed (in either source or binary
; form) with the major components (compiler, kernel, and so on) of the
; operating system on which the executable runs, unless that component
; itself accompanies the executable.
; 
; If distribution of executable or object code is made by offering
; access to copy from a designated place, then offering equivalent
; access to copy the source code from the same place counts as
; distribution of the source code, even though third parties are not
; compelled to copy the source along with the object code.
; 
;   4. You may not copy, modify, sublicense, or distribute the Program
; except as expressly provided under this License.  Any attempt
; otherwise to copy, modify, sublicense or distribute the Program is
; void, and will automatically terminate your rights under this License.
; However, parties who have received copies, or rights, from you under
; this License will not have their licenses terminated so long as such
; parties remain in full compliance.
; 
;   5. You are not required to accept this License, since you have not
; signed it.  However, nothing else grants you permission to modify or
; distribute the Program or its derivative works.  These actions are
; prohibited by law if you do not accept this License.  Therefore, by
; modifying or distributing the Program (or any work based on the
; Program), you indicate your acceptance of this License to do so, and
; all its terms and conditions for copying, distributing or modifying
; the Program or works based on it.
; 
;   6. Each time you redistribute the Program (or any work based on the
; Program), the recipient automatically receives a license from the
; original licensor to copy, distribute or modify the Program subject to
; these terms and conditions.  You may not impose any further
; restrictions on the recipients' exercise of the rights granted herein.
; You are not responsible for enforcing compliance by third parties to
; this License.
; 
;   7. If, as a consequence of a court judgment or allegation of patent
; infringement or for any other reason (not limited to patent issues),
; conditions are imposed on you (whether by court order, agreement or
; otherwise) that contradict the conditions of this License, they do not
; excuse you from the conditions of this License.  If you cannot
; distribute so as to satisfy simultaneously your obligations under this
; License and any other pertinent obligations, then as a consequence you
; may not distribute the Program at all.  For example, if a patent
; license would not permit royalty-free redistribution of the Program by
; all those who receive copies directly or indirectly through you, then
; the only way you could satisfy both it and this License would be to
; refrain entirely from distribution of the Program.
; 
; If any portion of this section is held invalid or unenforceable under
; any particular circumstance, the balance of the section is intended to
; apply and the section as a whole is intended to apply in other
; circumstances.
; 
; It is not the purpose of this section to induce you to infringe any
; patents or other property right claims or to contest validity of any
; such claims; this section has the sole purpose of protecting the
; integrity of the free software distribution system, which is
; implemented by public license practices.  Many people have made
; generous contributions to the wide range of software distributed
; through that system in reliance on consistent application of that
; system; it is up to the author/donor to decide if he or she is willing
; to distribute software through any other system and a licensee cannot
; impose that choice.
; 
; This section is intended to make thoroughly clear what is believed to
; be a consequence of the rest of this License.
; 
;   8. If the distribution and/or use of the Program is restricted in
; certain countries either by patents or by copyrighted interfaces, the
; original copyright holder who places the Program under this License
; may add an explicit geographical distribution limitation excluding
; those countries, so that distribution is permitted only in or among
; countries not thus excluded.  In such case, this License incorporates
; the limitation as if written in the body of this License.
; 
;   9. The Free Software Foundation may publish revised and/or new versions
; of the General Public License from time to time.  Such new versions will
; be similar in spirit to the present version, but may differ in detail to
; address new problems or concerns.
; 
; Each version is given a distinguishing version number.  If the Program
; specifies a version number of this License which applies to it and "any
; later version", you have the option of following the terms and conditions
; either of that version or of any later version published by the Free
; Software Foundation.  If the Program does not specify a version number of
; this License, you may choose any version ever published by the Free Software
; Foundation.
; 
;   10. If you wish to incorporate parts of the Program into other free
; programs whose distribution conditions are different, write to the author
; to ask for permission.  For software which is copyrighted by the Free
; Software Foundation, write to the Free Software Foundation; we sometimes
; make exceptions for this.  Our decision will be guided by the two goals
; of preserving the free status of all derivatives of our free software and
; of promoting the sharing and reuse of software generally.
; 
;                             NO WARRANTY
; 
;   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
; FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
; OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
; PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
; OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
; TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
; PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
; REPAIR OR CORRECTION.
; 
;   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
; WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
; REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
; INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
; OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
; TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
; YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
; PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGES.
; 
;                      END OF TERMS AND CONDITIONS
; 
;             How to Apply These Terms to Your New Programs
; 
;   If you develop a new program, and you want it to be of the greatest
; possible use to the public, the best way to achieve this is to make it
; free software which everyone can redistribute and change under these terms.
; 
;   To do so, attach the following notices to the program.  It is safest
; to attach them to the start of each source file to most effectively
; convey the exclusion of warranty; and each file should have at least
; the "copyright" line and a pointer to where the full notice is found.
; 
;     <one line to give the program's name and a brief idea of what it does.>
;     Copyright (C) <year>  <name of author>
; 
;     This program is free software; you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation; either version 2 of the License, or
;     (at your option) any later version.
; 
;     This program is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.
; 
;     You should have received a copy of the GNU General Public License along
;     with this program; if not, write to the Free Software Foundation, Inc.,
;     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
; 
; Also add information on how to contact you by electronic and paper mail.
; 
; If the program is interactive, make it output a short notice like this
; when it starts in an interactive mode:
; 
;     Gnomovision version 69, Copyright (C) year name of author
;     Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
;     This is free software, and you are welcome to redistribute it
;     under certain conditions; type `show c' for details.
; 
; The hypothetical commands `show w' and `show c' should show the appropriate
; parts of the General Public License.  Of course, the commands you use may
; be called something other than `show w' and `show c'; they could even be
; mouse-clicks or menu items--whatever suits your program.
; 
; You should also get your employer (if you work as a programmer) or your
; school, if any, to sign a "copyright disclaimer" for the program, if
; necessary.  Here is a sample; alter the names:
; 
;   Yoyodyne, Inc., hereby disclaims all copyright interest in the program
;   `Gnomovision' (which makes passes at compilers) written by James Hacker.
; 
;   <signature of Ty Coon>, 1 April 1989
;   Ty Coon, President of Vice
; 
; This General Public License does not permit incorporating your program into
; proprietary programs.  If your program is a subroutine library, you may
; consider it more useful to permit linking proprietary applications with the
; library.  If this is what you want to do, use the GNU Lesser General
; Public License instead of this License.
; 
; #endregion:License

; #endregion:DateParse (3465982675)
DA_FormatEx(FormatStr, Values*) {
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
            FormatStr := StrReplace(FormatStr, "{" search "}", "{"++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
