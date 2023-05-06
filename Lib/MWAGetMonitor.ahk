MWAGetMonitor(Mx := "", My := "") { ; Maestr0 | fetched from https://www.autohotkey.com/boards/viewtopic.php?p=342716#p342716
    if (!Mx or !My) {
        ; if Mx or My is empty, revert to the mouse cursor placement
        Coordmode Mouse, Screen	; use Screen, so we can compare the coords with the sysget information`
        MouseGetPos Mx, My
    }

    SysGet MonitorCount, 80	; monitorcount, so we know how many monitors there are, and the number of loops we need to do
    Loop, %MonitorCount%{
        SysGet mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars

        if (Mx >= mon%A_Index%left) && (Mx < mon%A_Index%right) && (My >= mon%A_Index%top) && (My < mon%A_Index%bottom) {
            ActiveMon := A_Index
            break
        }
    }
    return ActiveMon
}
