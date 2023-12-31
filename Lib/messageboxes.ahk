AppError(Title, Message, Options := 0, TitlePrefix := " - Error occured: ") {
    static labels := StrSplit("Abort,Cancel,Continue,Ignore,No,OK,Retry,TryAgain,Yes", ",")
    Options |= 0x1000, Options |= 0x0010
    MsgBox % Options, % script.name TitlePrefix Title, % Message
    for _, label in labels {
        IfMsgBox % label, return label
    }
}
