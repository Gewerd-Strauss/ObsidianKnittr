buildRScriptContent(Path,output_filename="",out="") {
    SplitPath % Path, , Path2, , Name
    RScriptFilePath:=strreplace(Path2,"\","\\")
        , RScriptFolder:=strreplace(Path2,"\","/")
    OutputType_Print:=""
    for _, output_type in out.sel {
        OutputType_Print.="sprintf('" output_type "')`n"
    }
    Str=
        (LTRIM
            getwd()
            if (getwd() != "%RScriptFolder%")
            {
            setwd("%RScriptFilePath%")
            getwd()
            }
            getwd()
            sprintf('Chosen Output formats:')
            %OutputType_Print%

        )
    if out.settings.bForceFixPNGFiles {
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
    else {
        bFixPNGS:=false
    }
    Name:=(output_filename!=""?output_filename:"index")
        , FormatOptions:=""
    for _,Class in out.Outputformats {
        format:=Class.AssembledFormatString
        if Instr(format,"pdf_document") {
            continue
        }
        if (format="") {
            Str2=
                (LTRIM

                    rmarkdown::render(`"index.rmd`",NULL,`"%Name%"`)`n
                )
        } else {
            Str2=
                (LTRIM

                    rmarkdown::render(`"index.rmd`",%format%,`"%Name%"`)`n
                )
        }
        Str.=Str2
        FormatOptions.= A_Tab strreplace(format,"`n",A_Tab "`n") "`n`n"
    }
    for _, Class in Out.Outputformats {
        format:=Class.AssembledFormatString
        if !Instr(format,"pdf_document") {

            continue
        }
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
        if bFixPNGs {
            Str2=
                (LTrim

                    rmarkdown::render(`"index.rmd`",%format%,`"%Name%"`)`n
                )
        }
        Str.=Str2
        FormatOptions.= A_Tab strreplace(format,"`n",A_Tab "`n") "`n`n"
    }
    Str2=
        (LTRIM

            sprintf("'build.R' successfully finished running.")
        )
    Str.=Str2
    return [Str,FormatOptions]

}

runRScript(Path,script_contents,RScript_Path:="") {
    SplitPath % Path,, OutDir
    writeFile(OutDir "\build.R",script_contents,"UTF-8-RAW",,true)
    CMD:=Quote_ObsidianHTML(RScript_Path) A_Space Quote_ObsidianHTML(strreplace(OutDir "\build.R","\","\")) ;; works with valid codefile (manually ensured no utf-corruption) from cmd, all three work for paths not containing umlaute with FileAppend
    GetStdStreams_WithInput(CMD, OutDir, InOut:="`n")
    if !validateRExecution(InOut) {
        MsgBox 0x10,% script.name " - " A_ThisFunc "()", Error encountered`; the 'build.R'-script did not run to succession.`n`nBelow is the resulting error returned. For more information`, please execute the `build.R`-script via console or RStudio.`n`nThe script will continue to cleanup its working directories now.
    }
    return
}

validateRExecution(String) {
    if InStr(String,"'build.R' successfully finished running.") {
        return true
    } else {
        return false
    }
}
