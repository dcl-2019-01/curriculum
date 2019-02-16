---
title: Scoped verbs with predicates
---

<!-- Generated automatically from manip-scoped-2.yml. Do not edit by hand -->

# Scoped verbs with predicates <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Scoped verb basics](manip-scoped.md))</small>


In the *Scoped verb basics* reading, you learned about the `_at` and `_all` variants of `mutate()`, `transmute()`, `summarize()`, `select()`, and `rename()`.

In this reading, you'll learn about scoped verbs that use **predicate functions**. First, you'll learn about the third suffix, `_if`. Then, you'll learn about the scoped variants of `filter()`.

\_if
----

Like the `_at` scoped verbs, the `_if` variants apply a dplyr verb only to specified columns. The `_at` variants specify columns based on name. The `_if` variants instead use predicate functions, applying the dplyr verb only to the columns for which the predicate function is `TRUE`.

`small_towns` is a tibble with information about some very small towns. However, whoever collected the data didn't do a very good job. The town and state names aren't capitalized, and there are several missing values.

``` r
small_towns <-
  tribble(
    ~town,     ~state,         ~population,    ~sq_miles,
    "bettles", "alaska",                12,         1.74,
    "gilbert", "arkansas",              NA,         0.38,
    NA,        "hawaii",                NA,         2,
    "ruso",    "north dakota",           4,        NA
  )
```

We could use `mutate_at()` to capitalize the town and state names.

``` r
small_towns %>% 
  mutate_at(vars(town, state), str_to_title)
```

    ## # A tibble: 4 x 4
    ##   town    state        population sq_miles
    ##   <chr>   <chr>             <dbl>    <dbl>
    ## 1 Bettles Alaska               12     1.74
    ## 2 Gilbert Arkansas             NA     0.38
    ## 3 <NA>    Hawaii               NA     2   
    ## 4 Ruso    North Dakota          4    NA

However, `mutate_if()`, along with the predicate function `is.character()`, will be more compact.

Tibble columns are vectors, so `is.character()` will return a single value for each column.

``` r
is.character(small_towns$town)
```

    ## [1] TRUE

``` r
is.character(small_towns$population)
```

    ## [1] FALSE

`mutate_if()` changes just the columns where `is.character()` is `TRUE`.

``` r
small_towns %>% 
  mutate_if(is.character, str_to_title)
```

    ## # A tibble: 4 x 4
    ##   town    state        population sq_miles
    ##   <chr>   <chr>             <dbl>    <dbl>
    ## 1 Bettles Alaska               12     1.74
    ## 2 Gilbert Arkansas             NA     0.38
    ## 3 <NA>    Hawaii               NA     2   
    ## 4 Ruso    North Dakota          4    NA

`select_if()` doesn't require you to specify a function to apply to the column names. This is useful if you want to select columns by property, but don't want to alter their names. For example, we might want to select the character columns of `small_towns`.

``` r
small_towns %>% 
  select_if(is.character)
```

    ## # A tibble: 4 x 2
    ##   town    state       
    ##   <chr>   <chr>       
    ## 1 bettles alaska      
    ## 2 gilbert arkansas    
    ## 3 <NA>    hawaii      
    ## 4 ruso    north dakota

### Anonymous predicate functions

We can also use `select_if()` to find the columns with no missing values. To do so, we'll need a predicate function that returns `TRUE` if a column has no `NA`s and `FALSE` otherwise.

Unlike `as.character()`, `!is.na()` will return a value for each element in a vector.

``` r
x <- c(1, 3)
y <- c(NA, 1)

!is.na(x)
```

    ## [1] TRUE TRUE

``` r
!is.na(y)
```

    ## [1] FALSE  TRUE

To get a single value, we can use the function `all()`. `all()` returns `TRUE` if all the values in a vector are `TRUE`. A related function, `any()`, returns `TRUE` if at least one of the values is `TRUE`.

``` r
all(!is.na(x))
```

    ## [1] TRUE

``` r
all(!is.na(y))
```

    ## [1] FALSE

`all(!is.na())` is an anonymous function. Recall that, in scoped verbs, you declare anonymous functions with a `~` and use `.` to refer to the argument.

The following code selects only the columns with no `NA`s.

``` r
small_towns %>% 
  select_if(~ all(!is.na(.)))
```

    ## # A tibble: 4 x 1
    ##   state       
    ##   <chr>       
    ## 1 alaska      
    ## 2 arkansas    
    ## 3 hawaii      
    ## 4 north dakota

Unfortunately, there's only one: `state`.

Scoped `filter()`
-----------------

Each value in `small_towns` is either missing or not, and so `!is.na()` will either be `TRUE` or `FALSE` for every value. We can visualize this using `mutate_all()`.

