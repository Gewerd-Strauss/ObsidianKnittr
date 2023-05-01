; #region:Deref (3534284804)
; #region:Metadata:
; Snippet: Deref;  (v.1)
; --------------------------------------------------------------
; License: GNU GPLv2
; LicenseURL: https://www.autohotkey.com/docs/v1/license.htm
; Source: https://www.autohotkey.com/docs/v1/lib/RegExMatch.htm#ExDeref
; (22 April 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 07 - Variables
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata

; #region:Description:
; Replace Variable references in-String
;
; Similar to Transform Deref, the following function expands variable references and escape sequences contained inside other variables.
; Furthermore, this example shows how to find all matches in a string rather than stopping at the first match (similar to the g flag in JavaScript's RegEx).
; #endregion:Description

; #region:Example
; var1 := "abc"
; var2 := 123
; MsgBox % Deref("%var1%def%var2%")  ; Reports abcdef123.
; #endregion:Example

; #region:Code
Deref(String) {
    spo := 1
    out := ""
    while (fpo := RegexMatch(String, "(%(.*?)%)|``(.)", m, spo)) {
        out .= SubStr(String, spo, fpo - spo)
        spo := fpo + StrLen(m)
        if (m1) {
            out .= %m2%
        } else switch (m3) {
        case "a": out .= "`a"
        case "b": out .= "`b"
        case "f": out .= "`f"
        case "n": out .= "`n"
        case "r": out .= "`r"
        case "t": out .= "`t"
        case "v": out .= "`v"
        default: out .= m3
        }
    }
    return out SubStr(String, spo)
}
; #endregion:Code

; #region:License
; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/docs/v1/license.htm'
;
; #endregion:License

; #endregion:Deref (3534284804)
