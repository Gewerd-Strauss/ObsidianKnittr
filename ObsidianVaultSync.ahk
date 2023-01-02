   #SingleInstance, Force
   SendMode Input
   SetWorkingDir, %A_ScriptDir%

   /*
   Read all paths to be supervised from file
   */
   NotifyTrayClick(DllCall("GetDoubleClickTime"))
   OnMessage(0x404, "f_TrayIconSingleClickCallBack")
   #Include <scriptobj>
      global script := { base : script
         ,name : regexreplace(A_ScriptName, "\.\w+")
         ,version : "1.1.1"
         ,author : "Gewerd Strauss"
         ,authorlink : ""
         ,email : "csa-07@freenet.de"
         ,credits : ""
         ,creditslink : ""
         ,crtdate : "10.01.2022"
         ,moddate : ""
         ,homepagetext : ""
         ,homepagelink : ""
         ,ghtext 	 : "My GitHub"
         ,ghlink		 : "https://github.com/Gewerd-Strauss"
         ,doctext : ""
         ,doclink	 : ""
         ,forumtext 	 : ""
         ,forumlink	 : ""
         ,donateLink : ""
         ;~ ,resfolder    : A_ScriptDir "\res"
         ;~ ,iconfile     : A_ScriptDir "\res\sct.ico"
         ,configfile : regexreplace(A_ScriptName, "\.\w+") ".ini"
         ,configfolder : A_ScriptDir "\INI-Files\"
         ,vAHK	 : A_AhkVersion}	

      global bGuiVisible:=false
      vSourceVaults:=-1
      vDestinationVaults:=-1
   IniTemplate=
	( LTRIM
	[Vault-Directories]

   [Synced Files]
	[Settings]
	)
   sHowToText=
	( LTRIM
		No configuration found. To set up, please open the config-file and 
		insert any desired absolute/full path in below "[Vault-Directories], and above [Settings]".


		Settings:

		DisplayGUI: set to "0" to hide the gui. Can increase speed.

		FastGUI: speed up the GUI considerably. 
		TargetSpecificSubfolders: a comma-separated list of folders in the directory of **each markdown-file** to be searched. All folders not present in this list are skipped.

		MoveToObsidianTrashInsteadOfNormalTrash: Set to true to move any file to the .trash-folder of the respective vault. Note that files already present in that folder get overwritten, and that files cannot easily be moved back to their initial location, as there is no "Restore file"-option in the .trash-folder.

		---

		The script will exit now. Please add the paths necessary to the config-file, then start the script again.
	)
   if (!Instr(FileExist(script.configfolder),"D"))
      FileCreateDir, % script.configfolder
   if !FileExist(script.configfolder script.configfile)
	{
		FileAppend, %IniTemplate%,% script.configfolder script.configfile
		MsgBox, 65, % script.name ": No configuration found.",% sHowToText
		IfMsgBox, Ok
		{
			run, % script.configfolder script.configfile
			ExitApp, 
		}
		Else	
		{
			msgbox,, % "Exiting " script.name "...", % "Script cannot start because valid configuration isn't present. Exiting script now. Please try again."
			ExitApp
		}

	}
	Else
	{
		FileRead, CurrentStateINI, % script.configfolder script.configfile
		CurrentstateINI:=strreplace(CurrentStateINI,"`r","")
		if (CurrentStateINI=IniTemplate)
		{
			MsgBox, 65, % script.name ": No configuration found.",% sHowToText
			IfMsgBox, Ok
			{
				run, % script.configfolder script.configfile
				ExitApp, 
			}
			else
				ExitApp, 
		}
		else
			IniObj:=fReadINI(script.configfolder script.configfile)
	}
   

   

   
   
   
   
   
   
   
   
   ; "D:\
   ; DokumenteCSA\
   ; 000 AAA Dokumente\
   ; 000 AAA HSRW\
   ; Download Lecture Slides for R&R\
   ; Obsidian NoteTaking\
   ; TestVault\
   
       Vaults:={}
   IniObj:=fReadINI(script.configfolder script.configfile)
   aObsidianPaths:=fGetObsidianPaths(IniObj,true)
   VaultChoices:=""
   for k,v in IniObj["Vault-Directories"]
   { ;vvName
      d:=RegExMatch(v, ".+\\(?<FolderName>.+)\\[^\\]*",v)
      SplitPath, v  , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
      Vaults[vFolderName]:=v
      VaultChoices.=vFolderName "|" (k=1?"|":"")
   }

   gosub, lGuiCreate_1
   return
   lGuiCreate_1:
   gui_control_options := "xm w820 " . cForeground . " -E0x200"  ; remove border around edit field
   Gui, 1: new
   Gui, Margin, 16, 16
   Gui, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC
   cBackground := "c" . "1d1f21"
   cCurrentLine := "c" . "282a2e"
   cSelection := "c" . "373b41"
   cForeground := "c" . "c5c8c6"
   cComment := "c" . "969896"
   cRed := "c" . "cc6666"
   cOrange := "c" . "de935f"
   cYellow := "c" . "f0c674"
   cGreen := "c" . "b5bd68"
   cAqua := "c" . "8abeb7"
   cBlue := "c" . "81a2be"
   cPurple := "c" . "b294bb"
   Gui, Color, 1d1f21, 373b41, 
   Gui, Font, s11 cWhite, Segoe UI 
   gui, add, tab3,xm ym w830 h900,Main|Files To Copy
   gui, tab, Main
   gui, add, text, w200 h0 x25 y45, HGI TET
   gui, add, text,x41 yp+36 w170, Choose Source Vault:
   gui, add, DropDownList, yp-4 xp+145 vvSourceVault, %  Vaultchoices
   gui, add, checkbox,  yp+4 xp+170 vbCopyToAll, Sync to all directories?
   
   Gui, add, Listview, r20 w780 h770 xp-315 yp+44 Checked Readonly vvDestinationVaults,Choose directories to sync | Path
   for k,v in Vaults
      LV_Add(Check,k,V)
   gui, add, button, yp-50 xp+500 glRunSync, Run Sync
   gui, add, button, yp xp+90 glOpenSettings, Open Settings
   Gui, Font, s7 cWhite, Verdana
   Gui, Add, Text,x25, Version: %VN%	Author: %AU% 
   gui, tab, Files To Copy
   Gui, Font, s11 cWhite, Segoe UI 
   gui, add, text, w200 h0 x25 y45, HGI TET
   gui, add, checkbox, x41 yp+36 vbSyncAll, Sync all files?

   Gui, add, Listview, r20 w780 h770 x41 yp+44 Checked Readonly vvChosenSyncs,Choose files to sync
   for k,v in IniObj["Synced Filenames"]
      
      LV_Add(Check, (Instr(v,".")?v:v " [Folder]"))
   ; for k,v in Vaults
   ;    LV_Add(Check,k,V)
   gui, show, 
   bGuiVisible:=true
