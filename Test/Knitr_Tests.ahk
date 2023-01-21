Path:="C:\Users\Claudius Main\Desktop\TempTemporal\Source for Word-formatting-Template\index.md"
ret:=ProcessAbstract(Path)
Clipboard:=ret
 msgbox, % ret
ProcessAbstract(NewContents)
{
    if (FileExist(NewContents))
        FileRead NewContents, % NewContents
    Lines:=Strsplit(NewContents,"`r`n")
    , Rebuild:=""
    for index, Line in Lines
    {
        if (st_count(Rebuild,"`n")>1)
        {
            Clipboard:=Rebuild.="`n" Line
            continue
        }
        if (!Instr(Rebuild,"abstract"))
            Rebuild.=((Index=1)?Line:"`n" Line)
        else
            Rebuild.=((SubStr(Line,1,2)="  ")?A_Space LTrim(Line):"`n" Line)
    }
    return Rebuild
}
ProcessTags(NewContents,bRemoveHashTagFromTags)
{
    if (FileExist(NewContents))
        FileRead NewContents, % NewContents
    AlreadyReplaced:=""
    Clipboard:=NewContents
    if Instr(NewContents,"_obsidian_pattern")
    {
        Tags:=Strsplit(NewContents,"tags:").2

        ;; eliminate duplicates
        Lines:=strsplit(Tags,"`r`n")
        Tags:=""
        for ind, Line in Lines
        {
            if SubStr(Line,1,2)="- " && !Instr(Tags,Line)
                Tags.=Line "`r`n"
            if SubStr(Line,1,2)="- "
                OrigTags.=Line "`r`n"
            if SubStr(LIne,1,3)="---"
                break
        }
        if (Tags="")
        {
            Tag:=Trim(Lines[1])
            Needle:="``{_obsidian_pattern_tag_" Tag "}``"
            if bRemoveHashTagFromTags
            {
                NewContents:=Strreplace(NewContents,Needle,Tag)
                if Instr(NewContents,Tag) && !Instr(NewContents,Needle)
                    Tags:=""
            }
            else
            {
                NewContents:=Strreplace(NewContents,Needle,"#" Tag)
                if Instr(NewContents,"#" Tag)
                    Tags:=""
            }
            AlreadyReplaced.=Tag "`n"
        }
        else
        {
            Tags:=Trim(Tags)
            Tags:=Strsplit(Tags,"`r`n")
            for ind,Tag in Tags
            {
                if (SubStr(Tag,1,1)="-")
                    Tags[ind]:=SubStr(Tag,3)
                else
                {
                    Cap:=Tags.Remove(Ind)
                    continue
                }
            }
            for ind, Tag in Tags
            {
                if (Tag="") && !Instr(AlreadyReplaced,Tag)
                    continue
                Needle:="``{_obsidian_pattern_tag_" Tag "}``"
                if bRemoveHashTagFromTags
                {
                    if !Instr(NewContents,Needle)
                        continue
                    NewContents:=Strreplace(NewContents,Needle,Tag)
                    if Instr(NewContents,Tag) && !Instr(NewContents,Needle)
                        Tags[Ind]:=""
                }
                else
                {
                    if !Instr(NewContents,Needle)
                        continue
                    NewContents:=Strreplace(NewContents,Needle,"#" Tag)
                    if Instr(NewContents,"#" Tag)
                        Tags[Ind]:=""
                }
                AlreadyReplaced.=Tag "`n"
            }
            rebuild:="`r`n"
            for ind, Tag in Tags
            {
                if (Tag="")
                    continue
                rebuild.="- " Tag "`r`n"
            }
            ;rebuild.="---"
            Clipboard:=NewContents:=strreplace(NewContents,OrigTags,rebuild)
            Clipboard:=NewContents
            Clipboard:=NewContents:=StrReplace(NewContents,"---`r`n---", "`r`n---`r`n",,1)
            Clipboard:=NewContents:=StrReplace(NewContents,"`r`n`r`n", "`r`n",,1)
        }
    }
    
    return NewContents
}
st_count(string, searchFor="`n")
{
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}
