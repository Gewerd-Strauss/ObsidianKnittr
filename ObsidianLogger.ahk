;___________________________________________________________________________________________________


; TimeLogger
; ----------

; User-configurable variables:
; ----------------------------
AppLoggingRate = 10 ; Rate for capturing active window titles - number in seconds
LogPath = ENTER-PATH-WHERE-YOU-KEEP-YOUR-JOURNALING-NOTES-IN-OBSIDIAN'S-VAULT. (Full path please. And yes, erase EVERYTHING on this line after the equals sign and add the path).
AppLogFile = yes ; Use separate AppLog file instead of a single AppLog/Journal file. Yes/No.
SectionTitles = no ; Add H5 headings before every entry.
FirstRun = 0 ; Change to 1 if you want to be automatically asked for an initial log entry after startup.


; Non-configurable stuff:
; -----------------------
; (Please, don't touch)

LastActiveWindow = 
AppLogSwitch = 1
JournalSwitch = 1
RunTime = 0
SleepTime := AppLoggingRate * 1000


; Actual script:
; --------------
	
	Gui, TimeLogger: Font, s12
	Gui, TimeLogger: Add, Edit, vLoggerContent x10 y10 w500 h600,
	Gui, TimeLogger: Font
	Gui, TimeLogger: Add, Button, gLogSave x10 y620 w500 h50, &Save Log Entry


	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, LoggerRate, TimeLogger Ultimate Hyper Rainbow Edition, When do you want me to check on you?`n`n(time range in minutes)



	Loop
	{
		JournalTime := LoggerRate * 60000
		RunTime := RunTime + SleepTime
		
		Sleep, %SleepTime%
		
		WinGetActiveTitle, ActiveWindow
		StoreActiveWindow = %ActiveWindow%
		
		If ActiveWindow != %LastActiveWindow%
		{
			FormatTime, LogTime,, HH:mm:ss
			FormatTime, LogFilename, , yyyy-MM-dd
			LogWindow := Regexreplace(ActiveWindow, "[^a-zA-Z0-9]", " ")
			
			If AppLogFile = yes
				{
					LogFilename = %LogFilename%_AppLog.md
				}
			Else
				{
					LogFilename = %LogFilename%.md
				}
				
			LogFile = %LogPath%%LogFilename%
			
			
			if (AppLogSwitch = 1) or (SectionTitles = yes)
				{
					FileContent = `n##### AppLog`n%LogTime% - %LogWindow%`n`n- - -`n
				}
			else
				{
					FileContent = `n%LogTime% - %LogWindow%`n`n- - -`n
				}
				
			AppLogSwitch = 0
			JournalSwitch = 1
			sleep, 20

			FileAppend, %FileContent%, %LogFile%
		}
		
		
		
		If (RunTime = JournalTime) or (FirstRun = 1)
		{
			InputBox, LoggerExcuse, TimeLogger Ultimate Hyper Rainbow Edition, GOTCHA - what are you doing?`n`n`n(Manual Journaling: Windows Key + J)`n(Stop logging/Exit TimeLogger: Shift + Windows Key + L)
			sleep, 20
			FormatTime, LogTime,, HH:mm:ss
			;FormatTime, LogFilename, , yyyy-MM-dd_dddd
			FormatTime, LogFilename, , yyyy-MM-dd
			LogWindow := Regexreplace(ActiveWindow, "[^a-zA-Z0-9]", " ")
			LogFilename = %LogFilename%.md
			LogFile = %LogPath%%LogFilename%
			
			If SectionTitles = yes
				{
					FileContent = `n- - -`n##### AutoJournal`n%LogTime% - %LoggerExcuse%`n`n- - -`n
				}
			Else
				{
					FileContent = `n- - -`n%LogTime% - %LoggerExcuse%`n`n- - -`n
				}
			sleep, 20
			RunTime = 0
			AppLogSwitch = 1
			JournalSwitch = 0
			FirstRun = 0

			FileAppend, %FileContent%, %LogFile%
		}
		WinActivate, %StoreActiveWindow%
		LastActiveWindow = %ActiveWindow%
	}
		

WriteJournal:
		FormatTime, LogTime,, HH:mm:ss
		;FormatTime, LogFilename, , yyyy-MM-dd_dddd
		FormatTime, LogFilename, , yyyy-MM-dd
		WinGetActiveTitle, ActiveWindow
		StoreActiveWindow = %ActiveWindow%

		LogWindow := Regexreplace(ActiveWindow, "[^a-zA-Z0-9]", " ")
		LogFilename = %LogFilename%.md
		LogFile = %LogPath%%LogFilename%
		If SectionTitles = yes
				{
					FileContent = `n- - -`n##### Journal`n%LogTime% - %LoggerContent%`n`n- - -`n
				}
		Else
				{
					FileContent = `n%LogTime% - %LoggerContent%`n`n- - -`n
				}
		FileAppend, %FileContent%, %LogFile%
		WinActivate, %StoreActiveWindow%
return

LogSave:
	Gui, TimeLogger: Submit, Hide
	GuiControlGet, LoggerContent
	sleep, 20
	GoSub, WriteJournal
	GuiControl, TimeLogger:, LoggerContent, 
return

#J::
	Gui, TimeLogger: Show
return

#+l::
		ExitApp
return

ExitApp