; --uID:2942823315
 ; Metadata:
  ; Snippet: Base64PNG_to_HICON  ;  (v.1.0)
  ; --------------------------------------------------------------
  ; Author: SKAN
  ; License: Custom public domain/conditionless right of use for any purpose
  ; LicenseURL:  https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/
  ; Source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36636
  ; (03.09.2017)
  ; --------------------------------------------------------------
  ; Library: Libs
  ; Section: 23 - Other
  ; Dependencies: Windows VISTA and above
  ; AHK_Version: 1.0
  ; --------------------------------------------------------------
  ; Keywords: Icon Base64

 ;; Description:
  ;; Parameters Width and Height are optional. Either omit them (to load icon in original dimensions) or specify both of them.
  ;; PNG decompression for Icons was introduced in WIN Vista
  ;; ICONs needn't be SQUARE
  ;; Passing fIcon parameter as false to CreateIconFromResourceEx() function, should create a hCursor (not tested)
  ;; Thanks to @Helgef and @just me me in ask-for-help topic: Anybody using Menu, Tray, Icon, HICON:%hIcon% ?
  ;; Thanks to @jeeswg for providing the formula to calculate Base64 data size.
  ;; Related:
  ;;     Base64 encoder/decoder for Binary data - https://autohotkey.com/boards/viewtopic.php?t=35964
  ;;     Base64ToComByteArray() :: Include image in script and display it with WIA 2.0 - https://autohotkey.com/boards/viewtopic.php?t=36124
  ;; 
  ;; 

 ;;; Example:
  ;;; #NoEnv
  ;;; #SingleInstance, Force
  ;;; 
  ;;; Base64PNG := "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAflBMVEXOgwD///+AUQDz5NSTXQD"
  ;;; . "j3NSliWe7dwCnagDGtaPnx6Pbp2eGVQDt1rz6+PXRjSTJgADCewCycQCeZADkwJbhuIf58ur06t/qzrDesHirb"
  ;;; . "QDw3ci0nILYn1TVlj+KYSSiZwCYYQCOWgDVyby+q5acfFSTbz/u4dTc08jNv7D3Mcn0AAACq0lEQVR42uzaXW/"
  ;;; . "aMBSA4WMn4JAQyAff0A5o123//w/OkSallUblSDm4qO9759zYfo4vI0RERERERERERERERERERERERB97Kva5L"
  ;;; . "3lX6deroljKXVoWxcpvWCbv2vkP++JJdFvud8nCfFZSrlQP8bwqE/NZiyTfa82hOJqgNrkotd6YoI6FKFSa4LY"
  ;;; . "qM1huTXCljN7aGIX9dSbgW8vYJWZIopAZUgIAAADEBHCuigvwy9VRAawvbQ91NICJP8A8zZoqIkDXPIsG8K+Li"
  ;;; . "wngu1ZRAXxtXADbxgawTVwAGx0gBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  ;;; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgI8BDBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  ;;; . "AAAAAD6AFOFHgrAKgQAAAAAAAAAADwegBuphwX4ln+KAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  ;;; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA1AY5mQAsNgIUZ0O/RAQozoJkGQ"
  ;;; . "G4GNB0dQNbhE/hjNQBkF/4CT3Z8AFmutkGbv/y0OgDyvNuYgLavP6wGQGdQ5GVy+xCTyezU3V4LoDNY50lyG3/"
  ;;; . "yMpt2t1cB6EunvtOsr1u/2RuJQm9T36zv1S/7m+sD2CGJQva/AQDAnQAudkBzUWhuB3SRsXN2QJkolNkBORm9J"
  ;;; . "nwCZ1HpHP4CG1GoOlyDNm9rUao+Bw3heqhEqcplbXr7EGmaNbWoVjdZmt7GT9vMVaKf8zVZn/PVcsdq58v6Ds5"
  ;;; . "XCRERERER/W0PDgkAAAAABP1/bfQEAAAAAAAL2VmKC7LwdTIAAAAASUVORK5CYII="
  ;;; 
  ;;; Gui, Add, Picture,, % "HICON:" Base64PNG_to_HICON(Base64PNG)
  ;;; Gui, Show,, Base64PNG_to_HICON() DEMO 
  ;;; Return 
  ;;; 
  ;;; ; Copy and paste Base64PNG_to_HICON() below
  ;;; 

  Base64PNG_to_HICON(Base64PNG, W:=0, H:=0) {     ;   By SKAN on D094/D357 @ tiny.cc/t-36636
    Local BLen:=StrLen(Base64PNG), Bin:=0,     nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)                     
      Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1
                ,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)
           ? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt"
                     ,0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0            
    }
    
   
   
    ; License:
   
     ; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/'
     ; Warning: Dependency 'Windows VISTA and above' may not be included. In that case, please search for it separately, or refer to the documentation.
   
   
   ; --uID:2942823315