#!/usr/local/bin/Rscript
suppressWarnings(suppressPackageStartupMessages(
  devtools::load_all(here::here(), quiet = TRUE)
))

cat_line(cli::rule("Building site", line = 2))

cat_line(cli::rule("Building units"))
build_units()

cat_line(cli::rule("Building storyboard"))
build_storyboard()

cat_line(cli::rule("Building overview graph"))
build_overview()

cat_line(cli::rule("Done", line = 2))