``` r
small_towns %>% 
  mutate_all(~ !is.na(.))
```

    ## # A tibble: 4 x 4
    ##   town  state population sq_miles
    ##   <lgl> <lgl> <lgl>      <lgl>   
    ## 1 TRUE  TRUE  TRUE       TRUE    
    ## 2 TRUE  TRUE  FALSE      TRUE    
    ## 3 FALSE TRUE  FALSE      TRUE    
    ## 4 TRUE  TRUE  TRUE       FALSE

The `_if` scoped verbs use the *columns* of these `TRUE`s and `FALSE`s to decide the columns to which to apply the dplyr verb. The `filter()` scoped verbs consider the *rows* of these truth values to decide which of them to keep.

### `all_vars()` and `any_vars()`

There are multiple ways to combine a row of truth values. For example, look at the last row of the above tibble: `TRUE` `TRUE` `TRUE` `FALSE`. We can combine these truth values using **and** or **or**:

-   `TRUE` **and** `TRUE` **and** `TRUE` **and** `FALSE` is `FALSE`
-   `TRUE` **or** `TRUE` **or** `TRUE` **or** `FALSE` is `TRUE`

`all()` combines using **and**, returning `TRUE` only when all of the elements are `TRUE`. `any()` combines using **or**, returning `TRUE` when any of the elements are `TRUE`. The scoped `filter()` verbs have their own `all()` and `any()` functions designed to work with predicate functions on tibble rows: `all_vars()` and `any_vars()`.

Say we want to find all the rows in `small_towns` with no `NA`s. We need to consider all columns, so we'll use `filter_all()`. And we want *all* the values in a row to be non-`NA`, so we'll use `all_vars()`.

``` r
small_towns %>% 
  filter_all(all_vars(!is.na(.)))
```

    ## # A tibble: 1 x 4
    ##   town    state  population sq_miles
    ##   <chr>   <chr>       <dbl>    <dbl>
    ## 1 bettles alaska         12     1.74

(The function `drop_na()` actually carries out this specific operation for you.)

If we just want rows in which at least one value is not `NA`, we'll use `any_vars()`.

``` r
small_towns %>% 
  filter_all(any_vars(!is.na(.)))
```

    ## # A tibble: 4 x 4
    ##   town    state        population sq_miles
    ##   <chr>   <chr>             <dbl>    <dbl>
    ## 1 bettles alaska               12     1.74
    ## 2 gilbert arkansas             NA     0.38
    ## 3 <NA>    hawaii               NA     2   
    ## 4 ruso    north dakota          4    NA

There are no rows in `small_towns` that only contain missing values, so we didn't actually remove any data.

`filter_at()` only considers the truth values in the specified columns. The following code finds the rows with non-`NA` values for both `town` and `population`.

``` r
small_towns %>% 
  filter_at(vars(town, population), all_vars(!is.na(.)))
```

    ## # A tibble: 2 x 4
    ##   town    state        population sq_miles
    ##   <chr>   <chr>             <dbl>    <dbl>
    ## 1 bettles alaska               12     1.74
    ## 2 ruso    north dakota          4    NA

Bettles, Alaska and Ruso, North Dakota both have non-missing values for `town` and `population`. The rest of the rows had missing values in `town` or `population`, or both.

You can't just supply `all_vars()` and `any_vars()` with the name of a function.

``` r
small_towns %>% 
  filter_all(any_vars(is.na))
```

    ## Error in filter_impl(.data, quo): Evaluation error: operations are possible only for numeric, logical or complex types.

`all_vars()` and `any_vars()` always require that you use `.` to refer to the function argument, even when using a named function like `is.na()`.

``` r
small_towns %>% 
  filter_all(any_vars(is.na(.)))
```

    ## # A tibble: 3 x 4
    ##   town    state        population sq_miles
    ##   <chr>   <chr>             <dbl>    <dbl>
    ## 1 gilbert arkansas             NA     0.38
    ## 2 <NA>    hawaii               NA     2   
    ## 3 ruso    north dakota          4    NA

The above code finds all rows with at least one `NA`.

### `filter_if()`

`filter_if()` will contain two predicate functions. The first predicate function determines which columns to consider, just as you learned earlier. The second predicate function determines which rows to include.

Above, we found all rows with non-`NA` values of `town` and `population`. If we want to find all rows with non-`NA` values of the two numeric variables, we can use `filter_if()`.

``` r
small_towns %>% 
  filter_if(is.numeric, all_vars(!is.na(.)))
```

    ## # A tibble: 1 x 4
    ##   town    state  population sq_miles
    ##   <chr>   <chr>       <dbl>    <dbl>
    ## 1 bettles alaska         12     1.74

`filter_if()` uses `is.numeric()` to find the columns, and `!is.na()` to find the rows.

