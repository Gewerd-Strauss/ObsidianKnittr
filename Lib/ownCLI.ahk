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
processCLIFlags(Byref Args) {
    if (Args.HasKey("--noMove")) {
        Args.noMove:=1
    } else {
        Args.noMove:=0
    }
    if (Args.HasKey("--noOKLog")) { ;; TODO: implement disabling the executionlogging via assignment to members of class EL (e.g. `EL.XX:=YYY`)
        Args.noOKLog:=1
    } else {
        Args.noOKLog:=0
    }
    if (Args.HasKey("--noRender")) {
        Args.RenderToOutputs:=0
    } else { ;; default
        if (!Args.HasKey("RenderToOutputs")) {
            Args.RenderToOutputs:=1
        }
    }

    ;; OHTML
    if (Args.HasKey("--OHTML.TrimErrors")) {
        Args.RemoveObsidianHTMLErrors:=1
    } else {
        Args.RemoveObsidianHTMLErrors:=0
    }
    if (Args.HasKey("--OHTML.Verbose")) {
        Args.Verbose:=1
    } else {
        Args.Verbose:=0
    }
    if (Args.HasKey("--OHTML.UseCustomFork")) {
        Args.UseCustomFork:=1
    } else {
        Args.UseCustomFork:=0
    }
    if (Args.HasKey("--OHTML.Convert")) {
        Args.Convert:=1
    } else if (Args.HasKey("--OHTML.Run")) {
        Args.Convert:=0
    } else { ;; if verb is not specified, default to convert.
        Args.Convert:=1
    }
    if (Args.HasKey("--SourceNameIndex")) { ;; control if the resulting md/rmd/qmd-file should have name %manuscriptname% or "index". Default: "index"
        Args.SourceNameIndex:=0
    } else {
        Args.SourceNameIndex:=1
    }
    if (!Args.HasKey("--noIntermediates")) {
        Args.noIntermediates:=0
    } else {
        Args.noIntermediates:=1
    }
}
processCLIArgs(ByRef Args) {
    if (!Args.HasKey("LastExecutionDirectory")) {
        Args.LastExecutionDirectory:=script.config.LastRun.LastExecutionDirectory
    }
    if (!Args.HasKey("OHTMLLevel")) {
        Args.OHTMLLevel:=script.config.config.defaultRelativeLevel
    }
    if Args.HasKey("path") {
        Args.path:=StrReplace(Args.path, "/","\")
    } else {

    }
    if (!Args.HasKey("--noIntermediates")) {
        Args.IntermediatesRemovalLevel:=0
    } else {
        if (!Args.HasKey("IntermediatesRemovalLevel")) {
            Args.IntermediatesRemovalLevel:=1
        }
    }
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
                    message:="Fatal error: CLI run without providing required argument '" arg "'.`nThis program will exit now." "`n" ttip_Obj2Str(Args)
                    AppError("Fatal argument-error occured", Message, Options := 0, TitlePrefix := " > " A_ThisFunc ": ")
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
validateCLIArgs(Byref Args) {
    ;; validate if non-implemented arguments are fed, and remove them
    for arg,val in Args {
        if (arg=="format") {
            continue
        } else if (arg=="cli") {
            continue
        }
        valid_inputs=
            (LTrim
                //obsidian html//
                convert ohtmllevel removeobsidianhtmlerrors usecustomfork verbose

                //quarto r//
                rendertooutputs lastexecutiondirectory

                //flags//
                nointermediates nomove noopen notify

                //flags-extensions//
                IntermediatesRemovalLevel

                //base//
                path runcli nooklog SourceNameIndex

            )
        if InStr(valid_inputs,arg) {
            continue
        }
        if ((SubStr(arg,1,2)="--") && !InStr(arg,"=")) { ;; generalise don't filter out flags
            continue
        }
        if (InStr(arg,"quarto::")) {
            continue
        }
        if (DEBUG) {
            msgbox % arg " = " val
        }
        Title:=": CLI-processing"
        Message:="CLI-Parameter '" arg "' (value:'" val "') is not implemented as of yet.`nThe parameter will be ignored."
        AppError(Title, Message,0x40030," > " A_ThisFunc)
    }
}
CLI_help() {
    flags:={"--noMove":"`t`t-`tSet to '1' to convert the note locally and create the '.qmd'-file at the location of the root."
            , "--noIntermediates": "`t-`tSet to '1' to delete/not store intermediate files after finishing execution.`n`t`t`t`t`t`t`tDeletes the output directory itself(?)"
            , "--noOpen":"`t`t-`tSet to '1' to not open the output directory after execution finishes."
            , "--noRender":"`t`t-`tSet to '1' to only create the '.qmd'-file, without rendering to outputs.`n`t`t`t`t`t`t`tOverwrites CL-Arg 'RenderToOutputs'"}
    Obj:={Path:"`t`t`t-`t(req): absolute path to the note being processed. The note must lie within an obsidian-Vault, as detected`n`t`t`t`t`t`tby the presence of an ``.obsidian``-folder somewhere above the note's location."
            , format:"`t`t`t-`t(req): key of the output-format used. Output format must be defined in 'DynamicArguments.ini'."
            , FullLog:"`t`t`t-`tNOT IMPLEMENTED"
            , OHTMLLevel:"`t`t-`tInteger, set to number of levels above the manuscript-LOCATION to implement an OHTML-restrictor."
            , Log:"`t`t`t-`tNOT IMPLEMENTED"
            , "quarto::XXXX.YY":"`t`t-`tPass along parameter modifications for parameter 'YY' of quarto-format 'XXXX'. Use quarto's parameter naming-scheme`n`t`t`t`t`t`tExample: ``quarto::html.number-depth=1``"
            , RenderToOutputs:"`t`t-`tSet to '1' to execute file-compilation via quarto-cli/``rscript``"
            , LastExecutionDirectory:"`t-`tSet to '1' to process in OHTML-output directory, set to '2' to process in vault-subfolder."}
    name:=script.name
    version:=script.version
    str1=
        (LTRIM
            ---------------------------------------
            CLI-Overview for '%name%' (v.%version%)
            1/3 - CLI-Arguments
            ---------------------------------------
            -h`treturn this help
            -v`treturn version

            Arguments:

        )
    for Arg, Explanation in Obj {
        str1.="`t`t" Arg  Explanation "`n"
    }
    str2=
        (LTrim
            ---------------------------------------
            CLI-Overview for '%name%' (v.%version%)
            2/3 - Flags
            ---------------------------------------

            Flags:

        )
    for Arg, Explanation in flags {
        str2.="`t`t" Arg  Explanation "`n"
    }
    str3=
        (LTrim
            ---------------------------------------
            CLI-Overview for '%name%' (v.%version%)
            3/3 - to-be-decided
            ---------------------------------------

        )
    ;for Arg, Explanation in flags {
    ;    str3.="`t`t" Arg  Explanation "`n"
    ;}
    str1_2=
        (LTRIM
            ---------------------------------------
            < {X} | {2} | {3} > 
            ---------------------------------------
            Press [Esc] to close the help.
            Press [1-9] for further details.
        )

    str2_2=
        (LTRIM
            ---------------------------------------
            < {1} | {X} | {3} > 
            ---------------------------------------
            Press [Esc] to close the help.
            Press [1-9] for further details.
        )
    str3_2=
        (LTRIM
            ---------------------------------------
            < {1} | {2} | {X} > 
            ---------------------------------------
            Press [Esc] to close the help.
            Press [1-9] for further details.
        )
    curr_help:=str1 str1_2
    while (1) {
        if GetKeyState("Escape") {
            break
        }
        if (GetKeyState(1)) {
            curr_help:=str1 str1_2
        } else if (GetKeyState(2)) {
            curr_help:=str2 str2_2
        } else if (GetKeyState(3)) {
            curr_help:=str3 str3_2
        } else if (GetKeyState("LCtrl") && GetKeyState("C")) {
            Clipboard:=curr_help
        }
        ttip(curr_help,5)
    }
    return
}
