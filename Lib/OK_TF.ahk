; --uID:1865426853
; Metadata:
; Snippet: TF - Textfile & String Library for AutoHotkey  ;  (v.3.8)
; --------------------------------------------------------------
; Author: hi5
; License: GPL 2.0
; LicenseURL:  https://raw.githubusercontent.com/hi5/TF/master/license.txt
; Source: https://github.com/hi5/TF| https://www.autohotkey.com/boards/viewtopic.php?f=6&t=576| http://www.autohotkey.com/forum/topic46195.html
;
; --------------------------------------------------------------
; Library: Libs
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

;; Description:
;; /*
;;
;; Documentation :
;; AutoHotkey.com: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=576
;; AutoHotkey.com: http://www.autohotkey.com/forum/topic46195.html (Also for examples)
;; License       : see license.txt (GPL 2.0)
;;
;; Credits & History: See documentation at GH above.
;;
;; Structure of most functions:
;;
;; OK_TF_...(Text, other parameters)
;; 	{
;; 	 ; get the basic data we need for further processing and returning the output:
;; 	 OK_TF_GetData(OW, Text, FileName)
;; 	 ; OW = 0 Copy inputfile
;; 	 ; OW = 1 Overwrite inputfile
;; 	 ; OW = 2 Return variable
;; 	 ; Text : either contents of file or the var that was passed on
;; 	 ; FileName : Used in case OW is 0 or 1 (=file), not used for OW=2 (variable)
;;
;; 	 ; Creates a matchlist for use in Loop below
;; 	 OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; A_ThisFunc useful for debugging your scripts
;;
;; 	 Loop, Parse, Text, `n, `r
;; 		{
;; 		 If A_Index in %OK_TF_MatchList%
;; 			{
;; 			...
;; 			}
;; 		 Else
;; 			{
;; 			...
;; 			}
;; 		}
;; 	 ; either copy or overwrite file or return variable
;; 	 Return OK_TF_ReturnOutPut(OW, OutPut, FileName, TrimTrailing, CreateNewFile)
;; 	 ; OW 0 or 1 = file
;; 	 ; Output = new content of file to save or variable to return
;; 	 ; FileName
;; 	 ; TrimTrailing: because of the loops used most functions will add trailing newline, this will remove it by default
;; 	 ; CreateNewFile: To create a file that doesn't exist this parameter is needed, only used in few functions
;; 	}
;;
;; */

OK_TF_CountLines(Text)
{
   OK_TF_GetData(OW, Text, FileName)
   StringReplace Text, Text, `n, `n, UseErrorLevel
   Return ErrorLevel + 1
}

OK_TF_ReadLines(Text, StartLine = 1, EndLine = 0, Trailing = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         OutPut .= A_LoopField "`n"
      Else if (A_Index => EndLine)
         Break
   }
   OW = 2 ; make sure we return variable not process file
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName, Trailing)
}

