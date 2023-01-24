Word_Document_Params:=new ot("word_document","D:\Dokumente neu\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\Finished\ObsidianScripts\Test\DynamicArguments.ini")
Word_Document_Params:=GenerateGUI(Word_Document_Params)
Word_Document_Params:=Word_Document_Params.Adjust()
; m(Word_Document_Params)
return
Class ot
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
            if (SubStr(Trim(Line),1,1)=";")
                continue
            Details:=strsplit(Line,"|")
            Parameter:=strsplit(Details.1,":").1
            Control:=strsplit(Details.1,":").2
            if Instr(Control, ",")
            {
                Options:=Strsplit(Control,",").2
                Control:=Strsplit(Control,",").1
                if Instr(Control,":")
                    Control:=Strsplit(Control,":").2
                This.Arguments[Trim(Parameter)]:={Trim(Parameter):Trim(Parameter),Type:Details.2,Default:Details.3,String:Details.4,Control:Control,Value:"",Options:Options,Other:Details.6}
            }
            else
            {
                if Instr(Control,":")
                    Control:=Strsplit(Control,":").2
                This.Arguments[Trim(Parameter)]:={Trim(Parameter):Trim(Parameter),Type:Details.2,Default:Details.3,String:Details.4,Control:Control,Value:"",Other:Details.6}
            }
            if Instr("boolean,integer,number",Details.2) ;(Details.2="boolean" || Details.2="number") || (Instr(Details.2,"boolean") || InStr(Details.2,"number"))
            {
                DefVal:=This.Arguments[Trim(Parameter),"Default"]+0
                This.Arguments[Trim(Parameter),"Default"]:=This.Arguments[Trim(Parameter),"Default"]+0
                This.Arguments[Trim(Parameter),"Value"]:=This.Arguments[Trim(Parameter),"Default"]+0
            }
            else if (Details.2="float")
            {

            }
            else if (Details.2="string")
            {

            }
            ;This.Arguments[Trim(Parameter),"Control"]:=Details.1
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
    Adjust()
    {
        This.AdjustBools()
        This.AdjustMinMax()
        return This
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
    __Init()
    {
        ObjRawSet(this,"type","")
        ObjRawSet(this,"Arguments",[])
        
    }
}
GenerateGUI(Format)
{
    static
    gui, ParamsGUI: new,

    for each,V in Format.Arguments
    {
        Control:=V.Control
        if (Options="")
            Options:=""
        if (Control="Edit")
        {
            gui, ParamsGUI: add, text,, % tmp:=V.String
            V.String:=""
        }
        gui, ParamsGUI:add, % Control, % Options " vv" each, % V.String
        if (Control="Edit")
        {
            V.String:=tmp
        }
    }
    gui, add, button, gSubmitDynamicArguments,Submit
    gui, ParamsGUI:Show,, Dynamic Arguments
    WinWait, Dynamic Arguments
    WinWaitClose, Dynamic Arguments
    for each, V in Format.Arguments
    {
        value:=v%each%
        Format.Arguments[each,"Value"]:=v%each%
    }
    return Format
    
}

SubmitDynamicArguments()
{
    gui, ParamsGui: Submit
    return
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