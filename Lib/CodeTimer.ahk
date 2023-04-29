; #region:CodeTimer (2035383057)

; #region:Metadata:
; Snippet: CodeTimer;  (v.1.0)
; --------------------------------------------------------------
; Author: CodeKnight
; Source: -
; (05.03.2020)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 23 - Other
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: performance, time
; #endregion:Metadata

; #region:Description:
; approximate measure of how much time has exceeded between two positions in code. Returns an array containing the time expired (in ms), as well as the displayed string.
; #endregion:Description

; #region:Example
; CodeTimer("A timer")
; Sleep 1050
; ; Insert other code between the two function calls
; CodeTimer("A timer")
;
; #endregion:Example

; #region:Code
CodeTimer(Description,x:=500,y:=500,ClipboardFlag:=0) {
    Global StartTimer
    If (StartTimer != "") {
        FinishTimer := A_TickCount
        TimedDuration := FinishTimer - StartTimer
        StartTimer := ""
        If (ClipboardFlag=1) {
            Clipboard:=TimedDuration
        }
        tooltip,% String:="Timer " Description "`n" TimedDuration " ms have elapsed!",% x,% y
        Return [TimedDuration,String,PrettyTickCount(TimedDuration)]
    } Else {
        StartTimer := A_TickCount
    }
}
; #endregion:Code

; #endregion:CodeTimer (2035383057)
