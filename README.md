# ObsidianScripts
 A variety of Obsidian.md helpers, in varying states of completion.



## ObsidianKnittr:

Wrapper-Script around [ObsidianHTML](https://github.com/obsidian-html/obsidian-html)  for exporting obsidianMD-notes to a variety of formats.

### Running the script:
Run the script, set your intended output formats and select an ObsidianMD-note to be converted. Note that due to the way ObsidianHTML works, this script will not work in folders which are not part of an obsidian vault.

Note that some of those require additional setup in R first. For more information, attempt to knit via R as you would normally do (f.e via RStudio) and refer to the documentation.

### Supported Formats:

1. "html_document" 
2. "pdf_document" * Note: `RMarkdown::Render()` cannot compute `.svg`-files as images if using the `pdflatex`-engine. Other engines not tested yet.
3. "word_document" 
4. "odt_document"
5. "rtf_document" 
6. "md_document"
7. "powerpoint_presentation"
8. "ioslides_presentation" 
9. "tufte::tufte_html" 
10. "github_document"

Note that those are not all formats that _could_ be supported, RMarkdown supports [those](https://rmarkdown.rstudio.com/lesson-9.html). However, not all of them are viable imo. If you want to extend them, edit the variable `PotentialOutputs` in the function `guiCreate()`.


### Dependencies:

ObsidianKnitter requires the installation of

- ObsidianHTML
- R (tested on 4.2.2, other versions might break)
- [this](https://gist.github.com/Gewerd-Strauss/8ee61682aef45c0d124b19afaeedc2fe) gist for the script.ahk include for commits older than 25.07.2023 22:10.
