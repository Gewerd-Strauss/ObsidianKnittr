html:=new ot("html_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\Test\DynamicArguments.ini")
docx:=new ot("word_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\Test\DynamicArguments.ini")
docx:=docx.GenerateGUI()
html:=html.GenerateGUI()
htmlstr:=html.AssembleFormatString() 
docxstr:=docx.AssembleFormatString()
Clipboard:=htmlstr "`n" docxstr
return
pdf:=new ot("pdf_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\INI-Files\DynamicArguments.ini")
docx:=new ot("word_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\INI-Files\DynamicArguments.ini")
Class ot ;; output_type
{
    
    __New(Format:="",ConfigFile:="")
    {
        this.type:=Format
        this.ClassName.= Format ")"
        if FileExist(ConfigFile)
            this.ConfigFile:=ConfigFile
        else
        {
            ID:=-1
            this.Error:=this.Errors[ID].String
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
            this.Error:=this.Errors[ID].String
            MsgBox 0x40031,%  this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        ;ttip(Lines)
        for each, Line in Lines
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
                ObjRawSet(This.Arguments[CurrentParam],matchkey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
                ; This.Arguments.InsertAt([matchKey] matchKey:=matchVal
                p+=StrLen(Match)
                Count++
            }
            /*
                ; if RegExMatch(Line, "(?<Key>\w*)\:(?<Val>[^|:]+)", v)
                ; {
                    
                ; }

                ; Details:=Parameter:=Control:=Options:="" ;; clear if assigned in previous pass
                ; Details:=strsplit(Line,"|")
                ; Parameter:=strsplit(Details.1,":").1
                ; Control:=strsplit(Details.1,":").2
                ; if Instr(Control, ",")
                ; {
                ;     Options:=Strsplit(Control,",").2
                ;     Control:=Strsplit(Control,",").1
                ;     if Instr(Control,":")
                ;         Control:=Strsplit(Control,":").2
                ;     This.Arguments[Trim(Parameter)]:={Trim(Parameter):Trim(Parameter),Type:Details.2,Default:Details.3,String:Details.4,Control:Control,Value:"",Options:Options,Other:Details.6}
                ; }
                ; else
                ; {
                ;     if Instr(Control,":")
                ;         Control:=Strsplit(Control,":").2
                ;     This.Arguments[Trim(Parameter)]:={Trim(Parameter):Trim(Parameter),Type:Details.2,Default:Details.3,String:Details.4,Control:Control,Value:"",Other:Details.6}
                ; }
                ; if Instr("boolean,integer,number",Details.2) ;(Details.2="boolean" || Details.2="number") || (Instr(Details.2,"boolean") || InStr(Details.2,"number"))
                ; {
                ;     DefVal:=This.Arguments[Trim(Parameter),"Default"]+0
                ;     This.Arguments[Trim(Parameter),"Default"]:=This.Arguments[Trim(Parameter),"Default"]+0
                ;     ;This.Arguments[Trim(Parameter),"Value"]:=This.Arguments[Trim(Parameter),"Default"]+0
                ; }
                ; else if (Details.2="float")
                ; {

                ; }
                ; else if (Details.2="string")
                ; {

                ; }
                ; else if (Details.2="valid_path")
                ; {
                ;     this.Arguments[Trim(Parameter)].SearchPath:=strsplit(this.Arguments[Trim(Parameter)].Other,"=").2
                ;     ; This.Arguments[Trim(Parameter),"Value"]:=
                ; }
                ;This.Arguments[Trim(Parameter),"Control"]:=Details.1
            */
        }
        this.AssumeDefaults()
        this._Adjust()
    }
    __Init()
    {
        this.Errors:={ ;; negative errors are hard failures, which will not let the program continue. positive errors are positive, and allow limited continuation. Functionality may be limited 
             -1:{String:"Provided Configfile does not exist:`n`n",EndString:"`n`n---`nExiting Script",Criticality:-100}
             ,+2:{String:"Format not defined.`nCheck your configfile.`n`nReturning default 'outputformat()'",Criticality:20}}
        this.ClassName:="ot ("
        this.GUITitle:="Define output format - "
        this.Version:="0.1.a"
        this.type:=""
        this.ConfigFile:=""
        ObjRawSet(this,"type","")
        ObjRawSet(this,"Arguments",{})
    }
    __Get(Param*)
    {
        instance:=this
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
        return This
    }

    AssembleFormatString()
    {
        /* TODO: method to generate the equivalence of this (exact this format), so I can simply BuildRScriptContents properly.
        Str3=
                    (LTRIM
                    rmarkdown::word_document(
                    toc = %bTOC%,
                    toc_depth = %toc_depth%,
                    number_sections = %bNumberSect%,
                    fig_caption = TRUE,
                    df_print = "default",
                    highlight = "default",
                    reference_docx="%template%",
                    keep_md = FALSE,
                    md_extensions = NULL,
                    pandoc_args = NULL
                    `)
                    )
                    output_type[k]:=Clipboard:=Str3
        */

        Str:="rmarkdown::" this.type "(`n" ;; start string
        this._Adjust()
        for Parameter, Value in this.Arguments
        {
            if (Parameter="toc_depth" && !this.Arguments["toc"].Value) ;|| (Parameter="toc" && !this.Arguments["toc"]Value)
                continue
            if (Value.Type="String") && (Value.Value!="") ;&& (Value.Control!="File")
                Value.Value:=DA_Quote(Value.Value)
            if (Value.Default="NULL") && (Value.Value="")
                Value.Value:="NULL"
            if (Parameter="reference_docx")
            {
                ParamBackup:=Value.Value
                ParamBackup:=Value.Value
                ParamString:=strsplit(Value.Value,"(").2
                ParamString:=Trim(ParamString,"""")
                if SubStr(ParamString,0)=")"
                {
                    tpl_Len:=StrLen(ParamString)-1
                    ParamString:=SubStr(ParamString, 1, tpl_Len)
                }
                ParamString:=StrReplace(ParamString, "\", "/")
                Tail:=SubStr(ParamString,-1)
                Tail2:=SubStr(ParamString,-2)
                Value.Value:=DA_Quote(ParamString)
                if (ParamString="")
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
            }
            Str.= Parameter " = " Value.Value ",`n"
        }
        Tail:=SubStr(Str,-2)
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
            if V.Type="Integer" || V.Type="Number" || V.Type="Boolean"
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
    AssumeDefaults()
    {
        for each, V in this.Arguments
        {
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

    FileSelect(VarName)
    {
        FileSelectFile, Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
        gui, ParamsGUI:default
        SplitPath, % Chosen,,,,ChosenName
        guicontrol,% "ParamsGUI:",v%VarName%, % ChosenName "(" Chosen ")"
    }
    
    GenerateGUI()
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
            MsgBox 0x40031,%  this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
            
        gui, ParamsGUI: new, +AlwaysOnTop -SysMenu -ToolWindow +caption +Border
        gui, font, s8

        for each,V in this.Arguments
        {
            Control:=V.Control
            if (Options="")
                Options:=""
            if (V.Control="Edit")
            {
                gui, ParamsGUI: add, text,, % tmp:=V.String
                ; V.String:=""
                if (V.ctrlOptions="Number") 
                {
                    if (v.Max!="") && (v.Min!="") ;&& (v.HasKey(Max) || v.HasKey(Min))
                    {
                        V.ctrlOptions.= A_Space 
                        Gui, ParamsGUI:Add, Edit
                        gui, ParamsGUI:add, UpDown, %  "h25 w80 Range" v.Min "-" v.Max " vv" each, % v.Default + 0
                        continue
                    }
                }
                gui, ParamsGUI: add, % V.Control, % V.ctrlOptions " vv" each
            }
            else if (V.Control="File")
            {
                gui, ParamsGUI:Add, Text,, % V.String
                gui, ParamsGUI:Add, edit,  % V.ctrlOptions " vv" each " disabled w200", % V.Value
                ; Func:=ObjBindMethod(this, "FileSelect")
                Gui, ParamsGUI:Add, button, hwndbutton, % "Select &File"
                onButton := ObjBindMethod(this, "FileSelect",each)
                GuiControl, ParamsGUI:+g, %button%, % onButton
            }
            else if (V.Control="DDL")
            {
                gui, ParamsGUI:Add, Text,, % V.String
                if Instr(V.ctrlOptions,",") && !Instr(V.ctrlOptions,"|")
                    V.ctrlOptions:=strreplace(V.ctrlOptions,",","|")
                if !Instr(V.ctrlOptions,v.Default)
                    v.ctrlOptions.=((SubStr(v.ctrlOptions,-1)="|")?"":"|") v.Default
                if !Instr(V.ctrlOptions,v.Default "|")
                    v.ctrlOptions:=strreplace(v.ctrlOptions,v.Default,v.Default "|")
                if !Instr(V.ctrlOptions,v.Default "||")
                    v.ctrlOptions:=strreplace(v.ctrlOptions,v.Default,v.Default "|")
                if !Instr(V.ctrlOptions,v.Default "||")
                    v.ctrlOptions:=strreplace(v.ctrlOptions,v.ctrlOptions "|")
                gui, ParamsGUI:add, % V.Control, %  " vv" each, % V.ctrlOptions
            }
            else
                gui, ParamsGUI:add, % V.Control, % V.ctrlOptions " vv" each, % V.String
            if (V.Control="Checkbox")
                guicontrol,% "ParamsGUI:",v%each%, % V.Default

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
        gui, ParamsGUI:Show,,% GUIName:=this.GUITitle this.type
        WinWait, % GUIName
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
        OnMessage(0x44, "OnMsgBox")
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
}

; --uID:4179423054
 ; Metadata:
  ; Snippet: DA_Quote  ;  (v.1)
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
  ;; DA_Quotes a string

 ;;; Example:
  ;;; Var:="Hello World"
  ;;; msgbox, % DA_Quote(Var . " Test")
  ;;; 

 DA_Quote(String)
 	{ ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
 		return """" String """"
 	}


; --uID:4179423054

DA_OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Continue with old
    }
}






m1 := new GMem(0, 20)
m2 := {base: GMem}.__New(0, 30)



class GMem
{
    __New(aFlags, aSize)
    {
        this.ptr := DllCall("GlobalAlloc", "UInt", aFlags, "Ptr", aSize, "Ptr")
        if !this.ptr
            return ""
        MsgBox % "New GMem of " aSize " bytes at address " this.ptr "."
        return this  ; This line can be omitted when using the 'new' operator.
    }

    __Delete()
    {
        MsgBox % "Delete GMem at address " this.ptr "."
        DllCall("GlobalFree", "Ptr", this.ptr)
    }
}
