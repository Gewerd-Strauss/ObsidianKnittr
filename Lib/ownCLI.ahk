parseA_Args(Args) {
    Object:={}
    for _, pair in Args {
        key:=strsplit(pair,"=",,2).1
        val:=strsplit(pair,"=",,2).2
        if (Object.HasKey(key)) {
            a:=[Object[key],val]
            Object[key]:=a
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
            if (!HasVal(found,arg)) {
                found.push(arg)
            }
        }
    }
    foundQ:=found.Count()
    if (foundQ=reqQ) {
        MsgBox % "success",,,% 3
        return true
    } else if (foundQ<reqQ) {
        MsgBox % "failure",,,% 3
        return false
    } else if (foundQ>reqQ) {
        MsgBox % "FATAL: this shouldn't happen, error occured in '" A_ThisFunc "'. 'foundQ'>'reqQ'??"
    }
}
CLI_help() {
    Obj:={Path:"`t`t`t-`treq.: absolute path to the note being processed. The note must lie within an obsidian-Vault, as detected by the presence of an ``.obsidian``-folder somewhere above the note's location."
            , format:"`t`t`t-`treq.: key of the output-format used. Output format must be defined in 'DynamicArguments.ini'."
            , FullLog:"`t`t`t-`tNOT TESTED"
            , OHTMLLevel:"`t`t-`tInteger, set to number of levels above the manuscript-LOCATION to implement an OHTML-restrictor."
            , LastExecutionDirectory:"`t-`tSet to '1' to process in OHTML-output directory, set to '2' to process in vault-subfolder."}
    str=
        (LTRIM
            -h`tPaste this help
            -v`tPaste Version

        )
    for Arg, Explanation in Obj {
        str.="`t`t" Arg  Explanation "`n"
    }
    ttip(str,5)
    msgbox % "close when you are finished with the help."
    return
}
