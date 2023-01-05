OutDir:="A\Path.path"
RSCRIPT_PATH:="RSCRIPT\RSCRIPT.RSCRIPT"
RSCRIPT_PATH:=RScript_Path
BUILD_RPATH:=strreplace(OutDir "\build.R","\","\\")
OUTDIR_PATH:=OutDir

Ahk_build=
        (Join`s LTRIM

            `nrun, `% `"`"`"%RSCRIPT_PATH%"""
            A_Space """%BUILD_RPATH%"""
            , `% "%OUTDIR_PATH%"
        )
FileAppend, % Ahk_build, % A_ScriptFullPath
return

Quote(String)
{ ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
    return """" String """"
}


/*

run, % """C:\Program Files\R\R-4.2.0\bin\Rscript.exe""" A_Space """C:\\Users\\Claudius Main\\Desktop\\TempTemporal\\Coming Out\\build.R""" , % "C:\Users\Claudius Main\Desktop\TempTemporal\Coming Out"

run, % """"RSCRIPT\RSCRIPT.RSCRIPT""""   """A\\Path.path\\build.R""" , % "A\Path.path"
run, % """"RSCRIPT\RSCRIPT.RSCRIPT""""   """A\\Path.path\\build.R""" , % "A\Path.path"
run, % """RSCRIPT\RSCRIPT.RSCRIPT"""   """A\\Path.path\\build.R""" , % "A\Path.path"
run, % """RSCRIPT\RSCRIPT.RSCRIPT""" A_Space """A\\Path.path\\build.R""" , % "A\Path.path"