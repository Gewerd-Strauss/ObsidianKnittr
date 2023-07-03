FileRead String, % "TESTFILEPATH"
String2:=convertToQMD(String,1)
;Validate(String,String2)
return

convertToQMD(String,bRemoveQuartoReferenceTypesFromCrossrefs) {
    String:=convertBookdownToQuartoReferencing(String,bRemoveQuartoReferenceTypesFromCrossrefs)         ;; modify chunk labels in chunks and references to contain their ref type.
    String:=convertDiagrams(String)                                                                     ;; convert graphviz and mermaid codechunk syntax
    String:=moveEquationreferencesToEndofBlock(String)                                                  ;; latex equation reference keys
    String:=fixCitationpathing(String)                                                                  ;; "csl" and "bibliography" frontmatter keys
    return String
}
moveEquationreferencesToEndofBlock(String) {
    ;; fix equation reference keys
    Lines:=strsplit(String,"`n")
    inEquation:=false
    Rebuild:=""
    for _, Line in Lines {
        Trimmed:=Trim(Line)
        if InStr(Trimmed,"$$") && !inEquation { 
            inEquation:=true
        } else if !InStr(Trimmed,"$$") && !inEquation {
            inEquation:=false
            Label:=""
            Rebuild.=Line "`n"
            continue
        } 
        if InStr(Trimmed,"$$") && inEquation && Label!="" { ;; this is the second $$ for this latex block. thus, we now want to redd the label
            Line:=RTrim(Line) A_Space "{#eq-" Label "}"
            Rebuild.=Line "`n"
            inEquation:=false
            continue
        }
        ;; let's find and remove the label.
        if RegexMatch(Line,"i)(?<FullString>\(\\#eq:(?<EQLabel>.*)\))",v)
        {
            inEquation:=true
            Line:=strreplace(Line,vFullString)
            Label:=vEQLabel
        }
        if (inEquation) {
            Rebuild.=Line "`n"

        } else {

        }
    }

    return Rebuild
}
convertBookdownToQuartoReferencing(String,bRemoveQuartoReferenceTypesFromCrossrefs) {

    ;; 1. `\@ref(type:label)` → `@type-label`  → regexmatchall?
    needle:="\\@ref\((?<Type>\w*)\:(?<Label>[^)]*)\)"
    Matches:=RegexMatchAll(String, "im)" needle)
    for _, match in Matches {                                                  ;; star, top
        needle := match[0]
        Type:=match[1]
        Label:=match[2]
        lbl:=Label
        if (Type="tab") {
            if (!InStr(Label, "tbl-")) {
                Label:="tbl-" Label
            }
            Type:="tbl"
        } else {
            if (!InStr(Label,Type "-")) {
                Label:=Type "-" Label

            }
        }
        if bRemoveQuartoReferenceTypesFromCrossrefs {
            String := strreplace(String, needle, "[-@"  Label "]")
        } else {
            String := strreplace(String, needle, "@"  Label)
        }

        ;; 2. tbl-WateringMethodTables →
        String:= strreplace(String,"r " lbl, "r " Label)
    }

    return String
}
convertDiagrams(String) {
    String:=strreplace(String,"```mermaid","```{mermaid}")
    String:=strreplace(String,"```dot","```{dot}")
    return String
}

fixCitationpathing(String) {
    needle1:="mi)(bibliography:(?<match>\N+))"
    needle2:="mi)(csl:(?<match>\N+))"
    if RegexMatch(String,needle1,v) {
        vmatch:=strsplit(vmatch,"`n").1
        String:=strreplace(String,vmatch,A_Space """" Trim(vmatch) """")
        ;String:=strreplace(String,vmatch,A_Space "'" Trim(vmatch) "'")
        ;String:=strreplace(String,vmatch,A_Space  Trim(vmatch) )
    }
    if RegexMatch(String,needle2,v) {
        vmatch:=strsplit(vmatch,"`n").1
        ;String:=strreplace(String,vmatch,A_Space """" Trim(vmatch) """")
        String:=strreplace(String,vmatch,A_Space "'" Trim(vmatch) "'")
        ;String:=strreplace(String,vmatch,A_Space  Trim(vmatch) )
    }
    return String
}
modifyQuartobuildscript(script_contents,RScriptFolder,out) {
    Matches:=RegexMatchAll(script_contents,"iUm)(?<fullchunk>execute_params = (?<yamlpart>(.|\s)+)output_format)") ;; WORKING
    while IsObject(Matches:=RegexMatchAll(Clipboard:=script_contents,"iUm)(execute_params = ((.|\s)+),output_format = ""(.+?)"",""(.+?)""\))")) ;; can't add this here: ,output_format(.+",")))
    {
        if !Matches.Count() { ;; needle no longer work
            break
        }
        yamlnames:=[]
        yaml_fnmod:=[]
        match:=Matches[1]
        fullmatch:=match[0]
        fullchunk:=match[1]
        yamlpart:=match[2]
        a:=match[3]
        b:=match[4]
        c:=match[5]
        d:=match[6]
        replacablepart:=strsplit(fullmatch,"`n`n").1
        yamlPath:=RScriptFolder "/yaml"
        Format:=Trim(Trim(strsplit(b,""",""").1))
        for _, val in out.sel {
            if !InStr(val,"quarto") {
                Continue
            }
            if !Instr(val,format) {
                Continue
            }
            yaml_fnmod.push(out.Outputformats[val]["filenameMod"])
            yamlnames.Push(out.Outputformats[val]["filename"])
            manuscriptname:=out.Outputformats[val]["filename"]
                . out.Outputformats[val]["filenameMod"]
                . "."
                . out.Outputformats[val]["filesuffix"]


        }
        script_contents:=StrReplace(script_contents,replacablepart,"pandoc_args = c(""--metadata-file"",""%YAMLPATH%"")"",output_format = """ Format """,output_file = ""%manuscriptname%"")" )
        yamlcode:= "`n"               "yaml::write_yaml(%yamlpart%,""%yamlPath%"")"
        yamlcode2=
            (LTRIM

                yaml_content <- readLines("`%YAMLPATH`%")
                yaml_content <- stringr::str_replace(yaml_content,": no\"",": FALSE\"")
                yaml_content <- stringr::str_replace(yaml_content,": yes\"",": TRUE\"")
                yaml_content <- stringr::str_replace(yaml_content,": yes",": TRUE")
                yaml_content <- stringr::str_replace(yaml_content,": 'true'",": TRUE")
                yaml_content <- stringr::str_replace(yaml_content,": 'false'",": FALSE")
                yaml_content <- stringr::str_replace(yaml_content,": 'FALSEne'",": FALSE")
                yaml_content <- stringr::str_replace(yaml_content,": no",": FALSE")
                yaml_content <- stringr::str_replace(yaml_content,": FALSEne",": none")
                yaml_content <- stringr::str_replace(yaml_content,"date: FALSEw","date: now")
                writeLines(yaml_content,"`%YAMLPATH`%")
            )
        yamlcode.="`n" yamlcode2
        script_contents:=StrReplace(script_contents,"quarto::quarto_render(",yamlcode "`n`nquarto::quarto_render(",,1 )
        script_contents:=Strreplace(script_contents,"),)",")")
        script_contents:=StrReplace(script_contents,"%YAMLPATH%",yamlPath "_" Format ".yaml")
        script_contents:=StrReplace(script_contents,"%yamlpart%",yamlpart)
        script_contents:=StrReplace(script_contents,"%manuscriptname%",manuscriptname )
        script_contents:=Strreplace(script_contents,"yaml"")"",output","yaml""),output")
    }
    return script_contents
}
