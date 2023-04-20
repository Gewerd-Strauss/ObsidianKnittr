;; thank you u/anonymous1184 - https://www.reddit.com/r/AutoHotkey/comments/12l4gr8/regex_whileloop_match_replacement_the_bane_of_my/
RegExMatchAll(Haystack, NeedleRegEx, StartingPosition := 1) {
    out := []
    RegExMatch(NeedleRegEx, "^([imsxADJUXPOSC`r`n`a]+)?\)?(.+)", match)
    NeedleRegEx := "O" StrReplace(match1, "O") ")" match2
    loop {
        StartingPosition := RegExMatch(Haystack, NeedleRegEx, match, StartingPosition)
        if (!StartingPosition)
            break
        StartingPosition += match.Len(0)
        out.Push(match)
    }
    return out
}

RegExMatchLines(Haystack, NeedleRegEx) {
    out := []
    RegExMatch(NeedleRegEx, "^([imsxADJUXPOSC``nra]+)?\)?(.+)", match)
    NeedleRegEx := "O" StrReplace(match1, "O") ")" match2
    for _, line in StrSplit(Haystack, "`n", "`r") {
        if (RegExMatch(line, NeedleRegEx, match))
            out.Push(match)
    }
    return out
}