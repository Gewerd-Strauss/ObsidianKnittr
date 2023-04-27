IsDebug() {
    static _ := !!(DllCall("GetCommandLine", "Str") ~= "i) \/Debug(=\H+)? ")
    return _
}