#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
;#Persistent
;#Warn All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;DetectHiddenWindows, On
;SetKeyDelay -1
SetBatchLines -1
SetTitleMatchMode, 2
; ntfy:=Notify()
;; to work in unison with 
;; obsidian-better-pdf-plugin: https://github.com/MSzturc/obsidian-better-pdf-plugin


Template=
(
```pdf
    "url" : %PathToFile%,
    "scale" : %scale%,
    "page" : %pages%,
    "fit"   : %fit%
```

)
return


gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
Gui, Margin, 16, 16
Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC
cBackground := "c" . "1d1f21"
cCurrentLine := "c" . "282a2e"
cSelection := "c" . "373b41"
cForeground := "c" . "c5c8c6"
cComment := "c" . "969896"
cRed := "c" . "cc6666"
cOrange := "c" . "de935f"
cYellow := "c" . "f0c674"
cGreen := "c" . "b5bd68"
cAqua := "c" . "8abeb7"
cBlue := "c" . "81a2be"
cPurple := "c" . "b294bb"
Gui, Color, 1d1f21, 373b41, 
Gui, Font, s11 cWhite, Segoe UI 
gui, add, text,xm ym, set scale,
Gui, add, Edit, xp %gui_control_options% -VScroll
gui, add, checkbox, Fit?

Gui, Font, s7 cWhite, Verdana
Gui, Add, Text,x25, Version: %VN%	Author: %AU% 
gui, show, 
return

GuiEscape:
gui, destroy
return
