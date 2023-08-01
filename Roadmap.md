# Roadmap

This is just an internal planning document to track the stuff I am currently considering.

- [ ] quarto-module
  - [ ] output_type class rework:: multiple headers for Quatro: cf:
    - <https://quarto.org/docs/reference/formats/docx.html>
    - <https://quarto.org/docs/reference/formats/html.html>
    - ...
    - likely not all options will be supported, as that will be WAY too many most likely?
  - [ ] `convertFromBookdown()` - fixes latex Environments, fixes equation label positions, fixes code chunk formatting,...
  - [ ] `convertToBookdown()` - reverses steps performed by `convertFromBookdown()`
  - [ ] adjustments to `buildRScriptContent()` torender via `quarto::render()` instead of `rmarkdown::render()`
  - [ ] add output-type to DynamicArguments.ini
  - [ ] add logic to build a `.qmd`- vs. `.rmd`-file depending on output format. (the step "Intermediary" must be modified for this to work. We could either fork and do both, or we finish to the end of the intermediary RMD-pipeline and then create a copy to be modified for qmd-formatting. Given that the intermediary formatting is blazingly fast, this should be the preferred option for the sake of a uniform input - previous modifications ensure a specific input can be more easily assumed.)
  - [ ] only issue: qmd → rmd conversion would not be viable, meaning if I write my source doc in mixed obsidian- & qadro- markdown, the rmarkdown-file will not be renderable unless I initially convert to rmd. TODO: write the conversion functions, then write extenisve unit tests for the circular conversion step.

- [ ]

- [ ] Update repository README
FIXME: ObsidianHTML.ahk -> createTemporaryObsidianHTML_Config() -> Make the exclude_glob a setting that can be edited
  - dwad
- [ ] add module to generate dynamic `.obsidian`-folders in an arbitrary root of the manuscript to speed up OHTML runtime
- [ ] clean up todo list
- [X] module for cleaning latex blocks to conform to RMD's janky standards.
- [x] bound DA-GUIs to main screen
- [x] no TOC by default in word and word2 output as they take SO MUCH SPACE
- [x] buildhistory: remove nonexistent paths on startup
