createTemporaryObsidianVaultRoot(manuscript_location,bAutoSubmitOTGUI) {
    if (bAutoSubmitOTGUI) {
        if (script.config.Config.AutoRelativeLevel!="") && (script.config.Config.AutoRelativeLevel >0) {
            Level:=script.config.Config.AutoRelativeLevel + 0
        }

    } else {
        Level:=0
    }
    Graph:=findObsidianVaultRootFromNote(manuscript_location,true)
    TV_String:=AssembleTV_String(Graph[2])
    ret:=chooseTV_Element(TV_String,Graph,Level,bAutoSubmitOTGUI)
    return {IsVaultRoot:ret.IsVaultRoot,Path:ret.Path,Graph:Graph}
}

AssembleTV_String(Array) {
    static str:="", reorder:={}
    Loop, % Array.Count()
    {
        Val:=Array[Array.Count() + 1 - A_Index]
        reorder.push(Val)
        Indents:=A_Index
        loop, %Indents%
            str.= A_Tab
        str.=Val "`tIcon4 expand`n"
    }
    OutputDebug % str
    global reordered_arr:=reorder
    return str
}
findObsidianVaultRootFromNote(path,reset:=false) {
    static FoundLocation:=OutFileName:=""
    static arr:={}
    OutputDebug % "`n"
    path_orig:=path
    if reset { ;; this is not relevant for now, but is needed for the GUI-implementation later on.
        arr:={}
    }
    if (SubStr(path,0)="\") ;; remove "\" from folder path if present
        path:=SubStr(path,1,StrLen(path)-1)

    SplitPath % path,OutFileName, OutDir
    OutputDebug % (InStr(FileExist(path),"D")?"Directory":"File")
    if !InStr(FileExist(path),"D") { ;; path is a file, so use OutDir as path
        path:=OutDir
    }

    obsidianVaultCheckString:=path "\.obsidian"
    if !InStr(FileExist(path_orig),"D") { ;; path is a file, so use OutDir as path

    } else {
        arr.push(OutFileName)
    }
    if InStr(FileExist(obsidianVaultCheckString),"D") { ;; check if path contains ".obsidian"-folder
        OutputDebug % " found at`n" path
        FoundLocation:=obsidianVaultCheckString
        C:=arr[arr.MaxIndex()]
        Cap:=OutDir "\" C
        if (arr.Count()=0) {
            arr.push(Cap)
        } else {
            arr[arr.MaxIndex()]:=Cap
        }
        OutputDebug % "`n"
        return [FoundLocation,arr] ;; collect and return the whole stack so far, this is the last call.
    } else {
        OutputDebug % " not found at`n" path
        SplitPath % path_orig,,OD
        if (path_orig=OD) {
            return 0 ;; we have reached the disk's root, all further cals would only run towards the recursion limit. Better back out now and throw an error
        }
        return %A_ThisFunc%(OD)
    }
    return -2 ;; unreachable and just here for my own OCD sake
}

chooseTV_Element(TV_String,Graph,Level,bAutoSubmitOTGUI) {
    global
    /*
    1. render the TV_GUI (callback of main GUI or TV-subGUI, depending on implementation)
    2. retrieves the selected TV-Element upon GUI submit
    */
    ImageListID := IL_Create(5)
    Loop 5 {
        IL_Add(ImageListID, "shell32.dll", A_Index)
    }
    arrc:=Graph[2].Count()
    if (arrc>20) {
        arrc:=20
    }
    arrc++

    /*
    - TODO: style this GUI, color, font size, positioning, parent hwnd etc pp
    - TODO: give this GUI a a hwnd and guilabel, reformat the function names to be pr   e   eeeeoperly namespaced
    TODO: add a checkbox on the main GUI to forego using this feature (must be checked to use it, default is unchecked or lastUsage)
    - TODO: add th
    */
    gui TOVR: new
    gui TOVR: +hwndTOVRGUI +LabelTOVR
    gui add, text,, % "Vault root: " Graph[2,arrc-1] "`nFolder containing chosen note: " manuscript_location
    Gui Add, TreeView, r%arrc% ImageList%ImageListID% checked w1200 r%arrc%
    Gui Add, Button, Default w70 gsubmitConfigFolder, &Submit Folder
    Gui +OwnDialogs
    TV_Delete()
    if (Level) && (bAutoSubmitOTGUI) {
        occurences:=st_count(TV_String,"Icon4 expand")
        intended_level:=occurences-Level
        Lines:=strsplit(TV_String,"`n")
        OutputDebug % TV_String
        TV_String:=""
        for each, Line in Lines {
            if (each=intended_level) {
                Line:=strreplace(Line,"Icon4 expand","Icon4 check expand")
            }
            TV_String.=Line "`n"
        }
        OutputDebug % TV_String
        ;; replace only the intended_level'th occurence with the modified string
        TV_String:=strreplace(TV_String,"Icon4 expand","Icon4 expand Check1",,occurences)
        TV_String:=strreplace(TV_String,"Icon4 expand Check1","Icon 4")
    }
    CreateTreeView(TV_String)
    gui show, w600 Autosize, % script.name  " - Set limiting '.obsidian'-folder"
    if (Level) && (bAutoSubmitOTGUI) {
        submitConfigFolder()
    } else {
        WinWaitClose % script.name  " - Set limiting '.obsidian'-folder"
    }
    if (temporary_obsidianconfig_path=-1) {
        ;; user chose the vault root, so do not flag for delete
        return {Path:Graph[1],IsVaultRoot:True}
    }
    if (temporary_obsidianconfig_path="") {
        ;; user closed the GUI - use default, do not flag for delete
        return {Path:Graph[1],IsVaultRoot:True}
    }
    ttip(FileExist(temporary_obsidianconfig_path))
    ret:=checkTemporaryObsidianVaultLocation(temporary_obsidianconfig_path)
    if !ret.isVaultRoot {
        FileCreateDir % temporary_obsidianconfig_path "\"
        if !FileExist(temporary_obsidianconfig_path) {
            ;; throw error
        }
    } else {
        return false
    }
    ttip(FileExist(temporary_obsidianconfig_path))
    ;m(temporary_obsidianconfig_path)
    return {Path:temporary_obsidianconfig_path,IsVaultRoot:false} 
}
TOVREscape() {
    gui TOVR: destroy
    return
}
setTemporaryObsidianVaultRoot(Path) {
    /*
    1. receives return of chooseTV_Element
    2. this element signifies the path at which the `.obsidian`-folder is to be set
    3. check if we are at a legitimate .obsidian-vault root -> by checking if checkTemporaryObsidianVaultLocation(Path)
    3.1 TRUE: not a vault root
    1. checks if it already exists
    2. sets if not existent, skip otherwhise
    3. flag for 'delete'
    3.2 FALSE: we are at vault root
    1. flag for 'no-delete' - it's a legitimate vault root after all
    4. checks for existence,
    returns true if exists
    returns false if not exist
    returns -1 if it exists and is a legitimate vault root that is not to be deleted
    */

}

checkTemporaryObsidianVaultLocation(Path) {
    bool:=false
    /*
    check if 'Path' is at a legitimate vault root
    - in this case we do not want to remove the .obsidian-folder upon exit, so return false
    - if not at vault root, return true as this is to be a temporary root folder
    - be cautious, default assumption is to keep the folder
    */
    bool:=!!FileExist(Path)
    return {Path:Path,IsVaultRoot:bool}
}

removeTemporaryObsidianVaultRoot(Path,Graph) {
    /*
    check CRT date to make sure this folder is not somehow the true vault root - overkill, but better be safe than REALLY sorry
    */
    if (Path=Graph[1]) {
        return {Path:Path,IsVaultRoot:True,IsEmpty:false}
    }
    isEmpty:=true
    Loop, Files, % Path "\*.*", FD ;; check if temporary obsidian folder contains any files - which it shouldn't
    {
        isEmpty:=false

    }
    if isEmpty { ;; remove if empty
        if (Path!=Graph[1]) {

            FileRemoveDir % Path
        }
    } else {
        ;; TODO:  check if this is the vault root actually. If Yes, return as array {Path:Path,isVaultRoot:True}
        return {Path:Path,IsVaultRoot:True}
    }
    bool:=!!FileExist(Path)
    if bool  {
        ;; throw error: temporary .obsidian-folder could not be removed.
    }
    return {Path:Path,IsVaultRoot:False,Removed:!bool}
}
submitConfigFolder(Level:="") {
    global
    gui TOVR: submit,
    arr:={}
    ItemID := 0  ; Causes the loop's first iteration to start the search at the top of the tree.
    Loop
    {

        idn:=TV_GetChild(ItemID)
        ItemID := TV_GetNext(idn, "Checked")  ; Replace "Full" with "Checked" to find all checkmarked items.
        TV_GetText(pathText, ItemID)
        if (pathText!="") {
            arr.push(pathText)
        }
        if not ItemID  ; No more items in tree.
            break ;; BUG: checking two entries should always return the most nested, but it always only returns one line. is this line at fault?
        if (A_Index>(Graph[1].Count() + Graph[2].Count())) {
            break
        }
    }
    /*
    use the contents of reordered_arr and 'pathText' to rebuild the path we need
    */
    if RegexMatch(arr[arr.MaxIndex()], "\((?<Count>\d*)\)",v) {
        temporary_obsidianconfig_path:=""
        loop, % vCount {
            temporary_obsidianconfig_path.=reordered_arr[A_Index] "\"
        }
    } else {
        ;; throw error
        gui TOVR: destroy
        return temporary_obsidianconfig_path:=-1
    }
    temporary_obsidianconfig_path:=temporary_obsidianconfig_path "\.obsidian"
    temporary_obsidianconfig_path:=RegexReplace(temporary_obsidianconfig_path,"\\{2,}","\")
    ;m(temporary_obsidianconfig_path)
    gui TOVR: destroy
    return temporary_obsidianconfig_path
}
CreateTreeView(TreeViewDefinitionString) {	; by Learning one
    IDs := {} 
    Loop, parse, TreeViewDefinitionString, `n, `r
    {
        if A_LoopField is space
            continue
        Item := RTrim(A_LoopField, A_Space A_Tab), Item := LTrim(Item, A_Space), Level := 0
        While (SubStr(Item,1,1) = A_Tab)
            Level += 1,	Item := SubStr(Item, 2)
        RegExMatch(Item, "([^`t]*)([`t]*)([^`t]*)", match)	; match1 = ItemName, match3 = Options
        if (Level=0)
            IDs["Level0"] := TV_Add("(" A_Index ") " match1, 0, match3)
        else
            IDs["Level" Level] := TV_Add("(" A_Index ") " match1, IDs["Level" Level-1], match3)
    }
}	; http://www.autohotkey.com/board/topic/92863-fu


