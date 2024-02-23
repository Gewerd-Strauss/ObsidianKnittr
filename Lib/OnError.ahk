fonError(DebugState,EL,a*) {
    /*
    write to EL in case of error
    */
    if (isObject(a)) {
        e:=a[1]
        if isObject(e) {
            if (a.Count()>1) {
                for _, obj in e {
                    str_:=onError_Obj2Str(obj,1,1)
                        , err_str.="`n`n`n" str_
                }
            } else {
                str_:=onError_Obj2Str(e,1,1)
                    , err_str.="`n`n`n" str_
            }
        } else {
            err_str:=onError_Obj2Str(a,1,1)
        }
        MsgBox % err_str
    }
    if (DebugState) {
        msgbox % DebugState " Encountered error, wrote EL to file"
            . "`n" 
            . "`n" 
            . "`n" 
    }
    EL.Errormessage:=err_str
    ExitApp -2
}

onError_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
    static String,Blank
    if (FullPath=1)
        String:=FullPath:=Blank:=""
    if (IsObject(Obj)) {
        for a,b in Obj{
            if (IsObject(b)) {
                onError_Obj2Str(b,FullPath "." a,BottomBlank)
            } else {
                if (BottomBlank=0) {
                    String.=FullPath "." a " = " b "`n"
                } else if (b!="") {
                    String.=FullPath "." a " = " b "`n"
                } else {
                    Blank.=FullPath "." a " =`n"
                }
            }
        }}
    return String Blank
}
