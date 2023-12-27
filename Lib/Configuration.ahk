setupDefaultConfig(Path,RS_C,OHTML_C,QUARTO_C) {
    InputBox given_searchroot, % script.name " - Initiate settings","Please give the search root folder."
    InitialSettings=
        (LTrim
            [Config]
            backupCount=250
            bundleStarterScript=1
            useQuartoCLI=1
            defaultRelativeLevel=2
            Destination=0
            FullLogOnSuccess=0
            HistoryLimit=25
            obsidianhtml_configfile=
            obsidianTagEndChars=():'
            OHTML_OutputDir=%A_Desktop%\TempTemporal\
            OHTML_WorkDir=%A_Desktop%\TempTemporal
            OHTML_WorkDir_OwnFork=D:\Dokumente neu\Repositories\obsidian-html
            OpenParentfolderInstead=1
            RScriptPath=%rscript_path%
            searchroot=%given_searchroot%
            SetSearchRootToLastRunManuscriptFolder=1
            confirmOHTMLCustomBuild=0
            [Version]
            ObsidianHTML_Version=3.4.1
            ObsidianKnittr_Version=3.1.5
            [LastRun]
            BackupOutput=1
            bStripLocalMarkdownLinks=0
            Conversion=
            ConvertInsteadofRun=1
            ForceFixPNGFiles=0
            FullLog=0
            InsertSetupChunk=0
            KeepFileName=1
            last_output_type=
            LastRelativeLevel=1
            manuscriptpath=
            RemoveHashTagFromTags=1
            RemoveObsidianHTMLErrors=0
            RenderRMD=0
            RestrictOHTMLScope=0
            UseOwnOHTMLFork=0
            Verbose=0
            [GuiPositioning]
            H=
            W=
            X=
            Y=
            [DDLHistory]
            1=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\Submission\BE28 Internship Report.md
            2=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\Methods\Exp2 Grünflächenanalyse.md
            3=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\019-ObsHTML_EmbeddedTitleStripping_Main.md
            4=D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\311 Programming\GFA-Utilities.md
            5=D:\Dokumente neu\Obsidian NoteTaking\BE31-Thesis\100 Thesis\Submission\BE31 Thesis Report.md
            6=D:\Dokumente neu\Obsidian NoteTaking\BE31-Thesis\100 Thesis\Methods\BE31 Introduction.md
            7=D:\Dokumente neu\Obsidian NoteTaking\The Universe\007 Quarto\Quarto uninterrupted nested list-enumeration.md
            8=D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\311 Programming\Quarto Eval.md
            9=D:\Dokumente neu\Obsidian NoteTaking\The Universe\007 Quarto\Quarto Equation Referencing.md
            10=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\RMD Bookdown how to reference equations.md
            11=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\Methods\Exp2 Watering.md
            12=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\Cross Ref equations.md
            13=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\Latex PDF testing.md
            14=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\01 Internships\Applications\bex-biotec\bex-biotec.md
            15=D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\301 DailyNotes\2023\10 October\18.10.2023.md
            16=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\Callout Testing.md
            17=D:\Dokumente neu\Obsidian NoteTaking\The Universe\019-Bugtesting-Subvault\Callout Testing 2.md
            18=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\07 Thesis\BE31 Thesis\Misc\BE31 Thesis Topic.md
            19=D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\311 Programming\Introduction Tips for new winter terms.md
            20=D:\Dokumente neu\Obsidian NoteTaking\The Universe\300 Personal\311 Programming\TOC callout testing.md
            21=D:\Dokumente neu\Obsidian NoteTaking\The Universe\100 Knowledge\Chemical Oxygen Demand.md
            22=D:\Dokumente neu\Obsidian NoteTaking\The Universe - Kopie\100 Knowledge\Chemical Oxygen Demand.md
            23=D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\05\BE26 Integrated Management System and Quality Management\BE26 Exam Preparation_embedded.md

        )
    writeFile(Path,InitialSettings,"UTF-16")
    return
}
