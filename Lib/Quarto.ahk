FileRead String, % "TESTFILEPATH"
String2:=convertToQMD(String)
;Validate(String,String2)
return

convertToQMD(String) {
    String:=convertBookdownToQuartoReferencing(String)
    String:=modifyEquationReferences(String)
    return String
}
modifyEquationReferences(String) {
    ;; fix equation reference keys
    Lines:=strsplit(String,"`n")
    inEquation:=false
    Rebuild:=""
    for _, Line in Lines {
        Trimmed:=Trim(Line)
        if InStr(Trimmed,"$$") && !inEquation { 
            inEquation:=true
            Rebuild.=Line "`n"
        } else if !InStr(Trimmed,"$$") && !inEquation {
            inEquation:=false
            Label:=""
            Rebuild.=Line "`n"
            continue
        } 
        if InStr(Trimmed,"$$") && inEquation && Label!="" { ;; this is the second $$ for this latex block. thus, we now want to redd the label
            Line:=RTrim(Line) A_Space "{#eq-" Label "}"
            Rebuild.=Line "`n"
            inEquation:=false
            continue
        }
        ;; let's find and remove the label.
        if RegexMatch(Line,"i)(?<FullString>\(\\#eq:(?<EQLabel>.*)\))",v)
        {
            inEquation:=true
            Line:=strreplace(Line,vFullString)
            Rebuild.=Line "`n"
            Label:=vEQLabel
        }
        if (inEquation) {
        } else {

        }
    }

    return Rebuild
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
