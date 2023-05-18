; #region:RegexMatchAll/RegexMatchLines (3010221476)

; #region:Metadata:
; Snippet: RegexMatchAll/RegexMatchLines;  (v.1.0)
; --------------------------------------------------------------
; Author: u/anonymous1184
; License: none
; Source: https://www.reddit.com/r/AutoHotkey/comments/12l4gr8/comment/jg6ngt7/?utm_source=reddit&utm_medium=web2x&context=3
; (14 April 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: Regex
; #endregion:Metadata

; #region:Example
; for _, match in matches {
;     text := StrReplace(text, match[0])
; }
; #endregion:Example


; #region:Code
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
; #endregion:Code


; #endregion:RegexMatchAll/RegexMatchLines (3010221476)
