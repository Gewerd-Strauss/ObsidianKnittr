; --uID:2849897047
; Metadata:
; Snippet: st_count  ;  (v.2.6)
; --------------------------------------------------------------
; Author: tidbit et al
; License: none
; Source: https://www.autohotkey.com/boards/viewtopic.php?t=53
;
; --------------------------------------------------------------
; Library: Libs
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: string things,

;; Description:
;;
;; Count
;;    Counts the number of times a tolken exists in the specified string.
;;
;;    string    = The string which contains the content you want to count.
;;    searchFor = What you want to search for and count.
;;
;;    note: If you're counting lines, you may need to add 1 to the results.
;;
;;
;; Name: String Things - Common String & Array Functions
;; Version 2.6 (Fri May 30, 2014)
;; Created: Sat March 02, 2013
;; Author: tidbit
;; Credit:
;;    AfterLemon  --- st_insert(), st_overwrite() bug fix. st_strip(), and more.
;;    Bon         --- word(), leftOf(), rightOf(), between() - These have been replaced
;;    faqbot      --- jumble()
;;    Lexikos     --- flip()
;;    MasterFocus --- Optimizing LineWrap and WordWrap.
;;    rbrtryn     --- group()
;;    Rseding91   --- Optimizing LineWrap and WordWrap.
;;    Verdlin     --- st_concat(), A couple nifty forum-only functions.
;;
;; Description:
;;    A compilation of commonly needed function for strings and arrays.

;;; Example:
;;; msgbox, % st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
;;; ;; output: 4

st_count(string, searchFor="`n") {
   StringReplace string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}

; --uID:2849897047
