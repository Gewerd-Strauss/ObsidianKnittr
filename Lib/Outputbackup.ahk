backupOutput(Path, manuscriptName, out) {
    SplitPath % Path, ,OutputRoot
    Name:=(manuscriptName!=""?manuscriptName:"index")
    Copied:=0
    for _, output_type in out.sel {
        FileSuffix:=strsplit(output_type,"_").1
        Output_File:=OutputRoot "\" Name "." FileSuffix
        bOutputExists:=FileExist(Output_File)

        if (bOutputExists!="") {
            BackupDirectory:=OutputRoot "\Old_Versions"
            FileGetTime MT,% Output_File,M
            FileGetTime CT,% Output_File,C
            FormatTime CT,%CT%,yyyy-MM-dd HHmmss
            FormatTime MT,%MT%,yyyy-MM-dd HHmmss
            if !InStr(FileExist(BackupDirectory),"D") {
                FileCreateDir % BackupDirectory
            }
            FileCreateDir % BackupDirectory "\" MT
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
    return
}
limitBackups(Count) {
    /*
    1. get number of backup subfolders 
    2. if number greater 'Count', get the remainder
    3. Get the 'remainder' number of oldest subfolders and 'FileRemoveDir' them
    */
}

; #region:FindFreeFileName() (1452864709)

; #region:Metadata:
; Snippet: FindFreeFileName()
; 09 Oktober 2022
; --------------------------------------------------------------
; License: WTFPL
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
    Testpath := FilePath ;Return path if it doesn't exist
    i := 1
    while FileExist(TestPath) {
        i++
        Testpath := dir "\" filename " (" i ")" (extension = "" ? "" : "." extension)
    }
    return TestPath
}
; #endregion:Code


; #endregion:FindFreeFileName() (1452864709)
