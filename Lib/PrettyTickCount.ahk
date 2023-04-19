; --uID:2595808127
 ; Metadata:
  ; Snippet: PrettyTickCount()
  ; 09 Oktober 2022  ; --------------------------------------------------------------
  ; License: WTFPL
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 26 - Date or Time
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------


 ;; Description:
  ;; takes a time in milliseconds and displays it in a readable fashion
  ;; 
  ;; 

  PrettyTickCount(timeInMilliSeconds) {                                                                 	;-- takes a time in milliseconds and displays it in a readable fashion
    ElapsedHours := SubStr(0 Floor(timeInMilliSeconds / 3600000), -1)
    ElapsedMinutes := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000) / 60000), -1)
    ElapsedSeconds := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000) / 1000), -1)
    ElapsedMilliseconds := SubStr(0 timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000 - ElapsedSeconds * 1000, -2)
    returned := ElapsedHours "h:" ElapsedMinutes "m:" ElapsedSeconds "s." ElapsedMilliseconds
    return returned
 }


; --uID:2595808127