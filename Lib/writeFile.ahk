; #region:writeFile (3352591673)

; #region:Metadata:
; Snippet: writeFile;  (v.1.0)
;  10 April 2023
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: MIT
; --------------------------------------------------------------
; Library: Personal Library
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: encoding, UTF-8/UTF-8-RAW
; #endregion:Metadata

; #region:Description:
; Small function for writing files to disk in a safe manner when requiring specific file encodings or flags.
; Allows f.e. UTF-8 filewrites
; #endregion:Description

; #region:Example
; Loop, Files, % Folder "\*." script.config.Config.filetype, F
;         {
;             scriptWorkingDir:=renameFile(A_LoopFileFullPath,Arr[A_Index],true,A_Index,TrueNumberOfFiles)
;             writeFile(scriptWorkingDir "\gfa_renamer_log.txt",Files, "UTF-8-RAW","w",true)
;         }
; #endregion:Example

; #region:Code
writeFile(Path,Content,Encoding:="",Flags:=0x2,bSafeOverwrite:=false) {
    if (bSafeOverwrite && FileExist(Path)) {
        ; if we want to ensure nonexistance.
        FileDelete % Path
    }
    if (Encoding!="") {
        if (fObj:=FileOpen(Path,Flags,Encoding)) {
            fObj.Write(Content) ;; insert contents
            fObj.Close() ;; close file
        }
        else {

            throw Exception("File could not be opened. Flags: " Flags "`nPath: " Path, -1, Path)
        }
    } else {
        if (fObj:=FileOpen(Path,Flags)) {
            fObj.Write(Content) ;; insert contents
            fObj.Close() ;; close file
        } else {
            throw Exception("File could not be opened. Flags: " Flags "`nPath: " Path, -1, Path)
        }
    }
    return
}
; #endregion:Code

; #endregion:writeFile (3352591673)
