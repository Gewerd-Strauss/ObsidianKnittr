cleanLatexEnvironmentsforRMarkdown(String) {
    str =
        (LTRIM
            align
            equation
            array
            pmatrix
            bmatrix
            theorem
            lemma
            corollary
            prposition
            conjecture
            definition
            example
            exercise
            hypothesis
        )
    Environments := StrSplit(str, "`n")
    for _, environment in Environments {
        if (environment = "") {
            continue
        }
        needle1 := "(?<TopFence>\${2,}\s*\n*\\begin\{" environment "\*+\})[^\S\r\n]*"    ;; star, top                             works
            , needle2 := "\\end\{" environment "\*+}(\n|\s)*(?<BotFence>\${2,})"                ;; star, bottom                      works
            , needle3 := "(?<TopFence>\${2,}\s*\n*\\begin\{" environment "\})[^\S\r\n]*"       ;; no star, top                          works
            , needle4 := "\\end\{" environment "\}(\n|\s)*(?<BotFence>\${2,})"                   ;; no star, bottom                  works

        Matches1 := RegexMatchAll(String, "im)" needle1)
        for _, match in Matches1 {                                                  ;; star, top
            _match := match[0]
                , String := strreplace(String, _match, "`n\begin{" Trim(environment) "*}")
        }

        Matches2 := RegexMatchAll(String, "im)" needle2)
        for _, match in Matches2 {                                                  ;; star, bottom
            _match := match[0]
                , String := strreplace(String, _match, "\end{" Trim(environment) "*}`n")
        }

        Matches3 := RegexMatchAll(String, "im)" needle3)
        for _, match in Matches3 {                                                  ;; no star, top
            _match := match[0]
                , String := strreplace(String, _match, "`n\begin{" Trim(environment) "}")
        }

        Matches4 := RegexMatchAll(String, "im)" needle4)
        for _, match in Matches4 {                                                  ;; no star, bottom
            _match := match[0]
                , String := strreplace(String, _match, "\end{" Trim(environment) "}`n")
        }
    }
    OutputDebug % String
    return String
}
fixNullFields(String) {
    Lines:=strsplit(String,"`n")
        , inFrontMatter:=false
        , Rebuild:=""
        , Rebuild:=String
    for _, Line in Lines {
        Trimmed:=Trim(Line)
        if InStr(Trimmed,"---") && !inFrontMatter && (_=1) {            ;; encountered first fence
            inFrontMatter:=true
        } else if !InStr(Trimmed,"---") && !inFrontMatter {             ;; not a code-fence, not in front matter -> text after frontmatter
            inFrontMatter:=false
            break
        } else if !InStr(Trimmed,"---") && inFrontMatter {              ;; not a code-fence, but after first codefence -> we are in frontmatter
            if RegExMatch(Line, ".+\:\s*(?<NULL>null)") {
                Line2:=StrReplace(Line, "null","""null""")
                    , Rebuild:=Strreplace(Rebuild,Line,Line2,,1)
            }
            if RegexMatch(Line,".+\:$") {
                if InStr(Line, "tags") {
                    if !InStr(Lines[_+1],"- ") {    ;; make sure that an empty array is only added when no tags are added yet
                        Rebuild:=Strreplace(Rebuild,"tags:","tags: []",,1)
                    }
                }
            }
        } else if InStr(Trimmed,"---") && inFrontMatter  && (_>1) {     ;; encountered the second code-fence of the yaml front matter
            inFrontMatter:=false
        }
    }
    return Rebuild
}