return
Numpad0:: 
gui, show, 
return
lRunSync:
gui, submit
CheckedRows:=[]
RowNumber:=0
Gui, Listview, vDestinationVaults
if (bCopyToAll)
{
   gui, submit
   ; vSourceVault
   aObsidianPaths:=fGetObsidianPaths(IniObj,true)

   m("write down method for choose all")
}  ; A_DefaultListView 
else
{
   gui, submit
   m("finish this path: f_GetSelectedLVEntries() cannot retrieve a checked, but not selected row","and the loop before does not work for unknown reasons. Source of code: //www.autohotkey.com/board/topic/92413-listview-with-checkboxes-and-eventinfo/?p=593870")
   loop, A_Index
   {
      RowNumber:=LV_GetNext(RowNumber,"C")
      if !RowNumber
         break
      LV_GEtText(sCurrText1,RowNumber,1)
      LV_GEtText(sCurrText2,RowNumber,2)
      CheckedRows.push(RowNumber:=[sCurrText1,sCurrText2])
   }
   sel:=f_GetSelectedLVEntries()
   ; for k,v in Vaults


}
m(bCopyToAll,vSourceVault,vDestinationVaults)
return


GCEscape:
gui, 1: hide
bGuiVisible:=false
return
buttonchckall:
Gui, ListView, locdir
LV_Modify(0, "Check")
return
lOpenSettings:
run, % script.configfolder script.configfile
return
buttonunchckall:
Gui, ListView, locdir
LV_Modify(0, "-Check") 
return

   fGetObsidianPaths(IniObj,InsertParentInstead:=false)
	{ ; assemble paths to vaults from ini file
		ObsidianPath:=[]
		; NumVaults:=IniObj["Vault-Directories"].MaxIndex()
		for k,v in IniObj["Vault-Directories"]
		{
			VaultInfo:=Strsplit(v,"\")
			VaultName:=VaultInfo[VaultInfo.MaxIndex()]
			if (VaultName="")
				VaultName:=VaultInfo[VaultInfo.MaxIndex()-1]
			ObsidianPath.push(v (InsertParentInstead?"":((SubStr(v,0,10)==".obsidian\")?:".obsidian\") ))
		}
		return ObsidianPath
	}
f_GetSelectedLVEntries()
	{ ;A_DefaultListView
		vRowNum:=0
		sel:=[]
		loop 
		{
			vRowNum:=LV_GetNext(vRowNum)
			if not vRowNum  ; The above returned zero, so there are no more selected rows.
				break
			LV_GetText(sCurrText1,vRowNum,1)
			LV_GetText(sCurrText2,vRowNum,2)
			LV_GetText(sCurrText3,vRowNum,3)
			LV_GetText(sCurrText4,vRowNum,4)
			sel[A_Index]:="||" sCurrText1 "||" sCurrText2 "||" sCurrText3
		}
		return sel
	}
f_UpdateProgress(Index,BarValue:="",PlusMinus:="",Param4:="")
	{
		if !IniObj["Settings"].FastGui
			sleep, 70
		guicontrol,,HeadText, % d:=ProgressMessages[Index,1]
		str:=(ProgressMessages[Index,2]!=""?ProgressMessages[Index,2]:Param4)
		guicontrol,,SubText, % str
		if (BarValue!="") && (BarValue!=-1)
		{
			if (PlusMinus!="")
				guicontrol,,Progress, % PlusMinus BarValue   
			Else
				guicontrol,,Progress, % BarValue
			if !IniObj["Settings"].FastGui
				sleep, 70
		}
		else if (BarValue==-1)
			guicontrol,,Progress,0
		else
		{
			loop, 25
				guicontrol,,Progress,+4
		}
		return
	}

   st_count(string, searchFor="`n")
	{ ; count number of occurences of 'searchFor' in 'string'
		; taken from ST-lib at https://www.autohotkey.com/boards/viewtopic.php?t=53, published by tidbit
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		/*
			Count
			Counts the number of times a tolken exists in the specified string.
			
			string    = The string which contains the content you want to count.
			searchFor = What you want to search for and count.
			
			note: If you're counting lines, you may need to add 1 to the results.
			
			example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
			output:  4
		*/
		StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
		return ErrorLevel
	}

   
	f_TrayIconSingleClickCallBack(wParam, lParam)
	{ ; taken and adapted from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
		VNI:=1.0.3.12
		; 0x201 WM_LBUTTONDOWN
		; 0x202 WM_LBUTTONUP
		if (lParam = 0x202) || (lParam = 0x201)
		{
         if bGuiVisible
			   gui 1: hide
         else
            gui 1: show
         bGuiVisible:=!bGuiVisible
   sleep, 200
			return 0
		}
	}
   NotifyTrayClick_203:
   if bGuiVisible
			   gui 1: hide
         else
            gui 1: show
         bGuiVisible:=!bGuiVisible
   return
   NotifyTrayClick(P*) 
	{ ; NotifyTrayClick | SKAN | https://www.autohotkey.com/boards/viewtopic.php?t=81157
		;  v0.41 by SKAN on D39E/D39N @ tiny.cc/notifytrayclick
		VNI=1.0.0.17
		Static Msg, Fun:="NotifyTrayClick", NM:=OnMessage(0x404,Func(Fun),-1),  Chk,T:=-250,Clk:=1
		If ( (NM := Format(Fun . "_{:03X}", Msg := P[2])) && P.Count()<4 )
			Return ( T := Max(-5000, 0-(P[1] ? Abs(P[1]) : 250)) )
		Critical
		If ( ( Msg<0x201 || Msg>0x209 ) || ( IsFunc(NM) || Islabel(NM) )=0 )
			Return
		Chk := (Fun . "_" . (Msg<=0x203 ? "203" : Msg<=0x206 ? "206" : Msg<=0x209 ? "209" : ""))
		SetTimer, %NM%,  %  (Msg==0x203        || Msg==0x206        || Msg==0x209)
		? (-1, Clk:=2) : ( Clk=2 ? ("Off", Clk:=1) : ( IsFunc(Chk) || IsLabel(Chk) ? T : -1) )
		Return True
	}
; ==================================================================================================================================
; Function:       Notifies about changes within folders.
;                 This is a rewrite of HotKeyIt's WatchDirectory() released at
;                    http://www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
; Tested on:      Win 10 Pro x64
; Usage:          WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
; Parameters:
;     Folder      -  The full qualified path of the folder to be watched.
;                    Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
;                    Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
;                    If not, it will be done internally on exit.
;     UserFunc    -  The name of a user-defined function to call on changes. The function must accept at least two parameters:
;                    1: The path of the affected folder. The final backslash is not included even if it is a drive's root
;                       directory (e.g. C:).
;                    2: An array of change notifications containing the following keys:
;                       Action:  One of the integer values specified as FILE_ACTION_... (see below).
;                                In case of renaming Action is set to FILE_ACTION_RENAMED (4).
;                       Name:    The full path of the changed file or folder.
;                       OldName: The previous path in case of renaming, otherwise not used.
;                       IsDir:   True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
;                    Pass the string "**DEL" to remove the directory from the list of watched folders.
;     SubTree     -  Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
;                    Default: False - sub-folders aren't watched.
;     Watch       -  The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_...
;                    values specified below.
;                    Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
; Return values:
;     Returns True on success; otherwise False.
; Change history:
;     1.0.03.00/2021-10-14/just me        -  bug-fix for addding, removing, or updating folders.
;     1.0.02.00/2016-11-30/just me        -  bug-fix for closing handles with the '**END' option.
;     1.0.01.00/2016-03-14/just me        -  bug-fix for multiple folders
;     1.0.00.00/2015-06-21/just me        -  initial release
; License:
;     The Unlicense -> http://unlicense.org/
; Remarks:
;     Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than MAXIMUM_WAIT_OBJECTS (64)
;     folders simultaneously.
; MSDN:
;     ReadDirectoryChangesW          msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
;     FILE_NOTIFY_CHANGE_FILE_NAME   = 1   (0x00000001) : Notify about renaming, creating, or deleting a file.
;     FILE_NOTIFY_CHANGE_DIR_NAME    = 2   (0x00000002) : Notify about creating or deleting a directory.
;     FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4   (0x00000004) : Notify about attribute changes.
;     FILE_NOTIFY_CHANGE_SIZE        = 8   (0x00000008) : Notify about any file-size change.
;     FILE_NOTIFY_CHANGE_LAST_WRITE  = 16  (0x00000010) : Notify about any change to the last write-time of files.
;     FILE_NOTIFY_CHANGE_LAST_ACCESS = 32  (0x00000020) : Notify about any change to the last access time of files.
;     FILE_NOTIFY_CHANGE_CREATION    = 64  (0x00000040) : Notify about any change to the creation time of files.
;     FILE_NOTIFY_CHANGE_SECURITY    = 256 (0x00000100) : Notify about any security-descriptor change.
;     FILE_NOTIFY_INFORMATION        msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
;     FILE_ACTION_ADDED              = 1   (0x00000001) : The file was added to the directory.
;     FILE_ACTION_REMOVED            = 2   (0x00000002) : The file was removed from the directory.
;     FILE_ACTION_MODIFIED           = 3   (0x00000003) : The file was modified.
;     FILE_ACTION_RENAMED            = 4   (0x00000004) : The file was renamed (not defined by Microsoft).
;     FILE_ACTION_RENAMED_OLD_NAME   = 4   (0x00000004) : The file was renamed and this is the old name.
;     FILE_ACTION_RENAMED_NEW_NAME   = 5   (0x00000005) : The file was renamed and this is the new name.
;     GetOverlappedResult            msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
;     CreateFile                     msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
;     FILE_FLAG_BACKUP_SEMANTICS     = 0x02000000
;     FILE_FLAG_OVERLAPPED           = 0x40000000
; ==================================================================================================================================
WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) {
   Static DummyObject := {Base: {__Delete: Func("WatchFolder").Bind("**END", "")}}
   Static TimerID := "**" . A_TickCount
   Static TimerFunc := Func("WatchFolder").Bind(TimerID, "")
   Static MAXIMUM_WAIT_OBJECTS := 64
   Static MAX_DIR_PATH := 260 - 12 + 1
   Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode
   Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
   Static SizeOfOVL := 32     ; size of the OVERLAPPED structure (64-bit)
   Static WatchedFolders := {}
   Static EventArray := []
   Static WaitObjects := 0
   Static BytesRead := 0
   Static Paused := False
   ; ===============================================================================================================================
   If (Folder = "")
      Return False
   SetTimer, % TimerFunc, Off
   RebuildWaitObjects := False
   ; ===============================================================================================================================
   If (Folder = TimerID) { ; called by timer
      If (ObjCount := EventArray.Count()) && !Paused {
         ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
         While (ObjIndex >= 0) && (ObjIndex < ObjCount) {
            Event := NumGet(WaitObjects, ObjIndex * A_PtrSize, "UPtr")
            Folder := EventArray[Event]
            If DllCall("GetOverlappedResult", "Ptr", Folder.Handle, "Ptr", Folder.OVLAddr, "UIntP", BytesRead, "Int", True) {
               Changes := []
               FNIAddr := Folder.FNIAddr
               FNIMax := FNIAddr + BytesRead
               OffSet := 0
               PrevIndex := 0
               PrevAction := 0
               PrevName := ""
               Loop {
                  FNIAddr += Offset
                  OffSet := NumGet(FNIAddr + 0, "UInt")
                  Action := NumGet(FNIAddr + 4, "UInt")
                  Length := NumGet(FNIAddr + 8, "UInt") // 2
                  Name   := Folder.Name . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
                  IsDir  := InStr(FileExist(Name), "D") ? 1 : 0
                  If (Name = PrevName) {
                     If (Action = PrevAction)
                        Continue
                     If (Action = 1) && (PrevAction = 2) {
                        PrevAction := Action
                        Changes.RemoveAt(PrevIndex--)
                        Continue
                     }
                  }
                  If (Action = 4)
                     PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
                  Else If (Action = 5) && (PrevAction = 4) {
                     Changes[PrevIndex, "Name"] := Name
                     Changes[PrevIndex, "IsDir"] := IsDir
                  }
                  Else
                     PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
                  PrevAction := Action
                  PrevName := Name
               } Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
               If (Changes.Length() > 0)
                  Folder.Func.Call(Folder.Name, Changes)
               DllCall("ResetEvent", "Ptr", Event)
               DllCall("ReadDirectoryChangesW", "Ptr", Folder.Handle, "Ptr", Folder.FNIAddr, "UInt", SizeOfFNI
                                              , "Int", Folder.SubTree, "UInt", Folder.Watch, "UInt", 0
                                              , "Ptr", Folder.OVLAddr, "Ptr", 0)
            }
            ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
            Sleep, 0
         }
      }
   }
   ; ===============================================================================================================================
   Else If (Folder = "**PAUSE") { ; called to pause/resume watching
      Paused := !!UserFunc
      RebuildObjects := Paused
   }
   ; ===============================================================================================================================
   Else If (Folder = "**END") { ; called to stop watching
      For Event, Folder In EventArray {
         DllCall("CloseHandle", "Ptr", Folder.Handle)
         DllCall("CloseHandle", "Ptr", Event)
      }
      WatchedFolders := {}
      EventArray := []
      Paused := False
      Return True
   }
   ; ===============================================================================================================================
   Else { ; called to add, update, or remove folders
      Folder := RTrim(Folder, "\")
      VarSetCapacity(LongPath, MAX_DIR_PATH << !!A_IsUnicode, 0)
      If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", MAX_DIR_PATH)
         Return False
      VarSetCapacity(LongPath, -1)
      Folder := LongPath
      If (WatchedFolders.HasKey(Folder)) { ; update or remove
         Event :=  WatchedFolders[Folder]
         FolderObj := EventArray[Event]
         DllCall("CloseHandle", "Ptr", FolderObj.Handle)
         DllCall("CloseHandle", "Ptr", Event)
         EventArray.Delete(Event)
         WatchedFolders.Delete(Folder)
         RebuildWaitObjects := True
      }
      If InStr(FileExist(Folder), "D") && (UserFunc <> "**DEL") && (EventArray.Count() < MAXIMUM_WAIT_OBJECTS) {
         If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
            Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
                                          , "UInt", 0x42000000, "Ptr", 0, "UPtr")
            If (Handle > 0) {
               Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
               FolderObj := {Name: Folder, Func: UserFunc, Handle: Handle, SubTree: !!SubTree, Watch: Watch}
               FolderObj.SetCapacity("FNIBuff", SizeOfFNI)
               FNIAddr := FolderObj.GetAddress("FNIBuff")
               DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", SizeOfFNI)
               FolderObj["FNIAddr"] := FNIAddr
               FolderObj.SetCapacity("OVLBuff", SizeOfOVL)
               OVLAddr := FolderObj.GetAddress("OVLBuff")
               DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", SizeOfOVL)
               NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
               FolderObj["OVLAddr"] := OVLAddr
               DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", SizeOfFNI, "Int", SubTree
                                              , "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
               EventArray[Event] := FolderObj
               WatchedFolders[Folder] := Event
               RebuildWaitObjects := True
            }
         }
      }
      If (RebuildWaitObjects) {
         VarSetCapacity(WaitObjects, MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
         OffSet := &WaitObjects
         For Event In EventArray
            Offset := NumPut(Event, Offset + 0, 0, "Ptr")
      }
   }
   ; ===============================================================================================================================
   If (EventArray.Count() > 0)
      SetTimer, % TimerFunc, -100
   Return (RebuildWaitObjects) ; returns True on success, otherwise False
}
