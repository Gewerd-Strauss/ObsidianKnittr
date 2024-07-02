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
            ObsidianKnittr_Version=4.1.7
            [LastRun]
            BackupOutput=1
            bStripLocalMarkdownLinks=0
            ConvertInsteadofRun=1
            KeepFileName=1
            last_output_type=
            LastRelativeLevel=1
            manuscriptpath=
            RemoveHashTagFromTags=1
            RemoveObsidianHTMLErrors=0
            RenderToOutputs=0
            RestrictOHTMLScope=0
            UseOwnOHTMLFork=0
            Verbose=0
            [GuiPositioning]
            H=
            W=
            X=
            Y=
            [DDLHistory]

        )
    writeFile(Path,InitialSettings,"UTF-16")
    return
}
setupDefaultDA(Path) {
    str=
        (LTRIM
            ;PACKAGE::FORMAT
            `t;Key:Control|Type|Default|String|Tab3Parent|Value|Other
            `t;Disable a package by prepending a ";" on the non-indented line at the start of the package definition.

            quarto::html
            `tnumber-depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth of sections that should be numbered?"|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#section-numbering"|Linktext:?
            `tnumber-sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#section-numbering"|Linktext:?
            `ttoc:Checkbox|Type:boolean|Default:1|String:"Do you want to include a ToC?"|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#table-of-contents"|Linktext:?
            `ttoc-depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#table-of-contents"|Linktext:?
            `t; toc-expand
            `ttoc-location:DDL|Type:String|Default:"left"|String:"Select ToC Location"|ctrlOptions:body,left,right|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#table-of-contents"|Linktext:?
            `ttoc-title:Edit|Type:String|String:"Set the ToC's Title"|Default:"Table of Contents"|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/output-formats/html-basics.html#table-of-contents"|Linktext:?
            `tdf-print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#tables"|Linktext:?
            `t;TODO: Finish this format, modify DynamicArguments.ahk to accept lists via a parameters "Tab3Parent" relationship: so we can map which kinds of string format we need for each package.
            `tfig-width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#figures"|Linktext:?
            `tfig-height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#figures"|Linktext:?
            `tfig-cap-location:DDL|Type:String|Default:margin|String:"Select location of figure caption"|ctrlOptions:Top,Bottom,Margin|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#figures"|Linktext:?
            `ttbl-cap-location:DDL|Type:String|Default:margin|String:"Select location of table caption"|ctrlOptions:Top,Bottom,Margin|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#tables"|Linktext:?
            `tfig-title:combobox|Type:String|Default:Figure|String:"Specify title prefix on figure-captions"|ctrlOptions:Figure,Fig.|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#figures"|Linktext:?
            `tfig-responsive:Checkbox|Type:boolean|Default:1|String:"Do you want to make images responsive?"|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/html.html#figures"|Linktext:?
            `temail-obfuscation:DDL|Type:String|Default:none|String:"Specify a method for obfuscating 'mailto'-links in HTML documents"|ctrlOptions:none,javascript,references|Tab3Parent:3. Misc
            `treference-location:DDL|Type:String|Default:margin|String:"Set reference position"|ctrloptions:bottom,margin|Tab3Parent:3. Misc
            `tcitation-location:DDL|Type:String|Default:margin|String:"Set citation position"|ctrloptions:bottom,margin|Tab3Parent:3. Misc
            `tcitations-hover:Checkbox|Type:boolean|Default:1|String:"Enables a hover popup for citations that shows the reference information"|Tab3Parent:3. Misc|Link:"https://quarto.org/docs/output-formats/html-basics.html#reference-popups"|Linktext:?
            `tfootnotes-hover:Checkbox|Type:boolean|Default:1|String:"Enables a hover popup for footnotes that shows the footnote contents"|Tab3Parent:3. Misc|Link:"https://quarto.org/docs/output-formats/html-basics.html#reference-popups"|Linktext:?
            `tcode-fold:DDL|Type:String|Default:true|String:"Collapse code into HTML <details> tag so the user can display it on-demand"|ctrlOptions:true,false,show|Tab3Parent:3. Misc|Link:"https://quarto.org/docs/output-formats/html-code.html#folding-code"|Linktext:?
            `tdate:combobox|Type:String|Default:now|String:"Specify dynamic date to use when compiling"|ctrloptions:today,now,last-modified|Tab3Parent:3. Misc
            `tdate-format:combobox|Type:String|Default:DD.MM.YYYY|String:"Specify date format to use when compiling"|ctrloptions:iso,full,long,medium,short,DD.MM.YYYY|Tab3Parent:3. Misc
            `tstandalone:Checkbox|Type:boolean|Default:1|String:"Produce output with an appropriate header and footer, aka not a fragment"|ctrloptions:disabled|Tab3Parent:3. Misc
            `tcode-overflow:DDL|Type:String|Default:Scroll|String:|ctrlOptions:Scroll,Wrap|Tab3Parent:3. Misc|Link:"https://quarto.org/docs/output-formats/html-code.html#code-overflow"|Linktext:?
            `tembed-resources:Checkbox|Type:boolean|Default:1|String:"Produce a standalone HTML file with no external dependencies using 'data:'-URIs"|ctrloptions:disabled|Tab3Parent:3. Misc
            `tlink-external-icon:Checkbox|Type:boolean|Default:0|String:"Show a special icon next to links that leave the current site"|Tab3Parent:4. Links|Link:"https://quarto.org/docs/reference/formats/html.html#links"|Linktext:?
            `tlink-external-newwindow:Checkbox|Type:boolean|Default:1|String:"Open external links in a new browser window/tab (don't navigate the current tab)"|Tab3Parent:4. Links|Link:"https://quarto.org/docs/reference/formats/html.html#links"|Linktext:?
            `tauthor:combobox|Type:String|Default:"Gewerd Strauss"|String:"Set Author for this output format"|ctrlOptions:Author1,Gewerd Strauss,redacted|Tab3Parent:3. Misc
            `tfilesuffix:Meta|Value:html
            `tinputsuffix:Meta|Value:qmd
            `trenderingpackage_start:Meta|Value:quarto::quarto_render("index.qmd",execute_params = list(
            `trenderingpackage_end:Meta|Value:),output_format = "html","`%name`%.html")
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:quarto
        )
    str2=
        (LTRIM
            quarto::docx
            `tnumber-depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth of sections that should be numbered?"|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/reference/formats/docx.html#numbering"|Linktext:?
            `tnumber-sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. ToC and Numbering|Value:0|Link:"https://quarto.org/docs/reference/formats/docx.html#numbering"|Linktext:?
            `ttoc:Checkbox|Type:boolean|Default:0|String:"Do you want to include a ToC?"|Tab3Parent:1. ToC and Numbering|Value:0|Link:"https://quarto.org/docs/reference/formats/docx.html#table-of-contents"|Linktext:?f
            `ttoc-depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. ToC and Numbering|Value:2|Link:"https://quarto.org/docs/reference/formats/docx.html#table-of-contents"|Linktext:?
            `t;number-offset:Edit|Type:String|Default:0|String:"Offset for section headings in output?"|Tab3Parent:1. ToC and Numbering|Value:0|Link:"https://quarto.org/docs/reference/formats/docx.html#numbering"|Linktext:?
            `t;toc-location:DDL|Type:String|Default:"right"|String:"Select ToC Location"|ctrlOptions:body,left,right|Tab3Parent:1. ToC and Numbering
            `ttoc-title:Edit|Type:String|String:"Set the ToC's Title"|Default:"Table of Contents"|Tab3Parent:1. ToC and Numbering|Link:"https://quarto.org/docs/reference/formats/docx.html#table-of-contents"|Linktext:?
            `treference-doc:File|Type:String|Default:"BE28 Template Internship Report - Kopie.docx"|String:"Choose format-reference Word-file."|SearchPath:"D:\Dokumente neu\PaperStyle_WordReferenceFiles\"|Tab3Parent:3. General|Link:"https://quarto.org/docs/reference/formats/docx.html#format-options"|Linktext:?
            `tdf-print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/docx.html#tables"|Linktext:?
            `t;TODO: Finish this format, modify DynamicArguments.ahk to accept lists via a parameters "Tab3Parent" relationship: so we can map which kinds of string format we need for each package.
            `tfig-height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/docx.html#figures"|Linktext:?
            `tfig-width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/docx.html#figures"|Linktext:?
            `t;out-width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figure containers"|Tab3Parent:2. Figures and Tables
            `t;fig-asp:Edit|Type:Number|Default
            `tfig-dpi:Edit|Type:Integer|Default:96|String:"Set figure dpi"|ctrlOptions:Number|Tab3Parent:2. Figures and Tables|Link:"https://quarto.org/docs/reference/formats/docx.html#figures"|Linktext:?
            `t;date:combobox|Type:String|Default:now|String:"Specify dynamic date to use when compiling"|ctrloptions:today,now,last-modified|Tab3Parent:3. Misc
            `t;date-format:combobox|Type:String|Default:DD.MM.YYYY|String:"Specify date format to use when compiling"|ctrloptions:iso,full,long,medium,short,DD.MM.YYYY|Tab3Parent:3. Misc
            `tauthor:combobox|Type:String|Default:"Author1"|String:"Set Author for this output format"|ctrlOptions:Author1,Gewerd Strauss,redacted|Tab3Parent:3. General
            `trenderingpackage_start:Meta|Value:quarto::quarto_render("index.qmd",execute_params = list(
            `trenderingpackage_end:Meta|Value:),output_format = "docx","`%name`%.docx")
            `tfilesuffix:Meta|Value:docx
            `tinputsuffix:Meta|Value:qmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:quarto
        )
    str3=
        (LTRIM
            quarto::pdf
            `t; Title & Author
            `t;title:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t;subtitle:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t;date:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t;author:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t;abstract:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `tthanks:Edit|Type:String|String:"The contents of an acknowledgments footnote after the document title"|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t;order:Edit|Tab3Parent:Title && Author|Link:"https://quarto.org/docs/reference/formats/pdf.html#title-author"|Linktext:?
            `t; Format Options
            `tpdf-engine:combobox|Type:String|Default:xelatex|String:"Use specified pdf engine. Give full path if engine not on PATH. Do not use 'pdflatex' if you have unicode-characters"|ctrlOptions:xelatex,pdflatex,lualatex,tectonic,latexmk,context,wkhtmltopdf,prince,weasyprint,pdfroff|Tab3Parent:Format options|Link:"https://quarto.org/docs/reference/formats/pdf.html#format-options"|LinkText:?
            `tpdf-engine-opt:edit|Type:String|Default:""|String:"Give command-line argument to the pdf-engine"|Tab3Parent:Format options|Link:"https://quarto.org/docs/reference/formats/pdf.html#format-options"|LinkText:?
            `t; Table of contents
            `ttoc:checkbox|Type:boolean|Default:1|String:"Include an automatically generated ToC"|Tab3Parent:Table of Contents|Link:"https://quarto.org/docs/reference/formats/pdf.html#table-of-contents"|LinkText:?
            `ttoc-depth:edit|Type:integer|Default:3|String:"Specify the number of section levels to include in the ToC"|Tab3Parent:Table of Contents|Link:"https://quarto.org/docs/reference/formats/pdf.html#table-of-contents"|LinkText:?
            `ttoc-title:edit|Type:String|Default:"Table of Contents"|String:"The title used for the ToC"|Tab3Parent:Table of Contents|Link:"https://quarto.org/docs/reference/formats/pdf.html#table-of-contents"|LinkText:?
            `tlof:checkbox|Type:boolean|Default:1|String:"Print a list of figures in the document"|Tab3Parent:Table of Contents|Link:"https://quarto.org/docs/reference/formats/pdf.html#table-of-contents"|LinkText:?
            `tlot:checkbox|Type:boolean|Default:1|String:"Print a list of tables in the document"|Tab3Parent:Table of Contents|Link:"https://quarto.org/docs/reference/formats/pdf.html#table-of-contents"|LinkText:?
            `t; Numbering
            `tnumber-depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth of sections that should be numbered?"|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:Numbering|Link:"https://quarto.org/docs/reference/formats/pdf.html#numbering"|Linktext:?
            `tnumber-sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:Numbering|Link:"https://quarto.org/docs/reference/formats/pdf.html#numbering"|Linktext:?
            `t;number-offset:Edit|Type:Integer|Default:3|String:"What is the maximum depth of sections that should be numbered?"|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:Numbering|Link:"https://quarto.org/docs/reference/formats/pdf.html#numbering"|Linktext:?
            `tshift-heading-level-by:Edit|Type:Number|Default:1|String:"Shift heading levels by a positive or negative integer (e.g. -1 or +2)"|ctrlOptions:Number|Tab3Parent:Numbering|Link:"https://quarto.org/docs/reference/formats/pdf.html#numbering"|Linktext:?
            `t;top-level-devision:Checkbox|Type:boolean|Default:1|String:"Treat top-level headings as the given division type (default, section, chapter, or part)."|Tab3Parent:Numbering|Link:"https://quarto.org/docs/reference/formats/pdf.html#numbering"|Linktext:?
            `t; Fonts
            `t; mainfont
            `t; monofont
            `t; fontsize
            `t; fontenc
            `t; fontfamily
            `t; fontfamilyoptions
            `t; sansfont
            `t; mathfont
            `t; CJKmainfont
            `t; mainfontoptions
            `t; sansfontoptions
            `t; monofontoptions
            `t; mathfontoptions
            `t; CJKoptions
            `t; microtypeoptions
            `t; linestretch
            `t; Colors
            `t; linkcolor
            `t; filecolor
            `t; citecolor
            `t; urlcolor
            `t; toccolor
            `t; colorlinks
            `t; Layout
            `t; fig-cap-location
            `t; tbl-cap-location
            `t; documentclass
            `t; classoption
            `t; pagestyle
            `t; papersize
            `t; grid
            `t; margin-left
            `t; margin-right
            `t; margin-top
            `t; margin-bottom
            `t; geometry
            `t; hyperrefoptions
            `t; indent
            `t; block-headings
            `t; Code
            `t; code-line-numbers
            `t; code-annotaions
            `t; code-block-border-left
            `t; code-block-bg
            `t; highlight-style
            `t; syntax-definitions
            `t; listings
            `t; indented-code-classes
            `t; Execution
            `t; eval
            `t; echo
            `t; output
            `t; warning
            `t; error
            `t; include
            `t; cache
            `t; freeze
            `t; Figures
            `tfig-align:DDL|Type:String|Default:"default"|String:"Figure horizontal alignment"|ctrlOptions:default,left,right,center|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `t; fig-env|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-pos:edit|Type:String|Default:"H"|String:"LaTeX figure position arrangement to be used in `\begin{figure}[]`"|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-cap-location:DDL|Type:String|Default:bottom|String:"Where to place figure captions"|ctrlOptions:top,bottom,margin|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-height:Edit|Type:Integer|Default:8|String:"Set default height in inches for figures"|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-format:DDL|Type:String|Default:png|String:"Default format for figures generated by Matplotlib or R graphics"|ctrlOptions:retina,png,jpeg,svg,pdf|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `tfig-dpi:Edit|Type:Integer|Default:96|String:"Default DPI for figures generated by Matplotlib or R graphics"|ctrlOptions:Number|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `t; fig-asp|Tab3Parent:Figures|Link:"https://quarto.org/docs/reference/formats/pdf.html#figures"|Linktext:?
            `t; Tables
            `ttbl-colwidths:Combobox|Type:String|Default:auto|String:"How to scale table column widths which ware wider than 'columns' characters (72 by default)?|Default:auto|ctrlOptions:auto,true,false|Tab3Parent:Tables|Link:"https://quarto.org/docs/reference/formats/pdf.html#tables"|Linktext:?
            `ttbl-cap-location:DDL|Type:String|Default:bottom|String:"Where to place table captions"|ctrlOptions:top,bottom,margin|Tab3Parent:Tables|Link:"https://quarto.org/docs/reference/formats/pdf.html#tables"|Linktext:?
            `tdf-print:DDL|Type:String|Default:default|String:"Method used to print tables in Knitr engine documents"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:Tables|Link:"https://quarto.org/docs/reference/formats/pdf.html#tables"|Linktext:?
            `t; References
            `t; bibliography|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; csl|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; cite-method|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; citeproc:Checkbox|Type:boolean|Default:1|String:"Turn on built-in citation processing."|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; biblatexoptions:edit|Type:String|String:"A list of options for BibLaTeX"|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; natbiboptions:edit|Type:String|String:"One or more options to provide for natbib when generating a bibliography"|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; biblio-style:edit|Type:String|String:"The bibliography style to use (e.g. `\bibliographystyle{dinat}` when using natbib or biblatex"|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; biblio-title|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; biblio-config|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; citation-abbreviations|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; link-citations|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; link-bibliography|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; notes-after-punctuation|Tab3Parent:References|Link:"https://quarto.org/docs/reference/formats/pdf.html#references"|Linktext:"?"
            `t; Footnotes
            `t; links-as-notes|Tab3Parent:Footnotes|Link:"https://quarto.org/docs/reference/formats/pdf.html#footnotes"|Linktext:?
            `t; reference-location|Tab3Parent:Footnotes|Link:"https://quarto.org/docs/reference/formats/pdf.html#footnotes"|Linktext:?
            `t; Citation
            `t; citation|Tab3Parent:Citation|Link:"https://quarto.org/docs/reference/formats/pdf.html#citation"|Linktext:?
            `t; Language
            `t; lang|Tab3Parent:Language|Link:"https://quarto.org/docs/reference/formats/pdf.html#language"|Linktext:?
            `t; language|Tab3Parent:Language|Link:"https://quarto.org/docs/reference/formats/pdf.html#language"|Linktext:?
            `t; dir|Tab3Parent:Language|Link:"https://quarto.org/docs/reference/formats/pdf.html#language"|Linktext:?
            `t; Includes
            `t; include-before-body|Tab3Parent:Includes|Link:"https://quarto.org/docs/reference/formats/pdf.html#includes"|Linktext:?
            `t; include-after-body|Tab3Parent:Includes|Link:"https://quarto.org/docs/reference/formats/pdf.html#includes"|Linktext:?
            `t; include-in-header|Tab3Parent:Includes|Link:"https://quarto.org/docs/reference/formats/pdf.html#includes"|Linktext:?
            `t; metadata-files|Tab3Parent:Includes|Link:"https://quarto.org/docs/reference/formats/pdf.html#includes"|Linktext:?
            `t; Metadata
            `t; keywords|Tab3Parent:Metadata|Link:"https://quarto.org/docs/reference/formats/pdf.html#metadata"|Linktext:?
            `t; subject|Tab3Parent:Metadata|Link:"https://quarto.org/docs/reference/formats/pdf.html#metadata"|Linktext:?
            `t; title-meta|Tab3Parent:Metadata|Link:"https://quarto.org/docs/reference/formats/pdf.html#metadata"|Linktext:?
            `t; author-meta|Tab3Parent:Metadata|Link:"https://quarto.org/docs/reference/formats/pdf.html#metadata"|Linktext:?
            `t; date-meta|Tab3Parent:Metadata|Link:"https://quarto.org/docs/reference/formats/pdf.html#metadata"|Linktext:?
            `t; Rendering
            `t; from|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; output-file|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; output-ext|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; template|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; template-partials|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; standalone|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; filters|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; shortcodes|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; keep-md|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; keep-ipynb|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; ipynb-filters|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; keep-tex|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; extract-media|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; resource-path|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; default-image-extension|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; abbreviations|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; dpi|Tab3Parent:Rendering|Link:"https://quarto.org/docs/reference/formats/pdf.html#rendering"|Linktext:?
            `t; Latexmk
            `tlatex-auto-mk:Checkbox|Type:boolean|Default:1|String:"Use Quarto's built-in PDF rendering wrapper (includes support for automatically installing missing LaTeX packages)"|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `tlatex-auto-install:Checkbox|Type:boolean|Default:1|String:"Enable/disable automatic LaTeX package installation"|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `tlatex-min-runs:Edit|Type:number|Default:1|String:"Minimum number of compilation passes."|ctrlOptions:number|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `tlatex-max-runs:Edit|Type:number|Default:5|String:"Minimum number of compilation passes."|ctrlOptions:number|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-clean|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-makeindex|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-makeindex-opts|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-tlmgr-opts|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-output-dir|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-tinytex:checkbox|Type:boolean|Default:0|String:"Use tinytex for pdf-compilation?"|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t;latex-input-paths|Tab3Parent:Latexmk|Link:"https://quarto.org/docs/reference/formats/pdf.html#latexmk"|Linktext:?
            `t; Text Output
            `t; ascii
            `t; Meta
            `trenderingpackage_start:Meta|Value:quarto::quarto_render("index.qmd",execute_params = list(
            `trenderingpackage_end:Meta|Value:),output_format = "pdf","`%name`%.pdf")
            `tfilesuffix:Meta|Value:pdf
            `tinputsuffix:Meta|Value:qmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:quarto
            `t;|Link:"https://quarto.org/docs/reference/formats/pdf.html#format-options"|Tab3Parent:Format options|LinkText:?
            `t;Link:"https://quarto.org/docs/reference/formats/pdf.html#format-options"|Linktext:?
        )
    str4=
        (LTRIM
            bookdown::html_document2
            `ttoc:Checkbox|Type:boolean|Default:1|String:"Do you want to include a ToC?"|Tab3Parent:1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `ttoc_float:Checkbox|Type:boolean|Default:1|String:"Do you want to set the ToC floating?"|Tab3Parent:1. General|Value:0
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tanchor_sections
            `tsection_divs
            `tfig_width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `t;fig_retina 
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `tdev
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `tcode_folding
            `tcode_download
            `tcode_contained
            `ttheme
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `thighlight_downlit
            `tmath_method
            `tmathjax
            `ttemplate
            `textra_dependencies
            `tCSS
            `tINCLUDES
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tlib_dir
            `t; md_extensions
            `t; reference_docx:File|Type:String|Default:Template_.docx|String:"Choose format-reference Word-file."|SearchPath:"D:\Dokumente neu\PaperStyle_WordReferenceFiles\"
            `tglobal_numbering:Checkbox|Type:boolean|Default:1|String:"Do you want to number tables and figures globally throughout the document?"|Tab3Parent:1. General
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:html
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:bookdown
        )
    str5=
        (LTRIM
            bookdown::word_document2
            `ttoc:Checkbox|Type:boolean|Default:0|String:"Do you want to include a ToC?"|Tab3Parent:1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:3|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tfig_width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `treference_docx:File|Type:String|Default:"BE28 Template Internship Report - Kopie.docx"|String:"Choose format-reference Word-file."|SearchPath:"D:\Dokumente neu\PaperStyle_WordReferenceFiles\"|Tab3Parent:1. General
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `tglobal_numbering:Checkbox|Type:boolean|Default:1|String:"Do you want to number tables and figures globally throughout the document?"|Tab3Parent:1. General
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:docx
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:bookdown
            `t;md_extensions
        )
    str6=
        (LTRIM
            bookdown::pdf_document2
            `t;Key:Control|Type|Default|String|Tab3Parent:format|Value|Other|Max|Min
            `ttoc:Checkbox|Type:boolean|Default:1|String:"Do you want to include a ToC?"|Tab3Parent:1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tfig_width:Edit|Type:Integer|Default:5|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:4|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_crop:Checkbox|Type:boolean|Default:1|String:"Do you want to crop figures? (requires installation of 'pdfcrop' and 'ghostscript' on R-Path."|Tab3Parent:2. Figures and Tables
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `t;dev
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `t;template:File|Type:String|Default:|String:"Choose Pandoc template for rendering."|SearchPath:""
            `tkeep_tex:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the intermediate 'tex'-file generated by Knitr?"|Tab3Parent:3. Misc
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tlatex_engine:DDL|Type:String|Default:pdflatex|String:"Choose latex engine for producing pdf output"|ctrlOptions:pdflatex,lualatex,xelatex,tectonic|Tab3Parent:3. Misc
            `tcitation_package:DDL|Type:String|Default:default|String:"Choose latex package for processing citations. Choose 'default' to use 'pandoc-citeproc'."|ctrlOptions:natbib,biblatex,default|Tab3Parent:3. Misc
            `tincludes
            `tmd_extensions
            `toutput_extensions
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `t;extra_dependencies
            `tglobal_numbering:Checkbox|Type:boolean|Default:1|String:"Do you want to number tables and figures globally throughout the document?"|Tab3Parent:1. General
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:pdf
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:bookdown
        )
    str7=
        (LTRIM
            rmarkdown::html_document
            `ttoc:Checkbox|Type:boolean|Default:1|String:""Do you want to include a ToC?""|Tab3Parent:1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `ttoc_float:Checkbox|Type:boolean|Default:1|String:"Do you want to set the ToC floating?"|Tab3Parent:1. General|Value:0
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tanchor_sections
            `tsection_divs
            `tfig_width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `t;fig_retina
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `tdev
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `tcode_folding
            `tcode_download
            `tcode_contained
            `ttheme
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `thighlight_downlit
            `tmath_method
            `tmathjax
            `ttemplate
            `textra_dependencies
            `tCSS
            `tINCLUDES
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tlib_dir
            `t; md_extensions
            `t; reference_docx:File|Type:String|Default:Template_.docx|String:"Choose format-reference Word-file."|SearchPath:"D:\Dokumente neu\PaperStyle_WordReferenceFiles\"
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:html
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:rmarkdown
        )
    str8=
        (LTRIM
            rmarkdown::word_document
            `t;Key:ControlType|VariableType:bool/int/float/string|Default:0|String:"Do you want to add a TOC?"|Tab3Parent:format|Value:0|BLALA:JUDAS
            `ttoc:Checkbox|Type:boolean|Default:0|String:"Do you want to include a ToC?"|Tab3Parent:1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:3|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tfig_width:Edit|Type:Integer|Default:8|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:6|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `treference_docx:File|Type:String|Default:"BE28 Template Internship Report.docx"|String:"Choose format-reference Word-file."|SearchPath:"D:\Dokumente neu\PaperStyle_WordReferenceFiles\"|Tab3Parent:1. General
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `t;md_extensions
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:docx
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:rmarkdown
        )
    str9=
        (LTRIM
            rmarkdown::pdf_document
            `t;Key:Control|Type|Default|String|Tab3Parent:format|Value|Other|Max|Min
            `ttoc:Checkbox|Type:boolean|Default:1|String:"Do you want to include a ToC?"|1. General|Value:0
            `ttoc_depth:Edit|Type:Integer|Default:3|String:"What is the maximum depth the ToC should display?"|Max:5|Min:1|ctrlOptions:Number|Tab3Parent:1. General|Value:2
            `tnumber_sections:Checkbox|Type:boolean|Default:1|String:"Do you want to number your sections automatically?"|Tab3Parent:1. General|Value:0
            `tfig_width:Edit|Type:Integer|Default:5|String:"Set default width in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_height:Edit|Type:Integer|Default:4|String:"Set default height in inches for figures"|Tab3Parent:2. Figures and Tables
            `tfig_crop:Checkbox|Type:boolean|Default:1|String:"Do you want to crop figures? (requires installation of 'pdfcrop' and 'ghostscript' on R-Path."|Tab3Parent:2. Figures and Tables
            `tfig_caption:Checkbox|Type:boolean|Default:1|String:"Do you want to add figure captions?"|Tab3Parent:2. Figures and Tables
            `t;dev
            `tdf_print:DDL|Type:String|Default:"kable"|String:"Choose Method for printing data frames"|ctrlOptions:default,kable,tibble,paged|Tab3Parent:2. Figures and Tables
            `thighlight:DDL|Type:String|Default:"tango"|String:"Set highlightmethod"|ctrlOptions:default,tango,pygments,kate,monochrome,espresso,zenburn,haddock,breezedark|Tab3Parent:3. Misc
            `t;template:File|Type:String|Default:|String:"Choose Pandoc template for rendering."|SearchPath:""
            `tkeep_tex:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the intermediate 'tex'-file generated by Knitr?"|Tab3Parent:3. Misc
            `tkeep_md:Checkbox|Type:boolean|Default:0|String:"Do you want to keep the markdown file generated by Knitr?"|Tab3Parent:3. Misc
            `tlatex_engine:DDL|Type:String|Default:pdflatex|String:"Choose latex engine for producing pdf output"|ctrlOptions:pdflatex,lualatex,xelatex,tectonic|Tab3Parent:3. Misc
            `tcitation_package:DDL|Type:String|Default:default|String:"Choose latex package for processing citations. Choose 'default' to use 'pandoc-citeproc'."|ctrlOptions:natbib,biblatex,default|Tab3Parent:3. Misc
            `tincludes
            `tmd_extensions
            `toutput_extensions
            `tpandoc_args:Edit|Type:String|Default:NULL|String:"Set Pandoc arguments"|ctrlOptions:w300, h60|Tab3Parent:3. Misc
            `t;extra_dependencies
            `trenderingpackage:Meta|Value:rmarkdown::render("index.rmd",`%format`%,"`%name`%")
            `tfilesuffix:Meta|Value:pdf
            `tinputsuffix:Meta|Value:rmd
            `tdateformat:Meta|Value:{A_DD}.{A_MM}.{A_YYYY}
            `tpackage:Meta|Value:rmarkdown

        )
    writeFile(Path,str "`n`n" str2 "`n`n" str3 "`n`n" str4 "`n`n" str5 "`n`n" str6 "`n`n" str7 "`n`n" str8 "`n`n" str9 "`n`n","UTF-8")
}
