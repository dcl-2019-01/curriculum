---
title: Parsing basics
---

<!-- Generated automatically from parse-basics.yml. Do not edit by hand -->

# Parsing basics <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Data structure basics](data-structure-basics.md), [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Exporting data](export.md), [Google sheets](googlesheets.md), [Parsing details](parse-details.md))</small>


So far you’ve worked with data sets that have been bundled in R
packages, or have been created with `tibble()` or `tribble()`. Now it’s
time to learn how to read simple flat files from disk. To do this, we’ll
use functions from [readr](http://readr.tidyverse.org). readr is one of
the core tidyverse packages, so you won’t usually load it explicitly.

``` r
library(tidyverse)
#> ── Attaching packages ───────────────────────────────────────────────────── tidyverse 1.2.0.9000 ──
#> ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.4     
#> ✔ tibble  1.4.1          ✔ dplyr   0.7.4     
#> ✔ tidyr   0.7.2          ✔ stringr 1.2.0     
#> ✔ readr   1.1.1          ✔ forcats 0.2.0
#> ── Conflicts ───────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
```

## Delimited files

In this unit, we’re going to focus on delimited files. Delimited files
have a **delimiter** between each value. Two types make up the majority
of delimited files that you’ll see in the wild: csv (comma separated)
and tsv (tab separated). We’ll focus on csv files, but everything you’ll
learn applies equally to tsvs, replacing commas with tabs.

A typical csv file looks something like this:

    Sepal.Length,Sepal.Width,Petal.Length,Petal.Width,Species
    5.1,3.5,1.4,0.2,setosa
    4.9,3,1.4,0.2,setosa
    4.7,3.2,1.3,0.2,setosa
    4.6,3.1,1.5,0.2,setosa
    5,3.6,1.4,0.2,setosa
    5.4,3.9,1.7,0.4,setosa
    4.6,3.4,1.4,0.3,setosa
    5,3.4,1.5,0.2,setosa

Note that:

  - The first line gives the column names
  - Each subsequent line is one row of data
  - Each value is separated by a comma (hence the name)

Typically you can recognise a csv file by its extension: `.csv`. But
beware\! Sometimes the extension lies, and if you’re getting weird
errors when reading a file, it’s a good idea to peek inside the file
using `readr::read_lines()` and `writeLines()`, specifying the `n_max`
argument to just look at the first few lines. (You’ll learn more about
`writeLines()` when we get to strings; for now just remember it’s a
useful tool for printing lines to the screen.)

``` r
"heights.csv" %>% 
  read_lines(n_max = 10) %>%
  writeLines()
#> "earn","height","sex","ed","age","race"
#> 50000,74.4244387818035,"male",16,45,"white"
#> 60000,65.5375428255647,"female",16,58,"white"
#> 30000,63.6291977374349,"female",16,29,"white"
#> 50000,63.1085616752971,"female",16,91,"other"
#> 51000,63.4024835710879,"female",17,39,"white"
#> 9000,64.3995075440034,"female",15,26,"white"
#> 29000,61.6563258264214,"female",12,49,"white"
#> 32000,72.6985437364783,"male",17,46,"white"
#> 2000,72.0394668497611,"male",15,21,"hispanic"
```

This file illustrates another feature present in many csv files: some
values are surrounded by quotes. Confusingly, this isn’t a guarantee
that the value is a string: some csv files also surround numbers in
quotes too. As you work with more csv files you’ll discover there are
few hard and fast rules: for pretty much every crazy thing that you can
imagine, someone has done it in a csv file somewhere.

## `read_csv()`

The workhorse for reading in csv files is called `read_csv()`. You give
it a path to a csv file and it gives you back a tibble:

``` r
heights <- read_csv("heights.csv")
#> Parsed with column specification:
#> cols(
#>   earn = col_double(),
#>   height = col_double(),
#>   sex = col_character(),
#>   ed = col_integer(),
#>   age = col_integer(),
#>   race = col_character()
#> )
heights
#> # A tibble: 1,192 x 6
#>     earn height sex       ed   age race    
#>    <dbl>  <dbl> <chr>  <int> <int> <chr>   
#>  1 50000   74.4 male      16    45 white   
#>  2 60000   65.5 female    16    58 white   
#>  3 30000   63.6 female    16    29 white   
#>  4 50000   63.1 female    16    91 other   
#>  5 51000   63.4 female    17    39 white   
#>  6  9000   64.4 female    15    26 white   
#>  7 29000   61.7 female    12    49 white   
#>  8 32000   72.7 male      17    46 white   
#>  9  2000   72.0 male      15    21 hispanic
#> 10 27000   72.2 male      12    26 white   
#> # ... with 1,182 more rows
```

If you are very lucky, you can point `read_csv()` at a file and it just
works. But this is usually the exception, not the rule, and often you’ll
need to tweak some arguments.

The most important arguments to `read_csv()` are:

  - `col_names`: usually `col_names = TRUE` which tells `read_csv()`
    that the first line of the file is the column names. If there aren’t
    any column names set `col_names = FALSE` or supply a character
    vector telling `read_csv()` what they should be `col_names = c("x",
    "y", "z")`

  - `col_types`: you might have noticed that when we called `read_csv()`
    above it printed out a list of column “specifications”. That
    describes how readr converts each column into an data structure.
    readr uses some pretty good heuristics to guess the type, but
    sometimes the heuristics fail and you’ll need to supply the truth.
    You’ll learn more about that later in the course

  - It’s fairly common to encounter csv files that have a bunch of 💩 at
    the top. You can use `skip = n` to skip the first n lines, or
    `comment = "#"` to ignore all lines that start with `#`.

  - `read_csv()` expects missing values to be suppled as `NA`. If your
    file uses a different convention, use `na = "."` to override the
    default.

You’ll get to practice using these arguments in the exercises.

