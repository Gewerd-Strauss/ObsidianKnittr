parseA_Args(Args) {
    Object:={}
    for _, pair in Args {
        key:=strsplit(pair,"=",,2).1
            , val:=strsplit(pair,"=",,2).2
        if (Object.HasKey(key)) {
            Object[key]:=[Object[key],val]
        } else {
            Object[key]:=val
        }
    }
    return Object
}
requireA_Args(Args) {
    required:=["format","path"]
    found:=[]
    reqQ:=required.Count()
    for arg, val in Args {
        if (HasVal(required,arg)) {
            if (arg="path") {
                val:=strreplace(val,"""")
                if (!FileExist(val)) {
                    message:="Fatal error: CLI run without providing required argument '" arg "'.`nThis program will exit now."
                    AppError("Fatal argument-error occured", Message, Options := 0, TitlePrefix := A_ThisFunc "()")
                    ExitApp -1
                }
            }
            if (!HasVal(found,arg)) {
                found.push(arg)
            }
        }
    }
    foundQ:=found.Count()
    if (foundQ=reqQ) {
        ttip("success")
        return true
    } else if (foundQ<reqQ) {
        ttip("failure")
        return false
    } else if (foundQ>reqQ) {
        MsgBox % "FATAL: this shouldn't happen, error occured in '" A_ThisFunc "'. 'foundQ'>'reqQ'??"
    }
}
CLI_help() {
    Obj:={Path:"`t`t`t-`t(req): absolute path to the note being processed. The note must lie within an obsidian-Vault, as detected`n`t`t`t`t`t`tby the presence of an ``.obsidian``-folder somewhere above the note's location."
            , format:"`t`t`t-`t(req): key of the output-format used. Output format must be defined in 'DynamicArguments.ini'."
            , FullLog:"`t`t`t-`tNOT TESTED"
            , OHTMLLevel:"`t`t-`tInteger, set to number of levels above the manuscript-LOCATION to implement an OHTML-restrictor."
            , Log:"`t`t`t-`tDD"
            , "quarto::XXXX.YY":"`t`t-`tPass along parameter modifications for parameter 'YY' of quarto-format 'XXXX'. Use quarto's parameter naming-scheme`n`t`t`t`t`t`tExample: ``quarto::html.number-depth=1``"
            , RenderToOutputs:"`t-`tSet to '1' to execute file-compilation via quarto-cli/`rscript`"
            , noMove:"`t-SEt to '1' to convert the note locally and create the '.qmd'-file at the location of the root."
            , LastExecutionDirectory:"`t-`tSet to '1' to process in OHTML-output directory, set to '2' to process in vault-subfolder."}
    name:=script.name
    str=
        (LTRIM
            CLI-Overview for '%name%':
            -h`tPaste this help
            -v`tPaste Version
        )
    for Arg, Explanation in Obj {
        str.="`t`t" Arg  Explanation "`n"
    }
    str.="`n`nPress [Esc] to close the help."
    ttip(str,5)
    while (1) {
        if GetKeyState("Escape") {
            break
        }
    }
    return
}
