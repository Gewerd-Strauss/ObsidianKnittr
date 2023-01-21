; --uID:2878031207
 ; Metadata:
  ; Snippet: AddToolTip()  ;  (v.1.0)
  ; --------------------------------------------------------------
  ; Author: Rseding91
  ; Source: https://www.autohotkey.com/boards/viewtopic.php?t=2584
  ; 
  ; --------------------------------------------------------------
  ; Library: AHK-Rare
  ; Section: 21 - ToolTips
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: multi-line, gui control, control

 ;; Description:
  ;; 	/*                              	DESCRIPTION
  ;; 
  ;; 			 Adds Multi-line ToolTips to any Gui Control
  ;; 			 AHK basic, AHK ANSI, Unicode x86/x64 compatible
  ;; 
  ;; 			 Thanks Superfraggle & Art: http://www.autohotkey.com/forum/viewtopic.php?p=188241
  ;; 			 Heavily modified by Rseding91 3/4/2014:
  ;; 			 Version: 1.0
  ;; 			   * Fixed 64 bit support
  ;; 			   * Fixed multiple GUI support
  ;; 			   * Changed the _Modify parameter
  ;; 					   * blank/0/false:                                	Create/update the tool tip.
  ;; 					   * -1:                                           		Delete the tool tip.
  ;; 					   * any other value:                             Update an existing tool tip - same as blank/0/false
  ;;                                                         						but skips unnecessary work if the tool tip already
  ;;                                                         						exists - silently fails if it doesn't exist.
  ;; 			   * Added clean-up methods:
  ;; 					   * AddToolTip(YourGuiHwnd, "Destroy", -1):       		Cleans up and erases the cached tool tip data created
  ;;                                                                                     					for that GUI. Meant to be used in conjunction with
  ;;                                                                                     					GUI, Destroy.
  ;; 					   * AddToolTip(YourGuiHwnd, "Remove All", -1):	   	Removes all tool tips from every control in the GUI.
  ;;                                                                                     					Has the same effect as "Destroy" but first removes
  ;;                                                                                     					every tool tip from every control. This is only used
  ;;                                                                                     					when you want to remove every tool tip but not destroy
  ;;                                                                                     					the entire GUI afterwords.
  ;; 					   * NOTE: Neither of the above are required if
  ;;                             	your script is closing.
  ;; 
  ;; 			 - 'Text' and 'Picture' Controls requires a g-label to be defined.
  ;; 			 - 'ComboBox' = Drop-Down button + Edit (Get hWnd of the 'Edit'   control using "ControlGet" command).
  ;; 			 - 'ListView' = ListView + Header       (Get hWnd of the 'Header' control using "ControlGet" command).
  ;; 
  ;; 	*/

  AddToolTip(_CtrlHwnd, _TipText, _Modify = 0) {                                                        			;-- very easy to use function to add a tooltip to a control
 
    Static TTHwnds, GuiHwnds, Ptr
    , LastGuiHwnd
    , LastTTHwnd
    , TTM_DELTOOLA := 1029
    , TTM_DELTOOLW := 1075
    , TTM_ADDTOOLA := 1028
    , TTM_ADDTOOLW := 1074
    , TTM_UPDATETIPTEXTA := 1036
    , TTM_UPDATETIPTEXTW := 1081
    , TTM_SETMAXTIPWIDTH := 1048
    , WS_POPUP := 0x80000000
    , BS_AUTOCHECKBOX = 0x3
    , CW_USEDEFAULT := 0x80000000

    Ptr := A_PtrSize ? "Ptr" : "UInt"

    /*                              	NOTE

                 This is used to remove all tool tips from a given GUI and to clean up references used
                 This can be used if you want to remove every tool tip but not destroy the GUI
                 When a GUI is destroyed all Windows tool tip related data is cleaned up.
                 The cached Hwnd's in this function will be removed automatically if the caching code
                 ever matches them to a new GUI that doesn't actually own the Hwnd's.
                 It's still possible that a new GUI could have the same Hwnd as a previously destroyed GUI
                 If such an event occurred I have no idea what would happen. Either the tool tip
                 To avoid that issue, do either of the following:
                       * Don't destroy a GUI once created
                 NOTE: You do not need to do the above if you're exiting the script Windows will clean up
                  all tool tip related data and the cached Hwnd's in this function are lost when the script
                  exits anyway.AtEOF
    */

    If (_TipText = "Destroy" Or _TipText = "Remove All" And _Modify = -1)
    {
        ; Check if the GuiHwnd exists in the cache list of GuiHwnds
        ; If it doesn't exist, no tool tips can exist for the GUI.
        ;
        ; If it does exist, find the cached TTHwnd for removal.
        Loop, Parse, GuiHwnds, |
            If (A_LoopField = _CtrlHwnd)
            {
                TTHwnd := A_Index
                , TTExists := True
                Loop, Parse, TTHwnds, |
                    If (A_Index = TTHwnd)
                        TTHwnd := A_LoopField
            }

        If (TTExists)
        {
            If (_TipText = "Remove All")
            {
                WinGet, ChildHwnds, ControlListHwnd, ahk_id %_CtrlHwnd%

                Loop, Parse, ChildHwnds, `n
                    AddToolTip(A_LoopField, "", _Modify) ;Deletes the individual tooltip for a given control if it has one

                DllCall("DestroyWindow", Ptr, TTHwnd)
            }

            GuiHwnd := _CtrlHwnd
            ; This sub removes 'GuiHwnd' and 'TTHwnd' from the cached list of Hwnds
            GoSub, RemoveCachedHwnd
        }

        Return
    }

    If (!GuiHwnd := DllCall("GetParent", Ptr, _CtrlHwnd, Ptr))
        Return "Invalid control Hwnd: """ _CtrlHwnd """. No parent GUI Hwnd found for control."

    ; If this GUI is the same one as the potential previous one
    ; else look through the list of previous GUIs this function
    ; has operated on and find the existing TTHwnd if one exists.
    If (GuiHwnd = LastGuiHwnd)
        TTHwnd := LastTTHwnd
    Else
    {
        Loop, Parse, GuiHwnds, |
            If (A_LoopField = GuiHwnd)
            {
                TTHwnd := A_Index
                Loop, Parse, TTHwnds, |
                    If (A_Index = TTHwnd)
                        TTHwnd := A_LoopField
            }
    }

    ; If the TTHwnd isn't owned by the controls parent it's not the correct window handle
    If (TTHwnd And GuiHwnd != DllCall("GetParent", Ptr, TTHwnd, Ptr))
    {
        GoSub, RemoveCachedHwnd
        TTHwnd := ""
    }

    ; Create a new tooltip window for the control's GUI - only one needs to exist per GUI.
    ; The TTHwnd's are cached for re-use in any subsequent calls to this function.
    If (!TTHwnd)
    {
        TTHwnd := DllCall("CreateWindowEx"
                        , "UInt", 0                             ;dwExStyle
                        , "Str", "TOOLTIPS_CLASS32"             ;lpClassName
                        , "UInt", 0                             ;lpWindowName
                        , "UInt", WS_POPUP | BS_AUTOCHECKBOX    ;dwStyle
                        , "UInt", CW_USEDEFAULT                 ;x
                        , "UInt", 0                             ;y
                        , "UInt", 0                             ;nWidth
                        , "UInt", 0                             ;nHeight
                        , "UInt", GuiHwnd                       ;hWndParent
                        , "UInt", 0                             ;hMenu
                        , "UInt", 0                             ;hInstance
                        , "UInt", 0)                            ;lpParam

        ; TTM_SETWINDOWTHEME
        DllCall("uxtheme\SetWindowTheme"
                    , Ptr, TTHwnd
                    , Ptr, 0
                    , Ptr, 0)

        ; Record the TTHwnd and GuiHwnd for re-use in any subsequent calls.
        TTHwnds .= (TTHwnds ? "|" : "") TTHwnd
        , GuiHwnds .= (GuiHwnds ? "|" : "") GuiHwnd
    }

    ; Record the last-used GUIHwnd and TTHwnd for re-use in any immediate future calls.
    LastGuiHwnd := GuiHwnd
    , LastTTHwnd := TTHwnd
    /*
        *TOOLINFO STRUCT*

        UINT        cbSize
        UINT        uFlags
        HWND        hwnd
        UINT_PTR    uId
        RECT        rect
        HINSTANCE   hinst
        LPTSTR      lpszText
        #if (_WIN32_IE >= 0x0300)
            LPARAM    lParam;
        #endif
        #if (_WIN32_WINNT >= Ox0501)
            void      *lpReserved;
        #endif
    */

    , TInfoSize := 4 + 4 + ((A_PtrSize ? A_PtrSize : 4) * 2) + (4 * 4) + ((A_PtrSize ? A_PtrSize : 4) * 4)
    , Offset := 0
    , Varsetcapacity(TInfo, TInfoSize, 0)
    , Numput(TInfoSize, TInfo, Offset, "UInt"), Offset += 4                         ; cbSize
    , Numput(1 | 16, TInfo, Offset, "UInt"), Offset += 4                            ; uFlags
    , Numput(GuiHwnd, TInfo, Offset, Ptr), Offset += A_PtrSize ? A_PtrSize : 4      ; hwnd
    , Numput(_CtrlHwnd, TInfo, Offset, Ptr), Offset += A_PtrSize ? A_PtrSize : 4    ; UINT_PTR
    , Offset += 16                                                                  ; RECT (not a pointer but the entire RECT)
    , Offset += A_PtrSize ? A_PtrSize : 4                                           ; hinst
    , Numput(&_TipText, TInfo, Offset, Ptr)                                         ; lpszText
    ; The _Modify flag can be used to skip unnecessary removal and creation if
    ; the caller follows usage properly but it won't hurt if used incorrectly.
    If (!_Modify Or _Modify = -1)
    {
        If (_Modify = -1)
        {
            ; Removes a tool tip if it exists - silently fails if anything goes wrong.
            DllCall("SendMessage"
                    , Ptr, TTHwnd
                    , "UInt", A_IsUnicode ? TTM_DELTOOLW : TTM_DELTOOLA
                    , Ptr, 0
                    , Ptr, &TInfo)

            Return
        }

        ; Adds a tool tip and assigns it to a control.
        DllCall("SendMessage"
                , Ptr, TTHwnd
                , "UInt", A_IsUnicode ? TTM_ADDTOOLW : TTM_ADDTOOLA
                , Ptr, 0
                , Ptr, &TInfo)

        ; Sets the preferred wrap-around width for the tool tip.
         DllCall("SendMessage"
                , Ptr, TTHwnd
                , "UInt", TTM_SETMAXTIPWIDTH
                , Ptr, 0
                , Ptr, A_ScreenWidth)
    }

    ; Sets the text of a tool tip - silently fails if anything goes wrong.
    DllCall("SendMessage"
        , Ptr, TTHwnd
        , "UInt", A_IsUnicode ? TTM_UPDATETIPTEXTW : TTM_UPDATETIPTEXTA
        , Ptr, 0
        , Ptr, &TInfo)

    Return
    RemoveCachedHwnd:
        Loop, Parse, GuiHwnds, |
            NewGuiHwnds .= (A_LoopField = GuiHwnd ? "" : ((NewGuiHwnds = "" ? "" : "|") A_LoopField))

        Loop, Parse, TTHwnds, |
            NewTTHwnds .= (A_LoopField = TTHwnd ? "" : ((NewTTHwnds = "" ? "" : "|") A_LoopField))

        GuiHwnds := NewGuiHwnds
        , TTHwnds := NewTTHwnds
        , LastGuiHwnd := ""
        , LastTTHwnd := ""
    Return
}


; --uID:2878031207