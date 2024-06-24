notify(String,CLIArgs) {
    ttip(String,5)
    if (CLIArgs!="") {
        Menu Tray, Tip, % String  "`n" CLIArgs.path
    } else {
        Menu Tray, Tip, % String
    }
    return
}
