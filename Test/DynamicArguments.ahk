Word_Document_Params:=new ot("word_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\Test\DynamicArguments.ini")
; Word_Document_Params:=Word_Document_Params._Adjust()
Word_Document_Params:=Word_Document_Params.GenerateGUI()
m(Word_Document_Params.A_Toc,Word_Document_Params.a_reference_docx)
; m(Word_Document_Params)
return
Class ot ;; output_type
{
    __New(Format:="",ConfigFile:="")
    {
        FileRead, Text, % ConfigFile
        this.type:=Format
        Lines:=strsplit(Text,Format "`r`n").2
        Lines:=strsplit(Lines,"`r`n`r`n").1
        Lines:=strsplit(Lines,"`r`n")
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
                matchKey:=SubStr(matchKey,1,StrLen(matchKey)-1)
                if (Count<2)
                {
                    CurrentParam:=matchKey
                    ObjRawSet(This.Arguments,matchKey,{})
                    ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                }
                ObjRawSet(This.Arguments[CurrentParam],matchkey,matchVal)

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
        this._Adjust()
        this.AssumeDefaults()
    }
    __Init()
    {
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
        This.AdjustBools()
        This.AdjustMinMax()
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
            if (V.Value="")
            {
                if  (V.Control="File")
                {
                    V.SearchPath:=strreplace(V.SearchPath,"""","")
                    if !FileExist(V.SearchPath V.Default)
                        MsgBox 0x40040, % "output_type: " this.type, % "The default File`n'" V.SearchPath V.Default "'`ndoes not exist. No default set."
                    else
                        V.Value:=V.SearchPath V.Default
                }
                else
                    V.Value:=V.Default
            }
            V.String:=strreplace(V.String,"""","")
        }
    }
    FileSelect(VarName)
    {
        
        FileSelectFile, Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
    }
    
    GenerateGUI()
    {
        static
        gui, ParamsGUI: new,

        for each,V in this.Arguments
        {
            Control:=V.Control
            if (Options="")
                Options:=""
            if (V.Control="Edit")
            {
                gui, ParamsGUI: add, text,, % tmp:=V.String
                ; V.String:=""
                gui, ParamsGUI: add, % V.Control, % V.ctrlOptions " vv" each
            }
            else if (V.Control="File")
            {
                gui, ParamsGUI:Add, Text,, % V.String
                ; Func:=ObjBindMethod(this, "FileSelect")
                Gui, ParamsGUI:Add, button, hwndbutton, % "Select File"
                onButton := ObjBindMethod(this, "FileSelect",each)
                GuiControl, ParamsGUI:+g, %button%, % onButton
            }
            else
                gui, ParamsGUI:add, % V.Control, % V.ctrlOptions " vv" each, % V.String
                ; gui, ParamsGUI:add, % Control, % Options " vv" each, % V.String

            if (Control="Edit")
            {
                ; V.String:=tmp
            }
        }
        gui, add, button,hwndSubmitButton,Submit
        onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
        GuiControl, ParamsGUI:+g,%SubmitButton%, % onSubmit
        gui, ParamsGUI:Show,, Dynamic Arguments
        WinWait, Dynamic Arguments
        WinWaitClose, Dynamic Arguments
        ; for each, V in this.Arguments
        ; {
        ;     value:=v%each%
        ;     this.Arguments[each,"Value"]:=v%each%
        ; }
        return this
    }
    SubmitDynamicArguments()
    {
        gui, ParamsGui: Submit
        return this
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