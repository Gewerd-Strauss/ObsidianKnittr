Class ot {
    __New(Format:="",ConfigFile:="",DDL_ParamDelimiter:="-<>-",SkipGUI:=FALSE) {
        this.type:=Format
        this.ClassName.= Format ")"
        this.DDL_ParamDelimiter:=DDL_ParamDelimiter
        this.SkipGUI:=SkipGUI
        if FileExist(ConfigFile) {
            this.ConfigFile:=ConfigFile
        } else {
            ID:=-1
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'") "'" ConfigFile "'" (this.Errors[ID].HasKey("EndString")?this.Errors[ID].EndString:"Fatal: Undefined Error with ID '" ID "'")
            ExitApp
            return
        }

        FileRead Text, % ConfigFile
        Lines:=strsplit(Text,Format "`r`n").2
        Lines:=strsplit(Lines,"`r`n`r`n").1
        Lines:=strsplit(Lines,"`r`n")
        if !Lines.Count() {
            this.Result:=this.type:=Format "()"
            ID:=+2
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        for _, Line in Lines {
            Count:=1
            p := 1
            regex:="(?<Key>\w+\:)(?<Val>[^|]+)" ;; does not support keys a la 'toc-depth' (as required by quarto)
            regex:="(?<Key>(\-|\w)+\:)(?<Val>[^|]+)"
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
                                p+=StrLen(Match)
                                Count++
                                continue
                            } else {
                                CurrentParam:=matchKey
                                ObjRawSet(This.Arguments,matchKey,{})
                                ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                            }
                        }
                        if !(InStr(Line,"renderingpackage")) {
                            ObjRawSet(This.Arguments[CurrentParam],matchKey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
                        }
                        p+=StrLen(Match)
                        Count++
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
        this.ClassName:="ot ("
        this.GUITitle:="Define output format - "
        this.Version:="0.1.a"
        this.type:=""
        this.ConfigFile:=""
        this.bClosedNoSubmit:=false
        ObjRawSet(this,"type","")
        ObjRawSet(this,"Arguments",{})
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
                    ParamString:=Trim(ParamString,"""")
                    if SubStr(ParamString,0)=")" {
                        tpl_Len:=StrLen(ParamString)-1
                        ParamString:=SubStr(ParamString, 1, tpl_Len)
                    }
                }
                ParamString:=StrReplace(ParamString, "\", "/")
                Value.Value:=DA_Quote(ParamString)
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
            if Value.HasKey("Max") {
                Value.Value:=Value.Max+0
            }
            if Value.HasKey("Min") && Value.Min>Value.Value 
            {
                Value.Value:=Value.Min+0
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
        FileSelectFile Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
        gui ParamsGUI:default
        SplitPath % Chosen,,,,ChosenName
        if (Chosen!="") {
            ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:44:47 AM ; case sensitivity
            guicontrol % "ParamsGUI:",v%VarName%, % ChosenName A_Space this.DDL_ParamDelimiter A_Space Chosen
        }
    }

    OpenFileSelectionFolder(Path) {
        SplitPath % Path,, OutDir
        run % OutDir
    }

    GenerateGUI(x:="",y:="") {
        global ;; this cannot be made static or this.SubmitDynamicArguments() will not receive modified values (aka it will always assemble the default)
        gui ParamsGUI: destroy
        if this.HasKey("Error") {
            ID:=strsplit(this.Error,A_Space).2
            if !(SubStr(ID,1,1)="-") {
                return this
            }
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }

        gui ParamsGUI: new, +AlwaysOnTop -SysMenu -ToolWindow +caption +Border +LabelotGUI_ +hwndotGUI_
        gui font, s8
        TabHeaders:={}
        for Parameter, Value in this.Arguments {
            if Value.HasKey("Tab3Parent") {

                TabHeaders[Value.Tab3Parent]:={Height:0}
            } else {
                this.Arguments[Parameter,"Tab3Parent"]:="Other"
                TabHeaders[Value.Tab3Parent]:={Height:0}
            }
        }
        Tab3String:=""
        ind:=0
        HiddenHeaders:={}
        for Header,_  in TabHeaders {
            HeaderFound:=false
            for Parameter, Value in this.Arguments {
                if (Value.Tab3Parent=Header) {
                    if Value.Control!="meta" {

                        HeaderFound:=true
                        HiddenHeaders[Header]:=false
                        break
                    } else {
                        HiddenHeaders[Header]:=true
                    }
                }
            }
            if (HeaderFound) {

                Tab3String.=Header
                ind++
                if (ind<TabHeaders.Count()) || (ind=1) {
                    Tab3String.="|"
                }
            }
        }
        WideControlWidth:=330
        gui add, Tab3, vvTab3 h900 w674, % Tab3String
        ;gui show, % "y0 x" A_ScreenWidth-500
        for Tab, Object in TabHeaders {
            if HiddenHeaders[Tab] {
                continue
            }
            TabHeight:=0
            gui Tab, % Tab,, Exact
            GuiControl Choose, vTab3, % Tab
            for Parameter, Value in this.Arguments {
                if Value.Control="meta" {
                    this[Parameter]:=Value.Value
                    continue
                }
                if InStr(Parameter,"-") {
                    Parameter:=strreplace(Parameter,"-","___") ;; fix "toc-depth"-like formatted parameters for quarto syntax when displaying. Three underscores are used to differentiate it from valid syntax for other packages.
                }
                if InStr(Parameter,"pandoc") {


                }
                if (True) {
                    if !InStr(Value.String,strreplace(Parameter,"___","-")) {
                        Value.String:= "" strreplace(Parameter,"___","-") "" ":" A_Space Value.String
                    }
                }
                ControlHeight:=0
                if (Tab=Value.Tab3Parent) {
                    Control:=Value.Control
                    if (Options="") {
                        Options:=""
                    }
                    if (Value.Control="Edit") {
                        if Value.HasKey("Link") {
                            gui ParamsGUI: add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui ParamsGUI: add, text,h20, % Value.String
                        }
                        ControlHeight+=20
                        if (Value.ctrlOptions="Number") {
                            if (Value.Max!="") && (Value.Min!="") {
                                Value.ctrlOptions.= A_Space
                                Gui ParamsGUI:Add, Edit,
                                gui ParamsGUI:add, UpDown, % "h20 w80 Range" Value.Min "-" Value.Max " vv" Parameter, % Value.Default + 0
                                ControlHeight+=20
                                GuiControl Move, vTab3, % "h" TabHeight + ControlHeight + 16
                                TabHeight+=ControlHeight
                                GuiControl Move, vTab3, % "h" TabHeight + 16
                                ;gui show
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
                        gui ParamsGUI: add, % Value.Control, % Value.ctrlOptions " vv" Parameter, % (Value.Value="NULL"?:Value.Value)
                        ;GuiControl Move, vTab3, % "h" TabHeight
                    } else if (Value.Control="File") {
                        if Value.HasKey("Link") {
                            gui ParamsGUI: add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui ParamsGUI: add, text,TabHeight+20, % Value.String
                        }
                        ControlHeight+=20
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui ParamsGUI:Add, edit, % Value.ctrlOptions " vv" Parameter " disabled w200 yp+30 h60", % Value.Value
                        ControlHeight+=90
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        Gui ParamsGUI:Add, button, yp+70 hwndSelectFile, % "Select &File"
                        ControlHeight+=30
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui ParamsGUI:add, button, yp xp+77 hwndOpenFileSelectionFolder, % "Open File Selection Folder"
                        onOpenFileSelectionFolder:=ObjBindMethod(this, "OpenFileSelectionFolder", Value.SearchPath)
                        onSelectFile := ObjBindMethod(this, "ChooseFile",Parameter)
                        GuiControl ParamsGUI:+g, %SelectFile%, % onSelectFile
                        GuiControl ParamsGUI:+g, %OpenFileSelectionFolder%, % onOpenFileSelectionFolder
                        gui ParamsGUI:add,text, w0 h0 yp+20 xp-77
                        ControlHeight+=20
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                    } else if (Value.Control="DDL") || (Value.Control="ComboBox") {
                        if Value.HasKey("Link") {
                            gui ParamsGUI: add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space Value.String
                        } else {
                            gui ParamsGUI: add, text,h20, % Value.String
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
                        tmpctrlOptions:=LTrim(RTrim(strreplace(Value.ctrlOptions,"||","|"),"|"),"|")
                        tmpctrlOptions_arr:=strsplit(tmpctrlOptions,"|")
                        Count:=tmpctrlOptions_arr.Count()
                        shown_rows:=(Count<=1?1:(Count>Threshold?Threshold:Count))
                        gui ParamsGUI:add, % Value.Control, % "  vv" Parameter " r" shown_rows , % Value.ctrlOptions
                        ControlHeight+=75
                    } else {
                        if Value.HasKey("Link") {
                            if (Value.Control="Checkbox") { 
                                gui ParamsGUI: add, Link,h20, % "<a href=" Value.Link ">?</a>" A_Space
                                gui ParamsGUI: add, % Value.Control, % Value.ctrlOptions "yp-8 xp+8 h30 vv" Parameter, % Value.String
                                gui ParamsGUI: add, text, h0 w0 xp-8 yp+20
                            }
                        } else {
                            gui ParamsGUI:add, % Value.Control, % Value.ctrlOptions " h30 vv" Parameter, % Value.String
                        }
                        ControlHeight+=30
                    }
                    if (Value.Control="Checkbox") {
                        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:49:09 AM ; case sensitivity
                        guicontrol % "ParamsGUI:",v%Parameter%, % Value.Default
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
        /*
        for Parameter,Value in this.Arguments {
        Control:=Value.Control
        if (Options="") {
        Options:=""
        }
        if (Value.Control="Edit") {
        gui ParamsGUI: add, text,, % Value.String
        if (Value.ctrlOptions="Number") {
        if (Value.Max!="") && (Value.Min!="") {
        Value.ctrlOptions.= A_Space
        Gui ParamsGUI:Add, Edit
        gui ParamsGUI:add, UpDown, % "h25 w80 Range" Value.Min "-" Value.Max " vv" Parameter, % Value.Default + 0
        continue
        }
        }
        if !RegexMatch(Value.ctrlOptions,"w\d*") {
        Value.ctrlOptions.= " w120"
        }
        gui ParamsGUI: add, % Value.Control, % Value.ctrlOptions " vv" Parameter, % (Value.Value="NULL"?:Value.Value)
        } else if (Value.Control="File") {
        gui ParamsGUI:Add, Text,, % Value.String
        gui ParamsGUI:Add, edit, % Value.ctrlOptions " vv" Parameter " disabled w200", % Value.Value
        Gui ParamsGUI:Add, button, hwndSelectFile, % "Select &File"
        gui ParamsGUI:add, button, yp xp+77 hwndOpenFileSelectionFolder, % "Open File Selection Folder"
        onOpenFileSelectionFolder:=ObjBindMethod(this, "OpenFileSelectionFolder", Value.SearchPath)
        onSelectFile := ObjBindMethod(this, "ChooseFile",Parameter)
        GuiControl ParamsGUI:+g, %SelectFile%, % onSelectFile
        GuiControl ParamsGUI:+g, %OpenFileSelectionFolder%, % onOpenFileSelectionFolder
        gui ParamsGUI:add,text, w0 h0 yp+20 xp-77
        } else if (Value.Control="DDL") {
        gui ParamsGUI:Add, Text,, % Value.String
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
        gui ParamsGUI:add, % Value.Control, % " vv" Parameter, % Value.ctrlOptions
        } else {
        gui ParamsGUI:add, % Value.Control, % Value.ctrlOptions " vv" Parameter, % Value.String
        }
        if (Value.Control="Checkbox") {
        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:49:09 AM ; case sensitivity
        guicontrol % "ParamsGUI:",v%Parameter%, % Value.Default
        }

        if (Control="Edit") {
        ; V.String:=tmp
        }
        }
        */
        GuiControl Move, vTab3, % "h" maxTabHeight
        ;guicontrol hide,vTab3
        ttip(maxTabHeight)
        maxTabHeight+=25
        ;gui show,
        GuiControl Choose, vTab3, 1
        gui Tab
        gui add, button,y%maxTabHeight% xp hwndSubmitButton,&Submit
        onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
        GuiControl ParamsGUI:+g,%SubmitButton%, % onSubmit
        gui add, button, yp xp+60 hwndEditConfig, Edit Configuration
        onEditConfig:=ObjBindMethod(this, "EditConfig")
        GuiControl ParamsGUI:+g,%EditConfig%, % onEditConfig
        onEscape:=ObjBindMethod(this,"otGUI_Escape2")
        Hotkey IfWinActive, % "ahk_id " otGUI_
        Hotkey Escape,% onEscape
        guiWidth:=692
        guiHeight:=maxTabHeight+40
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
        ;  }
        if (x!="") && (y!="") {
            gui ParamsGUI:Show,x%x% y%y% w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
        } else {
            gui ParamsGUI:Show,w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
        }
        WinWait % GUIName
        if this.SkipGUI {
            this.SubmitDynamicArguments() ;; auto-submit the GUI
        } Else {
            WinWaitClose % GUIName
        }
        return this
    }
    EditConfig() {
        static
        gui ParamsGUI: Submit, NoHide
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
        static ; global
        gui ParamsGui: Submit
        gui ParamsGui: destroy
        for Parameter,_ in this.Arguments {
            ;@ahk-neko-ignore 1 line; at 4/28/2023, 9:49:42 AM ; https://github.com/CoffeeChaton/vscode-autohotkey-NekoHelp/blob/main/note/code107.md
            parameter:=strreplace(parameter,"-","___")
            k=v%Parameter% ;; i know this is jank, but I can't seem to fix it. just don't touch for now?
            parameter:=strreplace(parameter,"___","-")
            a:=%k%
            this["Arguments",Parameter].Value:=a
        }
        return this
    }
    otGUI_Escape2() {
        static
        gui ParamsGUI: Submit
        gui ParamsGui: destroy
        ID:=0
        this.Error:=this.Errors[ID]
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
