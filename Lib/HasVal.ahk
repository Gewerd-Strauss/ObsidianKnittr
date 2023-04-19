; --uID:1547783079
 ; Metadata:
  ; Snippet: HasVal  ;  (v.1.0.0)
  ; --------------------------------------------------------------
  ; Author: jNizM
  ; Source: https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
  ; (18.01.2023)
  ; --------------------------------------------------------------
  ; Library: Personal Library
  ; Section: 13 - Objects
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------


 ;; Description:
  ;; Checks if an Array/Object has a value and returns its index/key.
  ;; 
  ;; If value occurs more than once in the array/object, ONLY THE FIRST occurence's key is returned

 ;;; Example:
  ;;; A:=[1,2,3]
  ;;; msgbox, % HasVal(A,2)
  ;;; B:={I:"1",J:"2",K:"3"}
  ;;; msgbox, % HasVal(B,2)
  ;;; 

  HasVal(haystack, needle) 
  {
      if !(IsObject(haystack)) || (haystack.Length() = 0)
          return 0
      for index, value in haystack
          if (value = needle)
              return index
      return 0
  }
 
 
 ; --uID:1547783079