; #Requires Autohotkey v1.1+
ConvertSRC_SYNTAX("C:\Users\Claudius Main\Desktop\TempTemporal\Embed2\index.md")

ConvertSRC_SYNTAX(md_Path)
{
    if FileExist(md_Path)
        FileRead, buffer, % md_Path
    else
        buffer:=md_Path
    ;Clipboard:=buffer
    p := 1
    regex = <img src="(?<SRC>[^"]+)"  width="(?<WIDTH>[^"]*)" alt="(?<ALT>[^"]*)" title="(?<TITLE>[^"]*)" \/>
    while (p := RegExMatch(buffer, "iO)" regex, match, p)) {
        align := ""
        cap := match.alt
        src := strreplace(match.src,"%20",A_Space)
        title := match.title
        width := match.width
        options:=""
        if width
            options.="out.width='" width  
        if extra 
            options.=(options!=""?"', ":"") "out.extra='" extra 
        if align
            options.=(options!=""?"', ":"") "fig.align='" align 
        if cap
            options.=(options!=""?"', ":"") "fig.cap='" cap 
        if title
            options.=(options!=""?"', ":"") "fig.title='" title
        if (options!="")
            options:=", " options "'"
        tpl = ;; Yes, the additional spaces in above and below the knitr-block are required, for god knows what reasons.
            (LTrim
            

            ``````{r%options%}
            knitr::include_graphics("%src%")
            ``````


            )
        buffer := StrReplace(buffer, match[0], tpl)
        p += StrLen(tpl)
    }
    tpl=
    (LTrim
    
    ---
    ``````{r setup, include=FALSE}
    knitr::opts_chunk$set(echo = FALSE)

    ``````
    
    )
    buffer1:=Regexreplace(buffer, "``````\{r setup(|.|\n)*``````","") ;; get rid of all potential r setup chunks
    Clipboard:=buffer1
    
    buffer:=RegExReplace(buffer1, "\n---", tpl,,1)
    Clipboard:=buffer
    OutputDebug % buffer
    return buffer
}
