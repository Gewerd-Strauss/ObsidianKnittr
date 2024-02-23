fonExit(DebugState,EL) {
    /*
    write to EL in case of exit
    */
    _:=DebugState . ";"
    ; EL.handle()
    ; , EL.close()
    return
}
