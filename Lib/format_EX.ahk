script_FormatEx(FormatStr, Values*) {
    replacements := []
    clone := Values.Clone()
    for i, part in clone
        IsObject(part) ? clone[i] := "" : Values[i] := {}
    FormatStr := Format(FormatStr, clone*)
    index := 0
    replacements := []
    for _, part in Values {
        for search, replace in part {
            replacements.Push(replace)
            FormatStr := StrReplace(FormatStr, "{" search "}", "{"++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
