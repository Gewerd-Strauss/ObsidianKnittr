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
            regex:="(?<Key>\w+\:)(?<Val>[^|]+)"
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
                            CurrentParam:=matchKey
                            ObjRawSet(This.Arguments,matchKey,{})
                            ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                        }
                        ObjRawSet(This.Arguments[CurrentParam],matchKey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
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
        if InStr(this.type,"::") { ;; start string
            Str:=this.type "(`n" ;; check if format is from a specific package or not
        } else {
            Str:="rmarkdown::" this.type "(`n"  ;; assume rmarkdown-package if not the case
        }
        this._Adjust()
        for Parameter, Value in this.Arguments {
            if (Parameter="toc_depth" && !this.Arguments["toc"].Value) {
                continue
            }
            if (Value.Type="String") && (Value.Value!="") && (Value.Default!="NULL") {
                Value.Value:=DA_Quote(Value.Value)
            }
            if (Parameter="reference_docx") {
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
        Str:=SubStr(Str,1,StrLen(Str)-2)
        Str.=(Instr(Str,"`n")?"`n)":"")
        this.AssembledFormatString:=Str
        return Str
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
            if Value.HasKey(Min) && Value.Min>Value.Value {
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
        gui add, button,hwndSubmitButton,&Submit
        onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
        GuiControl ParamsGUI:+g,%SubmitButton%, % onSubmit
        gui add, button, yp xp+60 hwndEditConfig, Edit Configuration
        onEditConfig:=ObjBindMethod(this, "EditConfig")
        GuiControl ParamsGUI:+g,%EditConfig%, % onEditConfig
        onEscape:=ObjBindMethod(this,"otGUI_Escape2")
        Hotkey IfWinActive, % "ahk_id " otGUI_
        Hotkey Escape,% onEscape
        if (x!="") && (y!="") {
            gui ParamsGUI:Show,x%x% y%y%,% GUIName:=this.GUITitle this.type
        } else {
            gui ParamsGUI:Show,,% GUIName:=this.GUITitle this.type
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
            k=v%Parameter% ;; i know this is jank, but I can't seem to fix it. just don't touch for now?
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
