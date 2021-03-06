library(purrr)
library(magrittr)
library(rmarkdown)


files <- list.files(system.file("shiny", package="ggiraph"), full.names = TRUE) %>%
  map_chr(function(appdir) {
    png_ <- file.path( tempdir(), paste0( basename(appdir), ".png") )
    webshot::appshot(appdir, png_, delay = 2)
    png_
  })
files %>% map( browseURL )

files <- list.files(system.file("rmd", package="ggiraph"), full.names = TRUE, recursive = TRUE, pattern = "\\.Rmd$") %>%
  map_chr(function(rmdfile) {
    render(rmdfile)
    png_ <- file.path( tempdir(), paste0( basename(rmdfile), ".png") )
    webshot::webshot(gsub("\\.Rmd$", ".html", rmdfile), png_, delay = 2)
    png_
  })
files %>% map( browseURL )
