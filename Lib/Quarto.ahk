FileRead String, % "TESTFILEPATH"
String2:=convertToQMD(String,1)
;Validate(String,String2)
return

convertToQMD(String,bRemoveQuartoReferenceTypesFromCrossrefs) {
    String:=convertBookdownToQuartoReferencing(String,bRemoveQuartoReferenceTypesFromCrossrefs)         ;; modify chunk labels in chunks and references to contain their ref type.
    String:=convertDiagrams(String)                                                                     ;; convert graphviz and mermaid codechunk syntax
    String:=moveEquationreferencesToEndofBlock(String)                                                  ;; latex equation reference keys
    String:=moveEquationLabelsUpIntoLatexEquation(String)                                               ;; 
    String:=fixCitationpathing(String)                                                                  ;; "csl" and "bibliography" frontmatter keys
    String:=fixNullFields(String)                                                                       ;; fix null-valued yaml fields
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
                , Label:=""
                , Rebuild.=Line "`n"
            continue
        } 
        if InStr(Trimmed,"$$") && inEquation && Label!="" { ;; this is the second $$ for this latex block. thus, we now want to redd the label
            Line:=RTrim(Line) A_Space "{#eq-" Label "}"
                , Rebuild.=Line "`n"
                , inEquation:=false
            continue
        }
        ;; let's find and remove the label.
        if RegexMatch(Line,"i)(?<FullString>\(\\#eq:(?<EQLabel>.*)\))",v)
        {
            inEquation:=true
                , Line:=strreplace(Line,vFullString)
                , Label:=vEQLabel
        }
        if (inEquation) {
            Rebuild.=Line "`n"
        } else {

        }
    }

    return Rebuild
}
moveEquationLabelsUpIntoLatexEquation(String) {
    needle:="\$+\s*\{#eq"
    Matches:=RegexMatchAll(String, "im)" needle)
    for _, match in Matches {                                                  ;; star, top
        needle := match[0]
            , String:=strreplace(String,needle,"$$ {#eq",,1)
    }
    return String
}
convertBookdownToQuartoReferencing(String,bRemoveQuartoReferenceTypesFromCrossrefs) {

    ;; 1. `\@ref(type:label)` → `@type-label`  → regexmatchall?
    needle:="\\@ref\((?<Type>\w*)\:(?<Label>[^)]*)\)"
    Matches:=RegexMatchAll(String, "im)" needle)
    for _, match in Matches {                                                  ;; star, top
        needle := match[0]
            , Type:=match[1]
            , Label:=match[2]
            , lbl:=Label
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

quartopurgeTags(String) {
    return String
    Lines:=strsplit(String,"`n")
    for each, line in Lines {
        if (InStr(line,"tags:")) {
            if (strLen(trim(line))>5) {
                Lines[each]:="tags: [" strreplace(line,"tags:") "]"
            }
        }
    }
    return String
}
fixCitationpathing(String) {
    needle1:="mi)(bibliography:(?<match>\N+))"
    if RegexMatch(String,needle1,v) {
        vmatch:=strsplit(vmatch,"`n").1
        String:=strreplace(String,vmatch,A_Space  Trim(vmatch) )
    }
    needle2:="mi)(csl:(?<match>\N+))"
    if RegexMatch(String,needle2,v) {
        vmatch:=strsplit(vmatch,"`n").1
        String:=strreplace(String,vmatch,A_Space "'" Trim(vmatch) "'")
    }
    return String
}
modifyQuartobuildscript(script_contents,RScriptFolder,out) {
    Matches:=RegexMatchAll(script_contents,"iUm)(?<fullchunk>execute_params = (?<yamlpart>(.|\s)+)output_format)") ;; WORKING
    while IsObject(Matches:=RegexMatchAll(script_contents,"iUm)(execute_params = ((.|\s)+),output_format = ""(.+?)"",""(.+?)""\))")) ;; can't add this here: ,output_format(.+",")))
    {
        if !Matches.Count() { ;; needle no longer work
            break
        }
        yamlnames:=[]
            , yaml_fnmod:=[]
            , match:=Matches[1]
            , fullmatch:=match[0]
            , yamlpart:=match[2]
            , b:=match[4]
            , replacablepart:=strsplit(fullmatch,"`n`n").1
            , yamlPath:=RScriptFolder "/yaml"
            , Format:=Trim(Trim(strsplit(b,""",""").1))
        for _, val in out.sel {
            if !InStr(val,"quarto") {
                Continue
            }
            if !Instr(val,format) {
                Continue
            }
            yaml_fnmod.push(out.Outputformats[val]["filenameMod"])
                , yamlnames.Push(out.Outputformats[val]["filename"])
                , manuscriptname:=out.Outputformats[val]["filename"]
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
            , script_contents:=StrReplace(script_contents,"quarto::quarto_render(",yamlcode "`n`nquarto::quarto_render(",,1 )
            , script_contents:=Strreplace(script_contents,"),)",")")
            , script_contents:=StrReplace(script_contents,"%YAMLPATH%",yamlPath "_" Format ".yaml")
            , script_contents:=StrReplace(script_contents,"%yamlpart%",yamlpart)
            , script_contents:=StrReplace(script_contents,"%manuscriptname%",manuscriptname )
            , script_contents:=Strreplace(script_contents,"yaml"")"",output","yaml""),output")
    }
    return script_contents
}


quartogetVersion() {
    if quarto_check().1 {
        GetStdStreams_WithInput("quarto -V",,out)
        out:=RegexReplace(out,"\s+")
    } else {
        out:="<not found. Is Quarto Installed?>"
    }
    return out
}
quarto_check() {
    static quarto_on_path:=false
    static out:=""
    if !quarto_on_path {
        GetStdStreams_WithInput("where quarto.exe",,out)
            , GetStdStreams_WithInput("where quarto.cmd",,out2)
            , GetStdStreams_WithInput("where quarto.js",,out3)
            , out:=strreplace(out,"`n")
            , out2:=strreplace(out2,"`n")
        if (!FileExist(out) || !FileExist(out2)) {
            quarto_on_path:=false
        } else {
            quarto_on_path:=true
        }
    }
    return [quarto_on_path,out]
}
write_quarto_yaml(output_type,OutDir,yaml_file) {
    yaml_path:=OutDir "\" yaml_file
        , String:=""
    for Parameter, Value in output_type.Arguments {
        Pair:= Parameter ": " strreplace(Value.Value,"""")
            , String:=String "`n" Pair
    }
    String:=Strreplace(String,": no""",": FALSE""")
        , String:=Strreplace(String,": yes""",": TRUE""")
        , String:=Strreplace(String,": yes",": TRUE")
        , String:=Strreplace(String,": 'true'",": TRUE")
        , String:=Strreplace(String,": 'false'",": FALSE")
        , String:=Strreplace(String,": 'FALSEne'",": FALSE")
        , String:=Strreplace(String,": no",": FALSE")
        , String:=Strreplace(String,": FALSEne",": none")
        , String:=Strreplace(String,"date: FALSEw","date: now")
        , String:=Strreplace(String,": true`n",": TRUE`n")
        , String:=Strreplace(String,": false`n",": FALSE`n")
    writeFile(yaml_path,String,Encoding:="utf-8",Flags:=0x2,bSafeOverwrite:=true)
    return String
}
cleanupIntermediatequartoFiles(guiOut) {
    FilesArr:=guiOut.removableintermediates
        , failed:=[]
    loop, 4 {
        type:=A_Index
        for _, file in FilesArr {
            if (type=1) { ;; folders
                if (InStr(FileExist(file),"D")) {
                    FileRemoveDir % file, true
                    if (FileExist(file)) {
                        failed.push(file)
                    }
                }
            } else if (type=2) { ;; *
                if (InStr(file,"*")) {
                    Loop, Files, % file, F
                    {
                        msgbox % A_LoopFileFullPath
                        FileDelete % A_LoopFileFullPath

                    }
                }
            } else if (type=3) { ;; scripts r/ahk/cmd

            } else if (type=4) { ;; compilation assets (bib, yaml)

            }
            if (fileExist(file)) {
                FileDelete % file
                if (FileExist(file)) {
                    failed.push(file)
                }
            }
        }
    }
    return failed
}
collectQuartoIntermediates(guiOut,CLIArgs) {

    purgeable_names:=["%root%\index.md"
            ,"%root%\not_created.md"]
        , removable_inputsuffixes:={}
    for _, suffix in guiOut.inputsuffixes { ;; check which filetypes of `index\.(<fileending>?\w*)` are required by the formats given, then remove all types that aren't.
        removable_inputsuffixes[suffix]:=true
    }
    for __,inputsuffix in guiOut.inputsuffixes {
        keep_suffix:=false
        for _, object in guiOut.Outputformats {
            if (object.inputsuffix=inputsuffix) {
                keep_suffix:=true
                break
            } else {
                continue
            }

        }
        if (keep_suffix) {
            continue
        } else {
            if (!HasVal(purgeable_names,"`%root`%\index." inputsuffix)) {
                purgeable_names.push("`%root`%\index." inputsuffix)
            }
        }
    }

    /*
    ;;??:
    index_files | required for r-execution, so... no
    index_cache | required for r-execution, so... no
    build.+\.cmd

    ;;intermediates:
    index.rmd   | only if rmd is not required
    index.md
    %filename%_vault.md
    .rhistory

    ;;to remove:
    manuscriptdir\*.cmd
    manuscriptdir\*.ahk
    manuscriptdir\build.r
    manuscriptdir\manuscriptname\


    ;; default - level 1
    ;; not recommended - level 2
    %manuscriptdir%\index_cache
    %manuscriptdir%\index_files

    ;; really not recommended - level 3
    %manuscriptdir%\grateful-refs.bib
    %manuscriptdir%\*.yaml
    */

    /*
    HACK: I have no idea why this assignment to `directory` is a conditional, so it currently just does the same either way. 
    I am typing this in the hope that I review this when I find out that something's wrong


    Follow-up question: Why am I not cleaning guiOut.Settings.ExecutionDirectory? Especially in case of !cliargs.noMove, this should be more accurate than guiOut.manuscriptdir
    */
    directory:=(CLIArgs.noMove?guiOut.manuscriptdir:guiOut.manuscriptdir) 
    purgeable_names.push(directory "\*.cmd")
    purgeable_names.push(directory "\*.ahk")
    purgeable_names.push(directory "\build.r")
    purgeable_names.push(directory "\" guiOut.manuscriptname "\")
    if (CLIArgs.HasKey("IntermediatesRemovalLevel")) {
        if (CLIArgs.IntermediatesRemovalLevel>1) {
            purgeable_names.push(directory "\index_cache")
            purgeable_names.push(directory "\index_files")
        }
        if (CLIArgs.IntermediatesRemovalLevel>2) {
            purgeable_names.push(directory "\grateful-refs.bib")
            purgeable_names.push(directory "\*.yaml")
        }
    }

    ; if (guiOut.HasKey("intermediates")) {
    ; currentIntermediates:=guiOut.intermediates
    ; } else {
    ; 
    ; }

    return purgeable_names
}
