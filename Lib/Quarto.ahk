FileRead String, % "TESTFILEPATH"
String2:=convertToQMD(String)
;Validate(String,String2)
return

convertToQMD(String) {
    String:=convertBookdownToQuartoReferencing(String)
    return String
}

convertBookdownToQuartoReferencing(String) {

    ;; 1. `\@ref(type:label)` → `@type-label`  → regexmatchall?
    needle:="\\@ref\((?<Type>\w*)\:(?<Label>[^)]*)\)"
    Matches:=RegexMatchAll(String, "im)" needle)
    for _, match in Matches {                                                  ;; star, top
        needle := match[0]
        Type:=match[1]
        Label:=match[2]
        lbl:=Label
        if (Type="tab") {
            if (!InStr(Label, "tbl-")) {
                Label:="tbl-" Label
            }
            Type:="tbl"
        } else {
            if (!InStr(Label,Type "-")) {
                Label:=Type "-" Label

            }
        }
        String := strreplace(String, needle, "@"  Label)

        ;; 2. tbl-WateringMethodTables →
        String:= strreplace(String,"r " lbl, "r " Label)
    }
    return String
}
