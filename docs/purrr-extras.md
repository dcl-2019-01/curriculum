---
title: Other purrr functions
---

<!-- Generated automatically from purrr-extras.yml. Do not edit by hand -->

# Other purrr functions <small class='program'>[program]</small>
<small>(Builds on: [purrr basics](purrr-basics.md))</small>


[map functions that output tibbles](#map-functions-that-output-tibbles)  
[Walk](#walk)  
[Predicate functions](#predicate-functions)  
In this reading, you'll learn about two more map variants, `map_dfr()` and `map_dfc()`. Then, you'll learn about `walk()`, as well as some useful purrr functions that work with functions that return either `TRUE` or `FALSE`.

The purrr package contains more functions that we can cover. The [purrr cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/purrr.pdf) is a great way to see an overview of the package or find a helpful function when you encounter a new type of iteration problem.

map functions that output tibbles
---------------------------------

You already know how to choose the appropriate map function ending to produce an atomic vector or list. There are also map function variants that produce a single tibble.

With these map functions, the assembly line worker creates a tibble for each input element, and the output conveyor belt ends up with a collection of tibbles. The worker then combines all the small tibbles into a single, larger tibble.

There are multiple ways to combine smaller tibbles into a larger tibble. purrr provides two options:

-   `map_dfr()` stacks the tibbles on top of each other.
-   `map_dfc()` stacks them side-by-side.

There are `_dfr` and `_dfc` variants of `pmap()` and `map2()` as well.

### `_dfr`

You will often use `map_dfr()` when reading in data. The following code reads in several very simple csv files that contain the names of different dinosaur genera.

``` r
read_csv("purrr-extras/file_001.csv")
```

    ## # A tibble: 1 x 2
    ##      id genus        
    ##   <int> <chr>        
    ## 1     1 Hoplitosaurus

``` r
read_csv("purrr-extras/file_002.csv")
```

    ## # A tibble: 1 x 2
    ##      id genus        
    ##   <int> <chr>        
    ## 1     2 Herrerasaurus

``` r
read_csv("purrr-extras/file_003.csv")
```

    ## # A tibble: 1 x 2
    ##      id genus      
    ##   <int> <chr>      
    ## 1     3 Coelophysis

`read_csv()` produces a tibble, and so we can use `map_dfr()` to map over all three file names and bind the resulting individual tibbles into a single tibble.

``` r
files <- str_glue("purrr-extras/file_00{1:3}.csv")
files
```

    ## purrr-extras/file_001.csv
    ## purrr-extras/file_002.csv
    ## purrr-extras/file_003.csv

``` r
files %>% 
  map_dfr(read_csv)
```

    ## # A tibble: 3 x 2
    ##      id genus        
    ##   <int> <chr>        
    ## 1     1 Hoplitosaurus
    ## 2     2 Herrerasaurus
    ## 3     3 Coelophysis

The result is a tibble with three rows and two columns, because `map_dfr()` aligns the columns of the individual tibbles by name.

The individual tibbles can have different numbers of rows or columns. `map_dfr()` creates a column for each unique column name.

``` r
read_csv("purrr-extras/file_004.csv")
```

    ## # A tibble: 2 x 3
    ##      id genus         start_period 
    ##   <int> <chr>         <chr>        
    ## 1     4 Dilophosaurus Sinemurian   
    ## 2     5 Segisaurus    Pliensbachian

``` r
c(files, "purrr-extras/file_004.csv") %>% 
  map_dfr(read_csv)
```

    ## # A tibble: 5 x 3
    ##      id genus         start_period 
    ##   <int> <chr>         <chr>        
    ## 1     1 Hoplitosaurus <NA>         
    ## 2     2 Herrerasaurus <NA>         
    ## 3     3 Coelophysis   <NA>         
    ## 4     4 Dilophosaurus Sinemurian   
    ## 5     5 Segisaurus    Pliensbachian

If some of the individual tibbles lack a column that others have, `map_dfr()` fills in with `NA` values.

### `_dfc`

`map_dfc()` is typically less useful than `map_dfr()`, because it relies on row position to stack the tibbles side-by-side. Row position is prone to error, and it will often be difficult to check if the data in each row is aligned correctly. However, if you have data with variables in different places and are positive the rows are aligned, `map_dfc()` may be appropriate.

Unfortunately, even if the individual tibbles contain a unique identifier for each row, `map_dfc()` doesn't use the identifiers to verify that the rows are aligned correctly, nor does it combine identically named columns.

``` r
read_csv("purrr-extras/file_005.csv")
```

    ## # A tibble: 1 x 3
    ##      id diet      start_period
    ##   <int> <chr>     <chr>       
    ## 1     1 herbivore Barremian

``` r
c("purrr-extras/file_001.csv", "purrr-extras/file_005.csv") %>% 
  map_dfc(read_csv)
```

    ## # A tibble: 1 x 5
    ##      id genus           id1 diet      start_period
    ##   <int> <chr>         <int> <chr>     <chr>       
    ## 1     1 Hoplitosaurus     1 herbivore Barremian

Instead, you end up with a duplicated column.

Therefore, if you have a unique identifier for each row, it is *much* better to use the identifier to join them together.

``` r
left_join(
  read_csv("purrr-extras/file_001.csv"),
  read_csv("purrr-extras/file_005.csv"),
  by = "id"
)
```

    ## # A tibble: 1 x 4
    ##      id genus         diet      start_period
    ##   <int> <chr>         <chr>     <chr>       
    ## 1     1 Hoplitosaurus herbivore Barremian

Finally, because `map_dfc()` combines tibbles by row position, the tibbles can have different numbers of columns, but must have the same number of rows.

The following files have different numbers of rows, and so `map_dfc()` produces an error.

``` r
read_csv("purrr-extras/file_006.csv")
```

    ## # A tibble: 2 x 2
    ##   diet      start_period
    ##   <chr>     <chr>       
    ## 1 herbivore Barremian   
    ## 2 carnivore Albian

``` r
c("purrr-extras/file_001.csv", "purrr-extras/file_006.csv") %>% 
  map_dfc(read_csv)
```

    ## Error in cbind_all(x): Argument 2 must be length 1, not 2

Walk
----

This short section discusses `walk()`. The walk functions work similarly to the map functions, but you use them when you're interested in applying a function that performs an action instead of producing data (e.g., `print()`).

-   [Walk](http://r4ds.had.co.nz/iteration.html#walk) \[r4ds-21.8\]

Predicate functions
-------------------

purrr has some useful functions that work with *predicate functions*, which are functions that return a single `TRUE` or `FALSE`. For example, `keep()` and `discard()` iterate over a vector and keep or discard only those elements for which the predicate function returns `TRUE`.

-   [Predicate functions](http://r4ds.had.co.nz/iteration.html#predicate-functions) \[r4ds-21.9.1\]

