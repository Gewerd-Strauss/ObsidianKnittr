Class ot ;; output_type
{
    
    __New(Format:="",ConfigFile:="",DDL_ParamDelimiter:="-<>-",SkipGUI:=FALSE)
    {
        this.type:=Format
        this.ClassName.= Format ")"
        this.DDL_ParamDelimiter:=DDL_ParamDelimiter
        this.SkipGUI:=SkipGUI
        if FileExist(ConfigFile)
            this.ConfigFile:=ConfigFile
        else
        {
            ID:=-1
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,%  this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'") "'" ConfigFile "'" (this.Errors[ID].HasKey("EndString")?this.Errors[ID].EndString:"Fatal: Undefined Error with ID '" ID "'")
            ExitApp
            return
        }

        FileRead, Text, % ConfigFile
        Lines:=strsplit(Text,Format "`r`n").2
        Lines:=strsplit(Lines,"`r`n`r`n").1
        Lines:=strsplit(Lines,"`r`n")
        if !Lines.Count()
        {
            this.Result:=this.type:=Format "()"
            ID:=+2
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,%  this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        ;ttip(Lines)
        for _, Line in Lines
        {
            Count:=1
            p := 1
            regex:="(?<Key>\w+\:)(?<Val>[^|]+)"
            
            if (SubStr(Trim(Line),1,1)=";")
                continue
            while (p := RegExMatch(Line, regex, match, p)) {
                ; do stuff
                matchKey:=SubStr(matchKey,1,StrLen(matchKey)-1) ;; remove the doublepoint.
                if (Count<2) ;; initiate Parameter-Object
                {
                    CurrentParam:=matchKey
                    ObjRawSet(This.Arguments,matchKey,{})
                    ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                }
                ObjRawSet(This.Arguments[CurrentParam],matchKey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
                ; This.Arguments.InsertAt([matchKey] matchKey:=matchVal
                p+=StrLen(Match)
                Count++
            }
        }
        this.AssumeDefaults()
        this._Adjust()
    }
    __Init()
    {
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
    __Get(Param*)
    {
        ret:={}
        for _,key in Param
        {
         ret[key]:=this.Arguments[key].Value
        }
        return ret
    }
    _Adjust()
    {
        This.AdjustMinMax()
        This.AdjustDDLs()
        This.AdjustBools()
        This.AdjustIntegers()
        This.AdjustNulls()
        return This
    }

    AssembleFormatString()
    {

        Str:="rmarkdown::" this.type "(`n" ;; start string
        this._Adjust()
        for Parameter, Value in this.Arguments
        {
            if (Parameter="toc_depth" && !this.Arguments["toc"].Value) ;|| (Parameter="toc" && !this.Arguments["toc"]Value)
                continue
            if (Value.Type="String") && (Value.Value!="") && (Value.Default!="NULL")
                Value.Value:=DA_Quote(Value.Value)
            if (Parameter="reference_docx")
            {
                ParamBackup:=Value.Value
                if Instr(Value.Value,this.DDL_ParamDelimiter)
                    ParamString:=strsplit(Value.Value,this.DDL_ParamDelimiter).2
                else
                    ParamString:=Value.Value
                if Instr(ParamString,"(")
                {
                    ParamString:=strsplit(ParamString,"(").2
                    ParamString:=Trim(ParamString,"""")
                    if SubStr(ParamString,0)=")"
                    {
                        tpl_Len:=StrLen(ParamString)-1
                        ParamString:=SubStr(ParamString, 1, tpl_Len)
                    }
                }
                ParamString:=StrReplace(ParamString, "\", "/")
                Value.Value:=DA_Quote(ParamString)
                if (ParamString="")
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                if Instr(ParamBackup,this.DDL_ParamDelimiter)
                    ParamBackup:=Trim(StrSplit(ParamBackup, this.DDL_ParamDelimiter).2)
                if !FileExist(Value.Value) && !FileExist(strreplace(ParamBackup,"\","/"))
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                if !FileExist(Trim(Value.Value,"""")) && !FileExist(strreplace(ParamBackup,"\","/"))
                {
                    MsgBox 0x40031, % "output_type: " this.type " - faulty reference_docx", % "The given path to the reference docx-file`n'" Value.Value  "'`ndoes not exist. Returning."
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
    AdjustDDLs()
    {
        for each, V in this.Arguments
        {
            if (V.Control!="DDL") && (V.Control!="DropDownList")
                continue
        }
    }
    AdjustBools()
    {
        for each, V in this.Arguments
        {
            if (V.Type="Integer" || V.Type="Number" || V.Type="Boolean")
                V.Value:=V.Value+0
            if (V.Type="boolean")
                V.Value:=(V.Value?"TRUE":"FALSE")
        }
    }
    AdjustIntegers()
    {
        for each, V in this.Arguments
        {
            if (V.Type="Integer")
                V.Value:=Floor(V.Value)
        }
    }
    AdjustMinMax()
    {
        for each, V in this.Arguments
        {
            if RegexMatch(V.Other,"Max\:(?<Max>\d*)",v_)
                V.Max:=v_Max+0
            if RegexMatch(V.Other,"Min\:(?<Min>\d*)",v_)
                V.Min:=v_Min+0
                if V.HasKey("Max")
                    V.Value:=V.Max+0
            if V.HasKey(Min) && V.Min>V.Value
                V.Value:=V.Min+0
        }
    }
    AdjustNulls()
    {
        for each, V in this.Arguments
        {
            if V.Value="NULL"
                V.Value:=strreplace(V.Value,"""")
        }
    }
    AssumeDefaults()
    {
        for each, V in this.Arguments
        {
            if V.HasKey("SearchPath")
                V.SearchPath:=strreplace(V.SearchPath,"""","")
            V.String:=strreplace(V.String,"""","")
            if (V.Type="String")
                V.Default:=strreplace(V.Default,"""","")
            if (V.Value="")
            {
                if  (V.Control="File")
                {
                    if !FileExist(V.SearchPath V.Default)
                        MsgBox 0x40031, % "output_type: " this.type, % "The default File`n'" V.SearchPath V.Default "'`ndoes not exist. No default set."
                    else
                        V.Value:=V.SearchPath V.Default
                }
                else
                    V.Value:=V.Default
            }
        }
    }

    ChooseFile(VarName)
    {
        FileSelectFile, Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
        gui, ParamsGUI:default
        SplitPath, % Chosen,,,,ChosenName
        if (Chosen!="")
            guicontrol,% "ParamsGUI:",v%VarName%, % ChosenName A_Space this.DDL_ParamDelimiter A_Space Chosen
    }

    OpenFileSelectionFolder(Path)
    {
        SplitPath, % Path,, OutDir
        run, % OutDir
    }

    GenerateGUI(x:="",y:="")
    {
        ;static
        global
        ; if this.Has
        gui, ParamsGUI: destroy
        if this.HasKey("Error") 
        {
            ID:=strsplit(this.Error,A_Space).2
            if !(SubStr(ID,1,1)="-")
                return this
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }

        gui, ParamsGUI: new, +AlwaysOnTop -SysMenu -ToolWindow +caption +Border +LabelotGUI_ +hwndotGUI_
        gui, font, s8

        for each,argument in this.Arguments
        {
            Control:=argument.Control
            if (Options="")
                Options:=""
            if (argument.Control="Edit")
            {
                gui, ParamsGUI: add, text,, % argument.String
                if (argument.ctrlOptions="Number")
                {
                    if (argument.Max!="") && (argument.Min!="")
                    {
                        argument.ctrlOptions.= A_Space
                        Gui, ParamsGUI:Add, Edit
                        gui, ParamsGUI:add, UpDown, % "h25 w80 Range" argument.Min "-" argument.Max " vv" each, % argument.Default + 0
                        continue
                    }
                }
                if !RegexMatch(argument.ctrlOptions,"w\d*")
                    argument.ctrlOptions.= " w120"
                gui, ParamsGUI: add, % argument.Control, % argument.ctrlOptions " vv" each, % (argument.Value="NULL"?:argument.Value)
            }
            else if (argument.Control="File")
            {
                gui, ParamsGUI:Add, Text,, % argument.String
                gui, ParamsGUI:Add, edit, % argument.ctrlOptions " vv" each " disabled w200", % argument.Value
                Gui, ParamsGUI:Add, button, hwndSelectFile, % "Select &File"
                gui, ParamsGUI:add, button, yp xp+77 hwndOpenFileSelectionFolder, % "Open File Selection Folder"
                onOpenFileSelectionFolder:=ObjBindMethod(this, "OpenFileSelectionFolder", argument.SearchPath)
                onSelectFile := ObjBindMethod(this, "ChooseFile",each)
                GuiControl, ParamsGUI:+g, %SelectFile%, % onSelectFile
                GuiControl, ParamsGUI:+g, %OpenFileSelectionFolder%, % onOpenFileSelectionFolder
                gui, ParamsGUI:add,text, w0 h0 yp+20 xp-77
            }
            else if (argument.Control="DDL")
            {
                gui, ParamsGUI:Add, Text,, % argument.String
                if Instr(argument.ctrlOptions,",") && !Instr(argument.ctrlOptions,"|")
                    argument.ctrlOptions:=strreplace(argument.ctrlOptions,",","|")
                if !Instr(argument.ctrlOptions,argument.Default)
                    argument.ctrlOptions.=((SubStr(argument.ctrlOptions,-1)="|")?"":"|") argument.Default
                if !Instr(argument.ctrlOptions,argument.Default "|")
                    argument.ctrlOptions:=strreplace(argument.ctrlOptions,argument.Default,argument.Default "|")
                if !Instr(argument.ctrlOptions,argument.Default "||")
                    argument.ctrlOptions:=strreplace(argument.ctrlOptions,argument.Default,argument.Default "|")
                if !Instr(argument.ctrlOptions,argument.Default "||")
                    argument.ctrlOptions:=strreplace(argument.ctrlOptions,argument.ctrlOptions "|")
                gui, ParamsGUI:add, % argument.Control, % " vv" each, % argument.ctrlOptions
            }
            else
                gui, ParamsGUI:add, % argument.Control, % argument.ctrlOptions " vv" each, % argument.String
            if (argument.Control="Checkbox")
                ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:49:09 AM ; case sensitivity
                guicontrol,% "ParamsGUI:",v%each%, % argument.Default

            if (Control="Edit")
            {
                ; V.String:=tmp
            }
        }
        gui, add, button,hwndSubmitButton,&Submit
        onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
        GuiControl, ParamsGUI:+g,%SubmitButton%, % onSubmit
        gui, add, button, yp xp+60 hwndEditConfig, Edit Configuration
        onEditConfig:=ObjBindMethod(this, "EditConfig")
        GuiControl, ParamsGUI:+g,%EditConfig%, % onEditConfig
        onEscape:=ObjBindMethod(this,"otGUI_Escape2")
        Hotkey, IfWinActive, % "ahk_id " otGUI_
        Hotkey, Escape,% onEscape
        if (x!="") && (y!="")
            gui, ParamsGUI:Show,x%x% y%y%,% GUIName:=this.GUITitle this.type
        else
            gui, ParamsGUI:Show,,% GUIName:=this.GUITitle this.type
        WinWait, % GUIName
        if this.SkipGUI
            this.SubmitDynamicArguments() ;; auto-submit the GUI
        Else
            WinWaitClose, % GUIName
        return this
    }
    EditConfig()
    {
        static
        gui, ParamsGUI: Submit, NoHide
        RunWait, % this.ConfigFile,,,PID
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
    SubmitDynamicArguments()
    {
        static ; global
        gui, ParamsGui: Submit
        gui, ParamsGui: destroy
        for each,V in this.Arguments
        {
            k=v%each%
            a:=%k%
            this["Arguments",each].Value:= a
        }
        return this
    }
    otGUI_Escape2()
    {
        static
        gui, ParamsGUI: Submit
        gui, ParamsGui: destroy
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
DA_Quote(String)
{ ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
    return """" String """"
}
; #endregion:Code

; #endregion:DA_Quote (4179423054)

DA_OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Continue with old
    }
}
