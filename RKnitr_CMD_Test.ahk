Str:="setwd(""C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa"")`n"
for k,format in ["html_document","word_document"]
{
    Str2=
    (LTRIM
    Rmarkdown::render(`"index.rmd`",`"%format%`")`n
    )
    Str.=Str2
}
    a:=strreplace(Str,"""","")
FileDelete, C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa\build.R
FileAppend, % Str, C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa\build.R
Run, C:\Program Files\R\R-4.2.0\bin\Rscript.exe e C:\Users\Claudius Main\Desktop\TempTemporal\TestPaper_apa\build.R
    ; run C:\Program Files\R\R-4.2.0\bin\Rscript.exe e %Str%,
    LastWorkDir:=A_WorkingDir
    SetWorkingDir, A_ScriptDir "\Test"
    run, cmd, % A_WorkingDir
    RunWait, C:\Program Files\R\R-4.2.0\bin\Rscript.exe e %Str%, ,Max, Rscript_PID
    SetWorkingDir, Test

; "C:\Program Files\R\R-4.2.0\bin\Rscript.exe" e "Rmarkdown::render(""index.rmd"",""html_document"")"
; "C:\Program Files\R\R-4.2.0\bin\Rscript.exe" e Rmarkdown::render("index.rmd","html_document")
; ;Rmarkdown::render("input.rmd","%format%")