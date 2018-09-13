---
title: Google sheets
---

<!-- Generated automatically from googlesheets.yml. Do not edit by hand -->

# Google sheets <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Parsing basics](parse-basics.md))</small>


Use the googlesheets package by Jenny Bryan to (suprise!) extract data from Google sheets. Google sheets are a surprisingly useful way of collecting data (especially with Google forms) and collaboratively working with data. googlesheets makes it easy to get that data into R and make use of it.

If you haven't already, install it:

``` r
install.packages("googlesheets")
```

``` r
# Libraries
library(tidyverse)
library(googlesheets)

# Parameters
  # URL for Gapminder example
url_gapminder <- "https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/"
```

Public sheets
-------------

Some Google sheets are public, anyone can read them. Take a look at this [example](https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/) of data from [Gapminder](https://www.gapminder.org/).

Each Google sheet has a sheet key, which is needed by googlesheets. Here's how to get the sheet key from a sheet's URL.

``` r
sheet_key <- extract_key_from_url(url_gapminder)

sheet_key
```

    ## [1] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"

Once you have the sheet key, you can use it to create a googlesheets object.

``` r
gs <- gs_key(sheet_key)

class(gs)
```

    ## [1] "googlesheet" "list"

Here's how you can list the worksheets in the Google sheet.

``` r
gs_ws_ls(gs)
```

    ## [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"

Here's how you can read in the Asia worksheet.

``` r
asia <- 
  gs %>% 
  gs_read(ws = "Asia")
```

    ## Accessing worksheet titled 'Asia'.

    ## Parsed with column specification:
    ## cols(
    ##   country = col_character(),
    ##   continent = col_character(),
    ##   year = col_integer(),
    ##   lifeExp = col_double(),
    ##   pop = col_integer(),
    ##   gdpPercap = col_double()
    ## )

``` r
asia
```

    ## # A tibble: 396 x 6
    ##    country     continent  year lifeExp      pop gdpPercap
    ##    <chr>       <chr>     <int>   <dbl>    <int>     <dbl>
    ##  1 Afghanistan Asia       1952    28.8  8425333      779.
    ##  2 Afghanistan Asia       1957    30.3  9240934      821.
    ##  3 Afghanistan Asia       1962    32.0 10267083      853.
    ##  4 Afghanistan Asia       1967    34.0 11537966      836.
    ##  5 Afghanistan Asia       1972    36.1 13079460      740.
    ##  6 Afghanistan Asia       1977    38.4 14880372      786.
    ##  7 Afghanistan Asia       1982    39.9 12881816      978.
    ##  8 Afghanistan Asia       1987    40.8 13867957      852.
    ##  9 Afghanistan Asia       1992    41.7 16317921      649.
    ## 10 Afghanistan Asia       1997    41.8 22227415      635.
    ## # ... with 386 more rows

Private sheets
--------------

Accessing private sheets requires you to authenticate to Google. Authentication is done with this command.

``` r
# Give googlesheets permission to access spreadsheet
gs_auth()
```

You will be prompted to log into Google. Once you have done this, googlesheets will create a file called `.httr-oauth` in your current directory. **NEVER CHECK THIS INTO GIT OR UPLOAD IT TO GITHUB**. (RStudio should create a `.gitignore` file to prevent `.httr-oauth` from being checked into Git or uploaded to GitHub.)

The `.httr-oauth` file allows you to avoid having to log into Google in the future. The reason you don't upload this to GitHub is that if someone were able to obtain this file, they could use it to access your Google files.

A common problem in using googlesheets is that it cannot find the `.httr-oauth` file. If you are using an RStudio project, your working directory is often the top level of the project, not the current subfolder. One way to avoid this problem is to simply make a copy of `.httr-oauth` to have one at both the top level of the project and the subfolder.

Once you are authenticated into Google, your next challenge is to find the sheet key for the Google sheet you are interested in using. You can use the following so see the sheets you have access to. The list is ordered by modification time, with the most recently modified sheets first.

``` r
gs_ls() %>% View()
```

Once you find the sheet you are interested in, you can copy its sheet key can create a variable for the it to place in the parameter section of your code.

Finally, you can read in the sheet using

``` r
df <- 
  gs_key(sheet_key) %>%
  gs_read()
```

