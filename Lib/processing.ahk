convertMDToRMD(md_Path,notename) {
    OldName:=md_Path "\" notename ".md"
        , NewName:=md_Path "\" notename ".rmd"
    FileCopy % OldName, % NewName, true
    return NewName
}
processAbstract(Contents) {
    if (FileExist(Contents)) {
        FileRead Contents, % Contents
    }
    Lines:=Strsplit(Contents,"`r`n")
        , Rebuild:=""
    for index, Line in Lines
    {
        if (st_count(Rebuild,"`n")>1) {
            Rebuild.="`n" Line
            continue
        }
        if (!Instr(Rebuild,"abstract")) {
            Rebuild.=((index=1)?Line:"`n" Line)
        } else {
            Rebuild.=((SubStr(Line,1,2)=" ")?A_Space LTrim(Line):"`n" Line)
        }
    }
    return Rebuild
}
processTags(Contents,bRemoveHashTagFromTags) {
    if (FileExist(Contents)) {
        FileRead Contents, % Contents
    }
    AlreadyReplaced:=""
    if Instr(Contents,"_obsidian_pattern") {
        Tags:=Strsplit(Contents,"tags:").2
        ;; eliminate duplicates
        Lines:=strsplit(Tags,"`r`n")
        Tags:=""
        for _, Line in Lines {
            if SubStr(Line,1,2)="- " && !Instr(Tags,Line) {
                Tags.=Line "`r`n"
            }
            if SubStr(Line,1,2)="- " {
                OrigTags.=Line "`r`n"
            }
            if SubStr(Line,1,3)="---" {
                break
            }
        }
        if (Tags="") {
            Tag:=Trim(Lines[1])
            Needle:="``{_obsidian_pattern_tag_" Tag "}``"
            if bRemoveHashTagFromTags {
                Contents:=Strreplace(Contents,Needle,Tag)
                if Instr(Contents,Tag) && !Instr(Contents,Needle) {
                    Tags:=""
                }
            } else {
                Contents:=Strreplace(Contents,Needle,"#" Tag)
                if Instr(Contents,"#" Tag) {
                    Tags:=""
                }
            }
            AlreadyReplaced.=Tag "`n"
        } else {
            Tags:=Trim(Tags)
            Tags:=Strsplit(Tags,"`r`n")
            for ind,Tag in Tags {
                if (SubStr(Tag,1,1)="-") {
                    Tags[ind]:=SubStr(Tag,3)
                }
            }

            for ind, Tag in Tags
            {
                loop, Parse, % script.config.Config.obsidianTagEndChars
                {
                    Tags[ind]:=(InStr(Tags[ind],A_LoopField)?StrSplit(Tags[ind],A_LoopField).1:Tags[ind])
                }
            }
            for ind, Tag in Tags {
                if (Tag="") && !Instr(AlreadyReplaced,Tag) {
                    continue
                }
                Needle:="``{_obsidian_pattern_tag_" Tag "}``"
                if bRemoveHashTagFromTags {
                    if !Instr(Contents,Needle) {
                        continue
                    }
                    Contents:=Strreplace(Contents,Needle,Tag)
                    if Instr(Contents,Tag) && !Instr(Contents,Needle) {
                        Tags[ind]:=""
                    }
                } else {
                    if !Instr(Contents,Needle) {
                        continue
                    }
                    Contents:=Strreplace(Contents,Needle,"#" Tag)
                    if Instr(Contents,"#" Tag) {
                        Tags[ind]:=""
                    }
                }
                AlreadyReplaced.=Tag "`n"
            }
            rebuild:="`r`n"
            for ind, Tag in Tags {
                if (Tag="") {
                    continue
                }
                rebuild.="- " Tag "`r`n"
            }
            ;rebuild.="---"
            Contents:=strreplace(Contents,OrigTags,rebuild)
                , Contents:=StrReplace(Contents,"---`r`n---", "`r`n---`r`n",,1)
                , Contents:=StrReplace(Contents,"`r`n`r`n", "`r`n",,1)
        }
        Matches:=RegexMatchAll(Contents,"(?<IDStart>\{_obsidian_pattern_tag_)(?<Tag>.+)(?<IDEnd>}`)")
        for _, match in Matches {
            _match:=match[0]
                , Contents:=strreplace(Contents,"``" _match "``",(bRemoveHashTagFromTags?"":"#") match[2])
        }
    }
    return Contents
}
