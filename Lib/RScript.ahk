buildRScriptContent(Path,output_filename="",out="")
{
    SplitPath, % Path, , Path2, , Name
    RScriptFilePath:=strreplace(Path2,"\","\\")
        , RScriptFolder:=strreplace(Path2,"\","/")
    Str=
    (LTRIM
        getwd()
        if (getwd() != "%RScriptFolder%")
        {
        setwd("%RScriptFilePath%")
        getwd()
        }
        getwd()

    )
    if out.3.8
    {
        Str2=
        (LTrim
            files <- list.files(pattern="*.PNG",recursive = TRUE)
            files2 <- list.files(pattern="*.png",recursive = TRUE)
            filesF <- c(files,files2)
            lapply(filesF,ImgFix  <- function(Path="")
            {
            png_image  <- magick::image_read(Path)
            jpeg_image <- magick::image_convert(png_image,"JPEG")
            png_image  <- magick::image_convert(jpeg_image,"PNG")
            magick::image_write(png_image,Path)
            sprintf( "Fixed Path '`%s'", Path)
            })
        )
        Str.="`n" Str2
        bFixPNGS:=true
    }
    else
        bFixPNGS:=false
    Name:=(output_filename!=""?output_filename:"index")
        , FormatOptions:=""
    for _,Class in out[4]
    {
        format:=Class.AssembledFormatString
        if Instr(format,"pdf_document")
        {
            continue
        }
        if (format="")
        {
            Str2=
            (LTRIM

                rmarkdown::render(`"index.rmd`",NULL,`"%Name%"`)`n
            )
        }
        else
        {
            Str2=
            (LTRIM

                rmarkdown::render(`"index.rmd`",%format%,`"%Name%"`)`n
            )
        }
        Str.=Str2
        FormatOptions.= A_Tab strreplace(format,"`n",A_Tab "`n") "`n`n"
    }
    for _, Class in Out[4]
    {
        format:=Class.AssembledFormatString
        if !Instr(format,"pdf_document")
            continue
        Str2=
        (LTrim
            files <- list.files(pattern="*.PNG",recursive = TRUE)
            files2 <- list.files(pattern="*.png",recursive = TRUE)
            filesF <- c(files,files2)
            lapply(filesF,ImgFix  <- function(Path="")
            {
            png_image  <- magick::image_read(Path)
            jpeg_image <- magick::image_convert(png_image,"JPEG")
            png_image  <- magick::image_convert(jpeg_image,"PNG")
            magick::image_write(png_image,Path)
            sprintf( "Fixed Path '`%s'", Path)
            })
            rmarkdown::render(`"index.rmd`",%format%,`"%Name%"`)`n
        )
        if bFixPNGs
        {
            Str2=
            (LTrim

                rmarkdown::render(`"index.rmd`",%format%,`"%Name%"`)`n
            )
        }
        Str.=Str2
        FormatOptions.= A_Tab strreplace(format,"`n",A_Tab "`n") "`n`n"
    }
    return [Str,FormatOptions]

}

runRScript(Path,script_contents,RScript_Path:="")
{
    SplitPath, % Path,, OutDir
    writeFile(OutDir "\build.R",script_contents,"UTF-8-RAW",,true)

    CMD:=quote(RScript_Path) A_Space quote(strreplace(OutDir "\build.R","\","\\")) ;; works with valid codefile (manually ensured no utf-corruption) from cmd, all three work for paths not containing umlaute with FileAppend
    Run, % CMD, % OutDir, , PID
    WinWait, % "ahk_pid " PID
    WinMove, % "ahk_pid " PID, , 0, 0, 464, 75
    WinWaitClose, % "ahk_pid " PID
    return
}