OK_TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
{
   OK_TF_GetData(OW, Text, FileName)
   IfNotInString, Text, %SearchText%
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         StringReplace LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
         OutPut .= LoopField "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_Replace(Text, SearchText, ReplaceText="")
{
   OK_TF_GetData(OW, Text, FileName)
   IfNotInString, Text, %SearchText%
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
   Loop
   {
      StringReplace Text, Text, %SearchText%, %ReplaceText%, All
      if (ErrorLevel = 0) ; No more replacements needed.
         break
   }
   Return OK_TF_ReturnOutPut(OW, Text, FileName, 0)
}

OK_TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
{
   options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
   If RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
   Else searchText := "m)" . searchText
   OK_TF_GetData(OW, Text, FileName)
   If (RegExMatch(Text, SearchText) < 1)
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3

   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         LoopField := RegExReplace(A_LoopField, NeedleRegEx, Replacement)
         OutPut .= LoopField "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_RegExReplace(Text, NeedleRegEx = "", Replacement = "")
{
   options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
   if RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
   else searchText := "m)" . searchText
   OK_TF_GetData(OW, Text, FileName)
   If (RegExMatch(Text, SearchText) < 1)
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
   Text := RegExReplace(Text, NeedleRegEx, Replacement)
   Return OK_TF_ReturnOutPut(OW, Text, FileName, 0)
}

OK_TF_RemoveLines(Text, StartLine = 1, EndLine = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         Continue
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_RemoveBlankLines(Text, StartLine = 1, EndLine = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   If (RegExMatch(Text, "[\S]+?\r?\n?") < 1)
      Return Text ; No empty lines so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_RemoveDuplicateLines(Text, StartLine = 1, Endline = 0, Consecutive = 0, CaseSensitive = false)
{
   OK_TF_GetData(OW, Text, FileName)
   If (StartLine = "")
      StartLine = 1
   If (Endline = 0 OR Endline = "")
      EndLine := OK_TF_Count(Text, "`n") + 1
   Loop, Parse, Text, `n, `r
   {
      If (A_Index < StartLine)
         Section1 .= A_LoopField "`n"
      If A_Index between %StartLine% and %Endline%
      {
         If (Consecutive = 1)
         {
            If (A_LoopField <> PreviousLine) ; method one for consecutive duplicate lines
               Section2 .= A_LoopField "`n"
            PreviousLine:=A_LoopField
         }
         Else
         {
            If !(InStr(SearchForSection2,"__bol__" . A_LoopField . "__eol__",CaseSensitive)) ; not found
            {
               SearchForSection2 .= "__bol__" A_LoopField "__eol__" ; this makes it unique otherwise it could be a partial match
               Section2 .= A_LoopField "`n"
            }
         }
      }
      If (A_Index > EndLine)
         Section3 .= A_LoopField "`n"
   }
   Output .= Section1 Section2 Section3
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_InsertLine(Text, StartLine = 1, Endline = 0, InsertText = "")
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         Output .= InsertText "`n" A_LoopField "`n"
      Else
         Output .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         Output .= ReplaceText "`n"
      Else
         Output .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}
OK_TF_InsertPrefix(Text, StartLine = 1, EndLine = 0, InsertText = "")
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         OutPut .= InsertText A_LoopField "`n"
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_InsertSuffix(Text, StartLine = 1, EndLine = 0 , InsertText = "")
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
         OutPut .= A_LoopField InsertText "`n"
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_TrimLeft(Text, StartLine = 1, EndLine = 0, Count = 1)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         StringTrimLeft StrOutPut, A_LoopField, %Count%
         OutPut .= StrOutPut "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_TrimRight(Text, StartLine = 1, EndLine = 0, Count = 1)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         StringTrimRight StrOutPut, A_LoopField, %Count%
         OutPut .= StrOutPut "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_AlignLeft(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
{
   Trim:=A_AutoTrim ; store trim settings
   AutoTrim On ; make sure AutoTrim is on
   OK_TF_GetData(OW, Text, FileName)
   If (Endline = 0 OR Endline = "")
      EndLine := OK_TF_Count(Text, "`n") + 1
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace. Trims leading and trailing spaces!
         SpaceNum := Columns-StrLen(LoopField)-1
         If (SpaceNum > 0) and (Padding = 1) ; requires padding + keep padding
         {
            Left:=OK_TF_SetWidth(LoopField,Columns, 0) ; align left
            OutPut .= Left "`n"
         }
         Else
            OutPut .= LoopField "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   AutoTrim %Trim%	; restore original Trim
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_AlignCenter(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
{
   Trim:=A_AutoTrim ; store trim settings
   AutoTrim On ; make sure AutoTrim is on
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
         SpaceNum := (Columns-StrLen(LoopField)-1)/2
         If (Padding = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
         {
            OutPut .= "`n"
            Continue
         }
         If (StrLen(LoopField) >= Columns)
         {
            OutPut .= LoopField "`n" ; add as is
            Continue
         }
         Centered:=OK_TF_SetWidth(LoopField,Columns, 1) ; align center using set width
         OutPut .= Centered "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   AutoTrim %Trim%	; restore original Trim
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_AlignRight(Text, StartLine = 1, EndLine = 0, Columns = 80, Skip = 0)
{
   Trim:=A_AutoTrim ; store trim settings
   AutoTrim On ; make sure AutoTrim is on
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
         If (Skip = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
         {
            OutPut .= "`n"
            Continue
         }
         If (StrLen(LoopField) >= Columns)
         {
            OutPut .= LoopField "`n" ; add as is
            Continue
         }
         Right:=OK_TF_SetWidth(LoopField,Columns, 2) ; align right using set width
         OutPut .= Right "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   AutoTrim %Trim%	; restore original Trim
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; Based on: CONCATenate text files, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
OK_TF_ConCat(FirstTextFile, SecondTextFile, OutputFile = "", Blanks = 0, FirstPadMargin = 0, SecondPadMargin = 0)
{
   If (Blanks > 0)
      Loop, %Blanks%
         InsertBlanks .= A_Space
   If (FirstPadMargin > 0)
      Loop, %FirstPadMargin%
         PaddingFile1 .= A_Space
   If (SecondPadMargin > 0)
      Loop, %SecondPadMargin%
         PaddingFile2 .= A_Space
   Text:=FirstTextFile
   OK_TF_GetData(OW, Text, FileName)
   StringSplit Str1Lines, Text, `n, `r
   Text:=SecondTextFile
   OK_TF_GetData(OW, Text, FileName)
   StringSplit Str2Lines, Text, `n, `r
   Text= ; clear mem

   ; first we need to determine the file with the most lines for our loop
   If (Str1Lines0 > Str2Lines0)
      MaxLoop:=Str1Lines0
   Else
      MaxLoop:=Str2Lines0
   Loop, %MaxLoop%
   {
      Section1:=Str1Lines%A_Index%
      Section2:=Str2Lines%A_Index%
      OutPut .= Section1 PaddingFile1 InsertBlanks Section2 PaddingFile2 "`n"
      Section1= ; otherwise it will remember the last line from the shortest file or var
      Section2=
   }
   OW=1 ; it is probably 0 so in that case it would create _copy, so set it to 1
   If (OutPutFile = "") ; if OutPutFile is empty return as variable
      OW=2
   Return OK_TF_ReturnOutPut(OW, OutPut, OutputFile, 1, 1)
}

OK_TF_LineNumber(Text, Leading = 0, Restart = 0, Char = 0) ; HT ribbet.1
{
   global t
   OK_TF_GetData(OW, Text, FileName)
   Lines:=OK_TF_Count(Text, "`n") + 1
   Padding:=StrLen(Lines)
   If (Leading = 0) and (Char = 0)
      Char := A_Space
   Loop, %Padding%
      PadLines .= Char
   Loop, Parse, Text, `n, `r
   {
      If Restart = 0
         MaxNo = %A_Index%
      Else
      {
         MaxNo++
         If MaxNo > %Restart%
            MaxNo = 1
      }
      LineNumber:= MaxNo
      If (Leading = 1)
      {
         LineNumber := Padlines LineNumber ; add padding
         StringRight LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
      }
      If (Leading = 0)
      {
         LineNumber := LineNumber Padlines ; add padding
         StringLeft LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
      }
      OutPut .= LineNumber A_Space A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; skip = 1, skip shorter lines (e.g. lines shorter startcolumn position)
; modified in TF 3.4, fixed in 3.5
OK_TF_ColGet(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1, Skip = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   If (StartColumn < 0)
   {
      StartColumn++
      Loop, Parse, Text, `n, `r ; parsing file/var
      {
         If A_Index in %OK_TF_MatchList%
         {
            output .= SubStr(A_LoopField,StartColumn) "`n"
         }
         else
            output .= A_LoopField "`n"
      }
      Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
   }
   if RegExMatch(StartColumn, ",|\+|-")
   {
      StartColumn:=OK_TF__MakeMatchList(Text, StartColumn, 1, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
      {
         If A_Index in %OK_TF_MatchList%
         {
            loop, parse, A_LoopField ; parsing LINE char by char
            {
               If A_Index in %StartColumn% ; if col in index get char
                  output .= A_LoopField
            }
            output .= "`n"
         }
         else
            output .= A_LoopField "`n"
      }
      output .= A_LoopField "`n"
   }
   else
   {
      EndColumn:=(EndColumn+1)-StartColumn
      Loop, Parse, Text, `n, `r
      {
         If A_Index in %OK_TF_MatchList%
         {
            StringMid Section, A_LoopField, StartColumn, EndColumn
            If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
               Continue
            OutPut .= Section "`n"
         }
      }
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; Based on: COLPUT.EXE & CUT.EXE, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
; modified in TF 3.4
OK_TF_ColPut(Text, Startline = 1, EndLine = 0, StartColumn = 1, InsertText = "", Skip = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   If RegExMatch(StartColumn, ",|\+")
   {
      StartColumn:=OK_TF__MakeMatchList(Text, StartColumn, 0, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
      {
         If A_Index in %OK_TF_MatchList%
         {
            loop, parse, A_LoopField ; parsing LINE char by char
            {
               If A_Index in %StartColumn% ; if col in index insert text
                  output .= InsertText A_LoopField
               Else
                  output .= A_LoopField
            }
            output .= "`n"
         }
         else
            output .= A_LoopField "`n"
      }
      output .= A_LoopField "`n"
   }
   else
   {
      StartColumn--
      Loop, Parse, Text, `n, `r
      {
         If A_Index in %OK_TF_MatchList%
         {
            If (StartColumn > 0)
            {
               StringLeft Section1, A_LoopField, StartColumn
               StringMid Section2, A_LoopField, StartColumn+1
               If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
                  OutPut .= Section1 Section2 "`n"
            }
            Else
            {
               Section1:=SubStr(A_LoopField, 1, StrLen(A_LoopField) + StartColumn + 1)
               Section2:=SubStr(A_LoopField, StrLen(A_LoopField) + StartColumn + 2)
               If (Skip = 1) and (A_LoopField = "")
                  OutPut .= Section1 Section2 "`n"
            }
            OutPut .= Section1 InsertText Section2 "`n"
         }
         Else
            OutPut .= A_LoopField "`n"
      }
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; modified TF 3.4
OK_TF_ColCut(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   If RegExMatch(StartColumn, ",|\+|-")
   {
      StartColumn:=OK_TF__MakeMatchList(Text, StartColumn, EndColumn, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
      {
         If A_Index in %OK_TF_MatchList%
         {
            loop, parse, A_LoopField ; parsing LINE char by char
            {
               If A_Index not in %StartColumn% ; if col not in index get char
                  output .= A_LoopField
            }
            output .= "`n"
         }
         else
            output .= A_LoopField "`n"
      }
      output .= A_LoopField "`n"
   }
   else
   {
      StartColumn--
      EndColumn++
      Loop, Parse, Text, `n, `r
      {
         If A_Index in %OK_TF_MatchList%
         {
            StringLeft Section1, A_LoopField, StartColumn
            StringMid Section2, A_LoopField, EndColumn
            OutPut .= Section1 Section2 "`n"
         }
         Else
            OutPut .= A_LoopField "`n"
      }
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_ReverseLines(Text, StartLine = 1, EndLine = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   StringSplit Line, Text, `n, `r ; line0 is number of lines
   If (EndLine = 0 OR EndLine = "")
      EndLine:=Line0
   If (EndLine > Line0)
      EndLine:=Line0
   CountDown:=EndLine+1
   Loop, Parse, Text, `n, `r
   {
      If (A_Index < StartLine)
         Output1 .= A_LoopField "`n" ; section1
      If A_Index between %StartLine% and %Endline%
      {
         CountDown--
         Output2 .= Line%CountDown% "`n" section2
      }
      If (A_Index > EndLine)
         Output3 .= A_LoopField "`n"
   }
   OutPut.= Output1 Output2 Output3
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

;OK_TF_SplitFileByLines
;example:
;OK_TF_SplitFileByLines("TestFile.txt", "4", "sfile_", "txt", "1") ; split file every 3 lines
; InFile = 0 skip line e.g. do not include the actual line in any of the output files
; InFile = 1 include line IN current file
; InFile = 2 include line IN next file
OK_TF_SplitFileByLines(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
{
   LineCounter=1
   FileCounter=1
   Where:=SplitAt
   Method=1
   ; 1 = default, splitat every X lines,
   ; 2 = splitat: - rotating if applicable
   ; 3 = splitat: specific lines comma separated
   OK_TF_GetData(OW, Text, FileName)

   IfInString, SplitAt, `- ; method 2
   {
      StringSplit Split, SplitAt, `-
      Part=1
      Where:=Split%Part%
      Method=2
   }
   IfInString, SplitAt, `, ; method 3
   {
      StringSplit Split, SplitAt, `,
      Part=1
      Where:=Split%Part%
      Method=3
   }
   Loop, Parse, Text, `n, `r
   {
      OutPut .= A_LoopField "`n"
      If (LineCounter = Where)
      {
         If (InFile = 0)
         {
            StringReplace CheckOutput, PreviousOutput, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; skip empty files
               OK_TF_SetGlobal(Prefix FileCounter,PreviousOutput)
            Output:=
         }
         If (InFile = 1)
         {
            StringReplace CheckOutput, Output, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; skip empty files
               OK_TF_SetGlobal(Prefix FileCounter,Output)
            Output:=
         }
         If (InFile = 2)
         {
            OutPut := PreviousOutput
            StringReplace CheckOutput, Output, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; output to array
               OK_TF_SetGlobal(Prefix FileCounter,Output)
            OutPut := A_LoopField "`n"
         }
         If (Method <> 3)
            LineCounter=0 ; reset
         FileCounter++ ; next file
         Part++
         If (Method = 2) ; 2 = splitat: - rotating if applicable
         {
            If (Part > Split0)
            {
               Part=1
            }
            Where:=Split%Part%
         }
         If (Method = 3) ; 3 = splitat: specific lines comma separated
         {
            If (Part > Split0)
               Where:=Split%Split0%
            Else
               Where:=Split%Part%
         }
      }
      LineCounter++
      PreviousOutput:=Output
      PreviousLine:=A_LoopField
   }
   StringReplace CheckOutput, Output, `n, , All
   StringReplace CheckOutput, CheckOutput, `r, , All
   If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
      OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
   If (CheckOutput <> "") and (OW = 2) ; output to array
   {
      OK_TF_SetGlobal(Prefix FileCounter,Output)
      OK_TF_SetGlobal(Prefix . "0" , FileCounter)
   }
}

; OK_TF_SplitFileByText("TestFile.txt", "button", "sfile_", "txt") ; split file at every line with button in it, can be regexp
; InFile = 0 skip line e.g. do not include the actual line in any of the output files
; InFile = 1 include line IN current file
; InFile = 2 include line IN next file
OK_TF_SplitFileByText(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
{
   LineCounter=1
   FileCounter=1
   OK_TF_GetData(OW, Text, FileName)
   SplitPath TextFile,, Dir
   Loop, Parse, Text, `n, `r
   {
      OutPut .= A_LoopField "`n"
      FoundPos:=RegExMatch(A_LoopField, SplitAt)
      If (FoundPos > 0)
      {
         If (InFile = 0)
         {
            StringReplace CheckOutput, PreviousOutput, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; output to array
               OK_TF_SetGlobal(Prefix FileCounter,PreviousOutput)
            Output:=
         }
         If (InFile = 1)
         {
            StringReplace CheckOutput, Output, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; output to array
               OK_TF_SetGlobal(Prefix FileCounter,Output)
            Output:=
         }
         If (InFile = 2)
         {
            OutPut := PreviousOutput
            StringReplace CheckOutput, Output, `n, , All
            StringReplace CheckOutput, CheckOutput, `r, , All
            If (CheckOutput <> "") and (OW <> 2) ; skip empty files
               OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
            If (CheckOutput <> "") and (OW = 2) ; output to array
               OK_TF_SetGlobal(Prefix FileCounter,Output)
            OutPut := A_LoopField "`n"
         }
         LineCounter=0 ; reset
         FileCounter++ ; next file
      }
      LineCounter++
      PreviousOutput:=Output
      PreviousLine:=A_LoopField
   }
   StringReplace CheckOutput, Output, `n, , All
   StringReplace CheckOutput, CheckOutput, `r, , All
   If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
      OK_TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
   If (CheckOutput <> "") and (OW = 2) ; output to array
   {
      OK_TF_SetGlobal(Prefix FileCounter,Output)
      OK_TF_SetGlobal(Prefix . "0" , FileCounter)
   }
}

OK_TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
{
   options:="^[imsxADJUXPS]+\)"
   if RegExMatch(searchText,options,o)
      searchText:=RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0(*ANYCRLF)" : "$0"))
   else searchText:="m)(*ANYCRLF)" searchText
   options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze, see http://www.autohotkey.com/forum/viewtopic.php?t=60062
   if RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
   else searchText := "m)" . searchText

   OK_TF_GetData(OW, Text, FileName)
   If (RegExMatch(Text, SearchText) < 1)
      Return "0" ; SearchText not in file or error, so do nothing

   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         If (RegExMatch(A_LoopField, SearchText) > 0)
         {
            If (ReturnText = 0)
               Lines .= A_Index "," ; line number
            Else If (ReturnText = 1)
               Lines .= A_LoopField "`n" ; text of line
            Else If (ReturnText = 2)
               Lines .= A_Index ": " A_LoopField "`n" ; add line number
            If (ReturnFirst = 1) ; only return first occurrence
               Break
         }
      }
   }
   If (Lines <> "")
      StringTrimRight Lines, Lines, 1 ; trim trailing , or `n
   Else
      Lines = 0 ; make sure we return 0
   Return Lines
}

OK_TF_Prepend(File1, File2)
{
   FileList=
(
%File1%
%File2%
)
   OK_TF_Merge(FileList,"`n", "!" . File2)
   Return
}

OK_TF_Append(File1, File2)
{
   FileList=
(
%File2%
%File1%
)
   OK_TF_Merge(FileList,"`n", "!" . File2)
   Return
}

; For OK_TF_Merge You will need to create a Filelist variable, one file per line,
; to pass on to the function:
; FileList=
; (
; c:\file1.txt
; c:\file2.txt
; )
; use Loop (files & folders) to create one quickly if you want to merge all TXT files for example
;
; Loop, c:\*.txt
;   FileList .= A_LoopFileFullPath "`n"
;
; By default, a new line is used as a separator between two text files
; !merged.txt deletes target file before starting to merge files
OK_TF_Merge(FileList, Separator = "`n", FileName = "merged.txt")
{
   OW=0
   Loop, Parse, FileList, `n, `r
   {
      Append2File= ; Just make sure it is empty
      IfExist, %A_LoopField%
      {
         FileRead Append2File, %A_LoopField%
         If not ErrorLevel ; Successfully loaded
            Output .= Append2File Separator
      }
   }

   If (SubStr(FileName,1,1)="!") ; check if we want to delete the target file before we start
   {
      FileName:=SubStr(FileName,2)
      OW=1
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName, 0, 1)
}

OK_TF_Wrap(Text, Columns = 80, AllowBreak = 0, StartLine = 1, EndLine = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   If (AllowBreak = 1)
      Break=
   Else
      Break=[ \r?\n]
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         If (StrLen(A_LoopField) > Columns)
         {
            LoopField := A_LoopField " " ; just seems to work better by adding a space
            OutPut .= RegExReplace(LoopField, "(.{1," . Columns . "})" . Break , "$1`n")
         }
         Else
            OutPut .= A_LoopField "`n"
      }
      Else
         OutPut .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

OK_TF_WhiteSpace(Text, RemoveLeading = 1, RemoveTrailing = 1, StartLine = 1, EndLine = 0) {
   OK_TF_GetData(OW, Text, FileName)
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
   Trim:=A_AutoTrim ; store trim settings
   AutoTrim On ; make sure AutoTrim is on
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         If (RemoveLeading = 1) AND (RemoveTrailing = 1)
         {
            LoopField = %A_LoopField%
            Output .= LoopField "`n"
            Continue
         }
         If (RemoveLeading = 1) AND (RemoveTrailing = 0)
         {
            LoopField := A_LoopField . "."
            LoopField = %LoopField%
            StringTrimRight LoopField, LoopField, 1
            Output .= LoopField "`n"
            Continue
         }
         If (RemoveLeading = 0) AND (RemoveTrailing = 1)
         {
            LoopField := "." A_LoopField
            LoopField = %LoopField%
            StringTrimLeft LoopField, LoopField, 1
            Output .= LoopField "`n"
            Continue
         }
         If (RemoveLeading = 0) AND (RemoveTrailing = 0)
         {
            Output .= A_LoopField "`n"
            Continue
         }
      }
      Else
         Output .= A_LoopField "`n"
   }
   AutoTrim %Trim%	; restore original Trim
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; Delete lines from file1 in file2 (using StringReplace)
; Partialmatch = 2 added in 3.4
OK_TF_Substract(File1, File2, PartialMatch = 0) {
   Text:=File1
   OK_TF_GetData(OW, Text, FileName)
   Str1:=Text
   Text:=File2
   OK_TF_GetData(OW, Text, FileName)
   OutPut:=Text
   If (OW = 2)
      File1= ; free mem in case of var/text
   OutPut .= "`n" ; just to make sure the StringReplace will work

   If (PartialMatch = 2)
   {
      Loop, Parse, Str1, `n, `r
      {
         IfInString, Output, %A_LoopField%
         {
            Output:= RegExReplace(Output, "im)^.*" . A_LoopField . ".*\r?\n?", replace)
         }
      }
   }
   Else If (PartialMatch = 1) ; allow paRTIal match
   {
      Loop, Parse, Str1, `n, `r
         StringReplace Output, Output, %A_LoopField%, , All ; remove lines from file1 in file2
   }
   Else If (PartialMatch = 0)
   {
      search:="m)^(.*)$"
      replace=__bol__$1__eol__
      Output:=RegExReplace(Output, search, replace)
      StringReplace Output, Output, `n__eol__,__eol__ , All ; strange fix but seems to be needed.
      Loop, Parse, Str1, `n, `r
         StringReplace Output, Output, __bol__%A_LoopField%__eol__, , All ; remove lines from file1 in file2
   }
   If (PartialMatch = 0)
   {
      StringReplace Output, Output, __bol__, , All
      StringReplace Output, Output, __eol__, , All
   }

   ; Remove all blank lines from the text in a variable:
   Loop
   {
      StringReplace Output, Output, `r`n`r`n, `r`n, UseErrorLevel
      if (ErrorLevel = 0) or (ErrorLevel = 1) ; No more replacements needed.
         break
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName, 0)
}

; Similar to "BK Replace EM" RangeReplace
OK_TF_RangeReplace(Text, SearchTextBegin, SearchTextEnd, ReplaceText = "", CaseSensitive = "False", KeepBegin = 0, KeepEnd = 0)
{
   OK_TF_GetData(OW, Text, FileName)
   IfNotInString, Text, %SearchText%
      Return Text ; SearchTextBegin not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
   Start = 0
   End = 0
   If (KeepBegin = 1)
      KeepBegin:=SearchTextBegin
   Else
      KeepBegin=
   If (KeepEnd = 1)
      KeepEnd:= SearchTextEnd
   Else
      KeepEnd=
   If (SearchTextBegin = "")
      Start=1
   If (SearchTextEnd = "")
      End=2

   Loop, Parse, Text, `n, `r
   {
      If (End = 1) ; end has been found already, replacement made simply continue to add all lines
      {
         Output .= A_LoopField "`n"
         Continue
      }
      If (Start = 0) ; start hasn't been found
      {
         If (InStr(A_LoopField,SearchTextBegin,CaseSensitive)) ; start has been found
         {
            Start = 1
            KeepSection := SubStr(A_LoopField, 1, InStr(A_LoopField, SearchTextBegin)-1)
            EndSection := SubStr(A_LoopField, InStr(A_LoopField, SearchTextBegin)-1)
            ; check if SearchEndText is in second part of line
            If (InStr(EndSection,SearchTextEnd,CaseSensitive)) ; end found
            {
               EndSection := ReplaceText KeepEnd SubStr(EndSection, InStr(EndSection, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
               If (End <> 2)
                  End=1
               If (End = 2)
                  EndSection=
            }
            Else
               EndSection=
            Output .= KeepSection KeepBegin EndSection
            Continue
         }
         Else
            Output .= A_LoopField "`n" ; if not found yet simply add
      }
      If (Start = 1) and (End <> 2) ; start has been found, now look for end if end isn't an empty string
      {
         If (InStr(A_LoopField,SearchTextEnd,CaseSensitive)) ; end found
         {
            End = 1
            Output .= ReplaceText KeepEnd SubStr(A_LoopField, InStr(A_LoopField, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
         }
      }
   }
   If (End = 2)
      Output .= ReplaceText
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

; Create file of X lines and Y columns, fill with space or other character(s)
OK_TF_MakeFile(Text, Lines = 1, Columns = 1, Fill = " ")
{
   OW=1
   If (Text = "") ; if OutPutFile is empty return as variable
      OW=2
   Loop, % Columns
      Cols .= Fill
   Loop, % Lines
      Output .= Cols "`n"
   Return OK_TF_ReturnOutPut(OW, OutPut, Text, 1, 1)
}

; Convert tabs to spaces, shorthand for OK_TF_ReplaceInLines
OK_TF_Tab2Spaces(Text, TabStop = 4, StartLine = 1, EndLine =0)
{
   Loop, % TabStop
      Replace .= A_Space
   Return OK_TF_ReplaceInLines(Text, StartLine, EndLine, A_Tab, Replace)
}

; Convert spaces to tabs, shorthand for OK_TF_ReplaceInLines
OK_TF_Spaces2Tab(Text, TabStop = 4, StartLine = 1, EndLine =0)
{
   Loop, % TabStop
      Replace .= A_Space
   Return OK_TF_ReplaceInLines(Text, StartLine, EndLine, Replace, A_Tab)
}

; Sort (section of) a text file
OK_TF_Sort(Text, SortOptions = "", StartLine = 1, EndLine = 0) ; use the SORT options http://www.autohotkey.com/docs/commands/Sort.htm
{
   OK_TF_GetData(OW, Text, FileName)
   If StartLine contains -,+,`, ; no sections, incremental or multiple line input
      Return
   If (StartLine = 1) and (Endline = 0) ; process entire file
   {
      Output:=Text
      Sort Output, %SortOptions%
   }
   Else
   {
      Output := OK_TF_ReadLines(Text, 1, StartLine-1) ; get first section
      ToSort := OK_TF_ReadLines(Text, StartLine, EndLine) ; get section to sort
      Sort ToSort, %SortOptions%
      OutPut .= ToSort
      OutPut .= OK_TF_ReadLines(Text, EndLine+1) ; append last section
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName, 0) ; https://github.com/hi5/TF/issues/11
}

OK_TF_Tail(Text, Lines = 1, RemoveTrailing = 0, ReturnEmpty = 1)
{
   OK_TF_GetData(OW, Text, FileName)
   Neg = 0
   If (Lines < 0)
   {
      Neg=1
      Lines:= Lines * -1
   }
   If (ReturnEmpty = 0) ; remove blank lines first so we can't return any blank lines anyway
   {
      Loop, Parse, Text, `n, `r
         OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
      StringTrimRight OutPut, OutPut, 1 ; remove trailing `n added by loop above
      Text:=OutPut
      OutPut=
   }
   If (Neg = 1) ; get only one line!
   {
      Lines++
      Output:=Text
      StringGetPos Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
      StringTrimLeft Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
      StringGetPos Pos, Output, `n
      StringLeft Output, Output, % Pos
      Output .= "`n"
   }
   Else
   {
      Output:=Text
      StringGetPos Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
      StringTrimLeft Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
      Output .= "`n"
   }
   OW = 2 ; make sure we return variable not process file
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName, RemoveTrailing)
}

OK_TF_Count(String, Char)
{
   StringReplace String, String, %Char%,, UseErrorLevel
   Return ErrorLevel
}

OK_TF_Save(Text, FileName, OverWrite = 1) { ; HugoV write file
   Return OK_TF_ReturnOutPut(OverWrite, Text, FileName, 0, 1)
}

OK_TF(TextFile, CreateGlobalVar = "T") { ; read contents of file in output and %output% as global var ...  http://www.autohotkey.com/forum/viewtopic.php?p=313120#313120
   global
   FileRead %CreateGlobalVar%, %TextFile%
   Return, (%CreateGlobalVar%)
}

; OK_TF_Join
; SmartJoin: Detect if CHAR(s) is/are already present at the end of the line before joining the next, this to prevent unnecessary double spaces for example.
; Char: character(s) to use between new lines, defaults to a space. To use nothing use ""
OK_TF_Join(Text, StartLine = 1, EndLine = 0, SmartJoin = 0, Char = 0)
{
   If ( (InStr(StartLine,",") > 0) AND (InStr(StartLine,"-") = 0) ) OR (InStr(StartLine,"+") > 0)
      Return Text ; can't do multiplelines, only multiple sections of lines e.g. "1,5" bad "1-5,15-10" good, "2+2" also bad
   OK_TF_GetData(OW, Text, FileName)
   If (InStr(Text,"`n") = 0)
      Return Text ; there are no lines to join so just return Text
   If (InStr(StartLine,"-") > 0)	; OK, we need some counter-intuitive string mashing to substract ONE from the "endline" parameter
   {
      Loop, Parse, StartLine, CSV
      {
         StringSplit part, A_LoopField, -
         NewStartLine .= part1 "-" (part2-1) ","
      }
      StringTrimRight StartLine, NewStartLine, 1
   }
   If (Endline > 0)
      Endline--
   OK_TF_MatchList:=OK_TF__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc)
   If (Char = 0)
      Char:=A_Space
   Char_Org:=Char
   GetRightLen:=StrLen(Char)-1
   Loop, Parse, Text, `n, `r
   {
      If A_Index in %OK_TF_MatchList%
      {
         If (SmartJoin = 1)
         {
            GetRightText:=SubStr(A_LoopField,0)
            If (GetRightText = Char)
               Char=
         }
         Output .= A_LoopField Char
         Char:=Char_Org
      }
      Else
         Output .= A_LoopField "`n"
   }
   Return OK_TF_ReturnOutPut(OW, OutPut, FileName)
}

;----- Helper functions ----------------

OK_TF_SetGlobal(var, content = "") ; helper function for OK_TF_Split* to return array and not files, credits Tuncay :-)
{
   global
   %var% := content
}

; Helper function to determine if VAR/TEXT or FILE is passed to TF
; Update 11 January 2010 (skip filecheck if `n in Text -> can't be file)
OK_TF_GetData(byref OW, byref Text, byref FileName)
{
   If (text = 0 "") ; v3.6 -> v3.7 https://github.com/hi5/TF/issues/4 and https://autohotkey.com/boards/viewtopic.php?p=142166#p142166 in case user passes on zero/zeros ("0000") as text - will error out when passing on one 0 and there is no file with that name
   {
      IfNotExist, %Text% ; additional check to see if a file 0 exists
      {
         MsgBox 48, TF Lib Error, % "Read Error - possible reasons (see documentation):`n- Perhaps you used !""file.txt"" vs ""!file.txt""`n- A single zero (0) was passed on to a TF function as text"
         ExitApp
      }
   }
   OW=0 ; default setting: asume it is a file and create file_copy
   IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
   {
      If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
      {
         Text:=SubStr(Text,2)
         OW=1 ; overwrite file (if it is a file)
      }
      IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
      {
         If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
            Text:= "!" . Text
         OW=2 ; no file, so it is a var or Text passed on directly to TF
      }
   }
   Else ; there is a newline character in Text so it has to be a variable
   {
      OW=2
   }
   If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
   {
      Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
      FileName=%Text% ; Store FileName
      FileRead Text, %Text% ; Read file and return as var Text
      If (ErrorLevel > 0)
      {
         MsgBox 48, TF Lib Error, % "Can not read " FileName
         ExitApp
      }
   }
   Return
}

; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
; SetWidth() : SetWidth increases a String's length by adding spaces to it and aligns it Left/Center/Right. ( Requires Space() )
OK_TF_SetWidth(Text,Width,AlignText)
{
   If (AlignText!=0 and AlignText!=1 and AlignText!=2)
      AlignText=0
   If AlignText=0
   {
      RetStr= % (Text)OK_TF_Space(Width)
      StringLeft RetText, RetText, %Width%
   }
   If AlignText=1
   {
      Spaces:=(Width-(StrLen(Text)))
      RetStr= % OK_TF_Space(Round(Spaces/2))(Text)OK_TF_Space(Spaces-(Round(Spaces/2)))
   }
   If AlignText=2
   {
      RetStr= % OK_TF_Space(Width)(Text)
      StringRight RetStr, RetStr, %Width%
   }
   Return RetStr
}

; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
OK_TF_Space(Width)
{
   Loop,%Width%
      Space=% Space Chr(32)
   Return Space
}

; Write to file or return variable depending on input
OK_TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) {
   If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
   {
      IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
      {
         If (CreateNewFile = 1) ; CreateNewFile used for OK_TF_SplitFileBy* and others
         {
            OW = 1
            Goto CreateNewFile
         }
         Else
            Return
      }
      If (TrimTrailing = 1)
         StringTrimRight Text, Text, 1 ; remove trailing `n
      SplitPath FileName,, Dir, Ext, Name
      If (Dir = "") ; if Dir is empty Text & script are in same directory
         Dir := A_WorkingDir
      IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
         FileCopy % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
      FileDelete % Dir "\" Name "_copy." Ext
      FileAppend %Text%, % Dir "\" Name "_copy." Ext
      Return Errorlevel ? False : True
   }
   CreateNewFile:
   If (OW = 1) ; input was file, will be overwritten by output
   {
      IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
      {
         If (CreateNewFile = 0) ; CreateNewFile used for OK_TF_SplitFileBy* and others
            Return
      }
      If (TrimTrailing = 1)
         StringTrimRight Text, Text, 1 ; remove trailing `n
      SplitPath FileName,, Dir, Ext, Name
      If (Dir = "") ; if Dir is empty Text & script are in same directory
         Dir := A_WorkingDir
      IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
         FileCopy % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
      FileDelete % Dir "\" Name "." Ext
      FileAppend %Text%, % Dir "\" Name "." Ext
      Return Errorlevel ? False : True
   }
   If (OW = 2) ; input was var, return variable
   {
      If (TrimTrailing = 1)
         StringTrimRight Text, Text, 1 ; remove trailing `n
      Return Text
   }
}

; OK_TF__MakeMatchList()
; Purpose:
; Make a MatchList which is used in various functions
; Using a MatchList gives greater flexibility so you can process multiple
; sections of lines in one go avoiding repetitive fileread/append actions
; For TF 3.4 added COL = 0/1 option (for OK_TF_Col* functions) and CallFunc for
; all OK_TF_* functions to facilitate bug tracking
OK_TF__MakeMatchList(Text, Start = 1, End = 0, Col = 0, CallFunc = "Not available")
{
   ErrorList=
   (join|
Error 01: Invalid StartLine parameter (non numerical character)`nFunction used: %CallFunc%
Error 02: Invalid EndLine parameter (non numerical character)`nFunction used: %CallFunc%
Error 03: Invalid StartLine parameter (only one + allowed)`nFunction used: %CallFunc%
   )
   StringSplit ErrorMessage, ErrorList, |
   Error = 0

   If (Col = 1)
   {
      LongestLine:=OK_TF_Stat(Text)
      If (End > LongestLine) or (End = 1) ; FIXITHERE BUG
         End:=LongestLine
   }

   OK_TF_MatchList= ; just to be sure
   If (Start = 0 or Start = "")
      Start = 1

   ; some basic error checking

   ; error: only digits - and + allowed
   If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
      Error = 1

   If (RegExReplace(End, "[0-9 ]", "") <> "")
      Error = 2

   ; error: only one + allowed
   If (OK_TF_Count(Start,"+") > 1)
      Error = 3

   If (Error > 0 )
   {
      MsgBox 48, TF Lib Error, % ErrorMessage%Error%
      ExitApp
   }

   ; Option #0 [ added 30-Oct-2010 ]
   ; Startline has negative value so process X last lines of file
   ; endline parameter ignored

   If (Start < 0) ; remove last X lines from file, endline parameter ignored
   {
      Start:=OK_TF_CountLines(Text) + Start + 1
      End=0 ; now continue
   }

   ; Option #1
   ; StartLine has + character indicating startline + incremental processing.
   ; EndLine will be used
   ; Make OK_TF_MatchList

   IfInString, Start, `+
   {
      If (End = 0 or End = "") ; determine number of lines
         End:= OK_TF_Count(Text, "`n") + 1
      StringSplit Section, Start, `, ; we need to create a new "OK_TF_MatchList" so we split by ,
      Loop, %Section0%
      {
         StringSplit SectionLines, Section%A_Index%, `+
         LoopSection:=End + 1 - SectionLines1
         Counter=0
         OK_TF_MatchList .= SectionLines1 ","
         Loop, %LoopSection%
         {
            If (A_Index >= End) ;
               Break
            If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
            {
               OK_TF_MatchList .= (SectionLines1 + A_Index) ","
               Counter=0
            }
            Else
               Counter++
         }
      }
      StringTrimRight OK_TF_MatchList, OK_TF_MatchList, 1 ; remove trailing ,
      Return OK_TF_MatchList
   }

   ; Option #2
   ; StartLine has - character indicating from-to, COULD be multiple sections.
   ; EndLine will be ignored
   ; Make OK_TF_MatchList

   IfInString, Start, `-
   {
      StringSplit Section, Start, `, ; we need to create a new "OK_TF_MatchList" so we split by ,
      Loop, %Section0%
      {
         StringSplit SectionLines, Section%A_Index%, `-
         LoopSection:=SectionLines2 + 1 - SectionLines1
         Loop, %LoopSection%
         {
            OK_TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
         }
      }
      StringTrimRight OK_TF_MatchList, OK_TF_MatchList, 1 ; remove trailing ,
      Return OK_TF_MatchList
   }

   ; Option #3
   ; StartLine has comma indicating multiple lines.
   ; EndLine will be ignored

   IfInString, Start, `,
   {
      OK_TF_MatchList:=Start
      Return OK_TF_MatchList
   }

   ; Option #4
   ; parameters passed on as StartLine, EndLine.
   ; Make OK_TF_MatchList from StartLine to EndLine

   If (End = 0 or End = "") ; determine number of lines
      End:= OK_TF_Count(Text, "`n") + 1
   LoopTimes:=End-Start
   Loop, %LoopTimes%
   {
      OK_TF_MatchList .= (Start - 1 + A_Index) ","
   }
   OK_TF_MatchList .= End ","
   StringTrimRight OK_TF_MatchList, OK_TF_MatchList, 1 ; remove trailing ,
   Return OK_TF_MatchList
}

; added for TF 3.4 col functions - currently only gets longest line may change in future
OK_TF_Stat(Text)
{
   OK_TF_GetData(OW, Text, FileName)
   Sort Text, f OK_TF__AscendingLinesL
   Pos:=InStr(Text,"`n")-1
   Return pos
}

OK_TF__AscendingLinesL(a1, a2) ; used by OK_TF_Stat
{
   Return StrLen(a2) - StrLen(a1)
}

/* -------------- */

; License:

;                     GNU GENERAL PUBLIC LICENSE
;                        Version 2, June 1991
;
;  Copyright (C) 1989, 1991 Free Software Foundation, Inc.
;  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;  Everyone is permitted to copy and distribute verbatim copies
;  of this license document, but changing it is not allowed.
;
;                             Preamble
;
;   The licenses for most software are designed to take away your
; freedom to share and change it. By contrast, the GNU General Public
; License is intended to guarantee your freedom to share and change free
; software--to make sure the software is free for all its users. This
; General Public License applies to most of the Free Software
; Foundation's software and to any other program whose authors commit to
; using it. (Some other Free Software Foundation software is covered by
; the GNU Library General Public License instead.) You can apply it to
; your programs, too.
;
;   When we speak of free software, we are referring to freedom, not
; price. Our General Public Licenses are designed to make sure that you
; have the freedom to distribute copies of free software (and charge for
; this service if you wish), that you receive source code or can get it
; if you want it, that you can change the software or use pieces of it
; in new free programs; and that you know you can do these things.
;
;   To protect your rights, we need to make restrictions that forbid
; anyone to deny you these rights or to ask you to surrender the rights.
; These restrictions translate to certain responsibilities for you if you
; distribute copies of the software, or if you modify it.
;
;   For example, if you distribute copies of such a program, whether
; gratis or for a fee, you must give the recipients all the rights that
; you have. You must make sure that they, too, receive or can get the
; source code. And you must show them these terms so they know their
; rights.
;
;   We protect your rights with two steps: (1) copyright the software, and
; (2) offer you this license which gives you legal permission to copy,
; distribute and/or modify the software.
;
;   Also, for each author's protection and ours, we want to make certain
; that everyone understands that there is no warranty for this free
; software. If the software is modified by someone else and passed on, we
; want its recipients to know that what they have is not the original, so
; that any problems introduced by others will not reflect on the original
; authors' reputations.
;
;   Finally, any free program is threatened constantly by software
; patents. We wish to avoid the danger that redistributors of a free
; program will individually obtain patent licenses, in effect making the
; program proprietary. To prevent this, we have made it clear that any
; patent must be licensed for everyone's free use or not licensed at all.
;
;   The precise terms and conditions for copying, distribution and
; modification follow.
;
;                     GNU GENERAL PUBLIC LICENSE
;    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
;
;   0. This License applies to any program or other work which contains
; a notice placed by the copyright holder saying it may be distributed
; under the terms of this General Public License. The "Program", below,
; refers to any such program or work, and a "work based on the Program"
; means either the Program or any derivative work under copyright law:
; that is to say, a work containing the Program or a portion of it,
; either verbatim or with modifications and/or translated into another
; language. (Hereinafter, translation is included without limitation in
; the term "modification".) Each licensee is addressed as "you".
;
; Activities other than copying, distribution and modification are not
; covered by this License; they are outside its scope. The act of
; running the Program is not restricted, and the output from the Program
; is covered only if its contents constitute a work based on the
; Program (independent of having been made by running the Program).
; Whether that is true depends on what the Program does.
;
;   1. You may copy and distribute verbatim copies of the Program's
; source code as you receive it, in any medium, provided that you
; conspicuously and appropriately publish on each copy an appropriate
; copyright notice and disclaimer of warranty; keep intact all the
; notices that refer to this License and to the absence of any warranty;
; and give any other recipients of the Program a copy of this License
; along with the Program.
;
; You may charge a fee for the physical act of transferring a copy, and
; you may at your option offer warranty protection in exchange for a fee.
;
;   2. You may modify your copy or copies of the Program or any portion
; of it, thus forming a work based on the Program, and copy and
; distribute such modifications or work under the terms of Section 1
; above, provided that you also meet all of these conditions:
;
;     a) You must cause the modified files to carry prominent notices
;     stating that you changed the files and the date of any change.
;
;     b) You must cause any work that you distribute or publish, that in
;     whole or in part contains or is derived from the Program or any
;     part thereof, to be licensed as a whole at no charge to all third
;     parties under the terms of this License.
;
;     c) If the modified program normally reads commands interactively
;     when run, you must cause it, when started running for such
;     interactive use in the most ordinary way, to print or display an
;     announcement including an appropriate copyright notice and a
;     notice that there is no warranty (or else, saying that you provide
;     a warranty) and that users may redistribute the program under
;     these conditions, and telling the user how to view a copy of this
;     License. (Exception: if the Program itself is interactive but
;     does not normally print such an announcement, your work based on
;     the Program is not required to print an announcement.)
;
; These requirements apply to the modified work as a whole. If
; identifiable sections of that work are not derived from the Program,
; and can be reasonably considered independent and separate works in
; themselves, then this License, and its terms, do not apply to those
; sections when you distribute them as separate works. But when you
; distribute the same sections as part of a whole which is a work based
; on the Program, the distribution of the whole must be on the terms of
; this License, whose permissions for other licensees extend to the
; entire whole, and thus to each and every part regardless of who wrote it.
;
; Thus, it is not the intent of this section to claim rights or contest
; your rights to work written entirely by you; rather, the intent is to
; exercise the right to control the distribution of derivative or
; collective works based on the Program.
;
; In addition, mere aggregation of another work not based on the Program
; with the Program (or with a work based on the Program) on a volume of
; a storage or distribution medium does not bring the other work under
; the scope of this License.
;
;   3. You may copy and distribute the Program (or a work based on it,
; under Section 2) in object code or executable form under the terms of
; Sections 1 and 2 above provided that you also do one of the following:
;
;     a) Accompany it with the complete corresponding machine-readable
;     source code, which must be distributed under the terms of Sections
;     1 and 2 above on a medium customarily used for software interchange; or,
;
;     b) Accompany it with a written offer, valid for at least three
;     years, to give any third party, for a charge no more than your
;     cost of physically performing source distribution, a complete
;     machine-readable copy of the corresponding source code, to be
;     distributed under the terms of Sections 1 and 2 above on a medium
;     customarily used for software interchange; or,
;
;     c) Accompany it with the information you received as to the offer
;     to distribute corresponding source code. (This alternative is
;     allowed only for noncommercial distribution and only if you
;     received the program in object code or executable form with such
;     an offer, in accord with Subsection b above.)
;
; The source code for a work means the preferred form of the work for
; making modifications to it. For an executable work, complete source
; code means all the source code for all modules it contains, plus any
; associated interface definition files, plus the scripts used to
; control compilation and installation of the executable. However, as a
; special exception, the source code distributed need not include
; anything that is normally distributed (in either source or binary
; form) with the major components (compiler, kernel, and so on) of the
; operating system on which the executable runs, unless that component
; itself accompanies the executable.
;
; If distribution of executable or object code is made by offering
; access to copy from a designated place, then offering equivalent
; access to copy the source code from the same place counts as
; distribution of the source code, even though third parties are not
; compelled to copy the source along with the object code.
;
;   4. You may not copy, modify, sublicense, or distribute the Program
; except as expressly provided under this License. Any attempt
; otherwise to copy, modify, sublicense or distribute the Program is
; void, and will automatically terminate your rights under this License.
; However, parties who have received copies, or rights, from you under
; this License will not have their licenses terminated so long as such
; parties remain in full compliance.
;
;   5. You are not required to accept this License, since you have not
; signed it. However, nothing else grants you permission to modify or
; distribute the Program or its derivative works. These actions are
; prohibited by law if you do not accept this License. Therefore, by
; modifying or distributing the Program (or any work based on the
; Program), you indicate your acceptance of this License to do so, and
; all its terms and conditions for copying, distributing or modifying
; the Program or works based on it.
;
;   6. Each time you redistribute the Program (or any work based on the
; Program), the recipient automatically receives a license from the
; original licensor to copy, distribute or modify the Program subject to
; these terms and conditions. You may not impose any further
; restrictions on the recipients' exercise of the rights granted herein.
; You are not responsible for enforcing compliance by third parties to
; this License.
;
;   7. If, as a consequence of a court judgment or allegation of patent
; infringement or for any other reason (not limited to patent issues),
; conditions are imposed on you (whether by court order, agreement or
; otherwise) that contradict the conditions of this License, they do not
; excuse you from the conditions of this License. If you cannot
; distribute so as to satisfy simultaneously your obligations under this
; License and any other pertinent obligations, then as a consequence you
; may not distribute the Program at all. For example, if a patent
; license would not permit royalty-free redistribution of the Program by
; all those who receive copies directly or indirectly through you, then
; the only way you could satisfy both it and this License would be to
; refrain entirely from distribution of the Program.
;
; If any portion of this section is held invalid or unenforceable under
; any particular circumstance, the balance of the section is intended to
; apply and the section as a whole is intended to apply in other
; circumstances.
;
; It is not the purpose of this section to induce you to infringe any
; patents or other property right claims or to contest validity of any
; such claims; this section has the sole purpose of protecting the
; integrity of the free software distribution system, which is
; implemented by public license practices. Many people have made
; generous contributions to the wide range of software distributed
; through that system in reliance on consistent application of that
; system; it is up to the author/donor to decide if he or she is willing
; to distribute software through any other system and a licensee cannot
; impose that choice.
;
; This section is intended to make thoroughly clear what is believed to
; be a consequence of the rest of this License.
;
;   8. If the distribution and/or use of the Program is restricted in
; certain countries either by patents or by copyrighted interfaces, the
; original copyright holder who places the Program under this License
; may add an explicit geographical distribution limitation excluding
; those countries, so that distribution is permitted only in or among
; countries not thus excluded. In such case, this License incorporates
; the limitation as if written in the body of this License.
;
;   9. The Free Software Foundation may publish revised and/or new versions
; of the General Public License from time to time. Such new versions will
; be similar in spirit to the present version, but may differ in detail to
; address new problems or concerns.
;
; Each version is given a distinguishing version number. If the Program
; specifies a version number of this License which applies to it and "any
; later version", you have the option of following the terms and conditions
; either of that version or of any later version published by the Free
; Software Foundation. If the Program does not specify a version number of
; this License, you may choose any version ever published by the Free Software
; Foundation.
;
;   10. If you wish to incorporate parts of the Program into other free
; programs whose distribution conditions are different, write to the author
; to ask for permission. For software which is copyrighted by the Free
; Software Foundation, write to the Free Software Foundation; we sometimes
; make exceptions for this. Our decision will be guided by the two goals
; of preserving the free status of all derivatives of our free software and
; of promoting the sharing and reuse of software generally.
;
;                             NO WARRANTY
;
;   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
; FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
; OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
; PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
; OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS
; TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE
; PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
; REPAIR OR CORRECTION.
;
;   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
; WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
; REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
; INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
; OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
; TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
; YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
; PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGES.
;
;                      END OF TERMS AND CONDITIONS

; --uID:1865426853
