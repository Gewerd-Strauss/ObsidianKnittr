; #region:enableGuiDrag (87004804)

; #region:Metadata:
; Snippet: enableGuiDrag;  (v.1.0)
; --------------------------------------------------------------
; Author: Goyyah, SKAN
; Source: http://autohotkey.com/board/topic/80594-how-to-enable-drag-for-a-gui-without-a-titlebar
; (13.06.2006)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 06 - gui - interacting
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata

; #region:Description:
; Enables Drag on a GUI without requiring a titlebar.
;
; Further Details and an alternative solution: https://www.autohotkey.com/boards/viewtopic.php?p=320&sid=70f513570fdd3a4de42f54b1b26bdb95#p320
;
; #endregion:Description

; #region:Example
; pic=%A_temp%\pic.png
; URLDownloadToFile,http://cdn.autohotkey.com/static/ahk_logo_ipb.png,%pic%
; ltext:=lines(100)
;
; Gui, Add, CheckBox, x12 y10 w80 h30 , CheckBox
; Gui, Add, Radio, x12 y40 w80 h30 , Radio
; Gui, Add, Edit, x2 y70 w90 h30 , Edit
; Gui, Add, GroupBox, x92 y10 w100 h90 , GroupBox
; Gui, Add, DropDownList, x102 y30 w80 h20 , DropDownList
; Gui, Add, ComboBox, x102 y60 w80 h20 , ComboBox
; Gui, Add, Progress, x192 y10 w100 h30 , 25
; Gui, Add, ListBox, x192 y40 w100 h60 , ListBox
; Gui, Add, ListView, x2 y100 w190 h80 , ListView
; Gui, Add, DateTime, x192 y130 w100 h30 ,
; Gui, Add, MonthCal, x2 y180 w230 h170 ,
; Gui, Add, Slider, x192 y100 w100 h30 , 25
; Gui, Add, Hotkey, x192 y160 w100 h20 ,
; Gui, Add, UpDown, x232 y180 w20 h170 , UpDown
; Gui, Add, Picture, x312 y10 w150 h40 , %pic%
; Gui, Add, Picture, x312 y60 w150 h44 , %pic%
; Gui, Add, Picture, x312 y120 w150 h44 , %pic%
; ;Tab2 doesnt work for some reason... Solution by Nazzal below...
; Gui, Add, Tab, x252 y180 w220 h170 , Tab1|Tab2
; gui, Add, Link,, <a href="http://www.Autohotkey.com">hello`, this is a link. Autohotkey.com</a>
; Gui, Add, Edit, w200 h80, Scrollable Edit Control`n%ltext%
; Gui, Show, w479 h358, Draggable GUI with Controls
;
; enableGuiDrag()
; return
;
; GuiClose:
; FileDelete, %A_temp%\pic.png
; ExitApp
;
; lines(numberoflines) {
; 	z=
; 	loop, %numberoflines%
; 		z=%z%Line%A_Index%`n
; 	StringTrimRight,z,z,1
; 	return z
; }
;
; enableGuiDrag(GuiLabel=1) {
; 	WinGetPos,,,A_w,A_h,A
; 	Gui, %GuiLabel%:Add, Text, x0 y0 w%A_w% h%A_h% +BackgroundTrans gGUI_Drag
; 	return
;
; 	GUI_Drag:
; 	PostMessage 0xA1,2  ;-- Goyyah/SKAN trick
; 	;http://autohotkey.com/board/topic/80594-how-to-enable-drag-for-a-gui-without-a-titlebar
; 	return
; }
;
; #endregion:Example

; #region:Code
enableGuiDrag(GuiLabel=1) {
   WinGetPos,,,A_w,A_h,A
   Gui, %GuiLabel%:Add, Text, x0 y0 w%A_w% h%A_h% +BackgroundTrans gGUI_Drag
   return

   GUI_Drag:
   SendMessage 0xA1,2 ;-- Goyyah/SKAN trick
   ;
   return
}
; #endregion:Code

; #endregion:enableGuiDrag (87004804)
