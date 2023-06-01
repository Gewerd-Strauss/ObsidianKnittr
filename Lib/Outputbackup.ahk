backupOutput(Path, manuscriptName, out) {
    SplitPath % Path, ,OutputRoot
    Name:=(manuscriptName!=""?manuscriptName:"index")
    Copied:=0
    for _, output_type in out.sel {
        if InStr(output_type,"word_document") {
            FileSuffix:="docx"
        } else {
            FileSuffix:=strsplit(output_type,"_").1
            if InStr(FileSuffix,"::") {

                FileSuffix:=strsplit(FileSuffix,"::").2
            }
        }
        Output_File:=OutputRoot "\" Name "." FileSuffix
        BackupDirectory:=OutputRoot "\Old_Versions"

        if !InStr(FileExist(BackupDirectory),"D") {
            FileCreateDir % BackupDirectory
        }
        bOutputExists:=FileExist(Output_File)
        if (bOutputExists!="") {
            if (MT="") {
                FileGetTime MT,% Output_File,M
                FileGetTime CT,% Output_File,C
                FormatTime CT,%CT%,yyyy-MM-dd HHmmss
                FormatTime MT,%MT%,yyyy-MM-dd HHmmss
            }
            bOutputFolderExists:=FileExist(BackupDirectory "\" MT)
            if (bOutputFolderExists="") {
                FileCreateDir % BackupDirectory "\" MT
            } else {
                if (bOutputFolderExists!="D") { ;; directory exists
                    FileCreateDir % BackupDirectory "\" MT
                }
            }
            FileCopy % Output_File, % BackupDirectory "\" MT "\" Name "." FileSuffix
            Copied++
        } else {

        }
    }
    if (Copied) {
        Output_Log_Source:=OutputRoot "\Executionlog.txt"
        Output_Log_Dest:=BackupDirectory "\" MT "\" Name "_Log.txt"
        FileMove % Output_Log_Source, % Output_Log_Dest,1
    }
    return BackupDirectory
}
limitBackups(BackupDirectory,Limit) {
    backupCount:=0
    Arr:={}
    Loop, Files, % BackupDirectory "\*", D 
    {
        backupCount++
        Arr[A_LoopFileName]:=A_LoopFileFullPath
    }
    Arr2:={}
    for _, Path in Arr {
        Arr2.push(Path)
    }
    if Arr2.Count()>Limit {
        Diff:=Arr2.Count()-Limit
        loop, % Diff {
            FileRemoveDir % Arr2[A_Index] "\",% true
        }

    }
    /*
    1. get number of backup subfolders 
    2. if number greater 'Count', get the remainder
    3. Get the 'remainder' number of oldest subfolders and 'FileRemoveDir' them
    */
    return
}

; #region:FindFreeFileName() (1452864709)

; #region:Metadata:
; Snippet: FindFreeFileName()
; 09 Oktober 2022
; License: WTFPL
; --------------------------------------------------------------
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Finds a non-existing filename for Filepath by appending a number in brackets to the name
;
;
; #endregion:Description

; #region:Code
FindFreeFileName(FilePath) {																                                                                    	;-- Finds a non-existing filename for Filepath by appending a number in brackets to the name

    SplitPath FilePath, , dir, extension, filename
    TestPath := FilePath ;Return path if it doesn't exist
    i := 1
    while FileExist(TestPath) {
        i++
        TestPath := dir "\" filename " (" i ")" (extension = "" ? "" : "." extension)
    }
    return TestPath
}
; #endregion:Code


; #endregion:FindFreeFileName() (1452864
