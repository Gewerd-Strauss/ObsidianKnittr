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
        needle2 := "\\end\{" environment "\*+}(\n|\s)*(?<BotFence>\${2,})"                ;; star, bottom                      works
        needle3 := "(?<TopFence>\${2,}\s*\n*\\begin\{" environment "\})[^\S\r\n]*"       ;; no star, top                          works
        needle4 := "\\end\{" environment "\}(\n|\s)*(?<BotFence>\${2,})"                   ;; no star, bottom                  works

        Matches1 := RegexMatchAll(String, "im)" needle1)
        for _, match in Matches1 {                                                  ;; star, top
            _match := match[0]
            String := strreplace(String, _match, "`n\begin{" Trim(environment) "*}")
        }

        Matches2 := RegexMatchAll(String, "im)" needle2)
        for _, match in Matches2 {                                                  ;; star, bottom
            _match := match[0]
            String := strreplace(String, _match, "\end{" Trim(environment) "*}`n")
        }

        Matches3 := RegexMatchAll(String, "im)" needle3)
        for _, match in Matches3 {                                                  ;; no star, top
            _match := match[0]
            String := strreplace(String, _match, "`n\begin{" Trim(environment) "}")
        }

        Matches4 := RegexMatchAll(String, "im)" needle4)
        for _, match in Matches4 {                                                  ;; no star, bottom
            _match := match[0]
            String := strreplace(String, _match, "\end{" Trim(environment) "}`n")
        }
    }
    OutputDebug % String
    return String
}
