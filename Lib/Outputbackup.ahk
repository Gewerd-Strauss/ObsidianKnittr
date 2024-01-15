backupOutput(Path, out) {
    SplitPath % Path, ,OutputRoot
    BackupDirectory:=OutputRoot "\Old_Versions"
    Copied:=0
    MT:=""
    for format, Filesuffix in out.filesuffixes {
        package:=strsplit(format,"::").1
        Loop, Files, % OutputRoot "\*" Filesuffix 
        {
            if (MT="") {
                FileGetTime MT,% A_LoopFileFullPath,M
                FileGetTime CT,% A_LoopFileFullPath,C
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
            FileMove % A_LoopFileFullPath, % A_LoopFileFullPath
            SplitPath % A_LoopFileFullPath, OutFileName
            fileisAccessible:=!ErrorLevel
            if (package!="") {
                if fileisAccessible {
                    FileMove % A_LoopFileFullPath, % BackupDirectory "\" MT "\" OutFileName
                } else {
                    FileCopy % A_LoopFileFullPath, % BackupDirectory "\" MT "\" OutFileName
                }
            } else {
                if fileisAccessible {
                    FileMove % A_LoopFileFullPath, % BackupDirectory "\" MT "\" Name "." Filesuffix
                } else {
                    FileCopy % A_LoopFileFullPath, % BackupDirectory "\" MT "\" Name "." Filesuffix
                }
            }
            Copied++
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
