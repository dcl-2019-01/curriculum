---
title: Scoped verb basics
---

<!-- Generated automatically from manip-scoped.yml. Do not edit by hand -->

# Scoped verb basics <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Programming with dplyr](manip-programming.md), [Tidy evaluation](tidy-eval.md))</small>


You'll often want to operate on multiple columns at the same time. Luckily, there are **scoped** versions of dplyr verbs that allow you to apply that verb to multiple columns at once.

Scoped verbs are powerful. They allow you to quickly carry out complex wrangling that would otherwise be much more difficult.

Each dplyr verb comes in three scoped variants. The name of each variant consists of the dplyr verb plus one of three suffixes: `_at`, `_all`, or `_if`. In this reading, you'll learn about the `_all` and `_at` scoped verbs.

### \_all and \_at scoped verbs

`x` is a simple tibble.

``` r
x <-
  tibble(
    number_1 = c(1, 1, 51),
    number_2 = c(3, 42, NA),
    letter = c("w", "x", "w")
  )

x
```

    ## # A tibble: 3 x 3
    ##   number_1 number_2 letter
    ##      <dbl>    <dbl> <chr> 
    ## 1        1        3 w     
    ## 2        1       42 x     
    ## 3       51       NA w

We can use `summarize()` to find the number of distinct values for each variable.

``` r
x %>% 
  summarize(
    number_1 = n_distinct(number_1),
    number_2 = n_distinct(number_2),
    letter = n_distinct(letter)
  )
```

    ## # A tibble: 1 x 3
    ##   number_1 number_2 letter
    ##      <int>    <int>  <int>
    ## 1        2        3      2

There are only three variables in `x`. If `x` had more columns, however, writing out each `n_distinct()` call would be a hassle. Instead, we can use a scoped verb to succinctly summarize all columns at once. This will save time and reduce code duplication.

Each scoped verb has a suffix and a prefix. The prefix specifies the dplyr verb and the suffix specifies the scoped variant. There are two suffixes you'll learn about in this reading:

-   `_all`: applies the dplyr verb to all variables
-   `_at`: applies the dplyr verb to selected variables

#### \_all

To summarize all the variables in `x` as we did above, we'll use the scoped verb `summarize_all()`.

Each scoped verb takes a tibble and a function as arguments. In this case, the function is `n_distinct()`.

``` r
x %>% 
  summarize_all(n_distinct)
```

    ## # A tibble: 1 x 3
    ##   number_1 number_2 letter
    ##      <int>    <int>  <int>
    ## 1        2        3      2

Notice that we wrote `n_distinct`, and not `n_distinct()`. Recall that `n_distinct` is the name of the function, while `n_distinct()` calls the function.

#### \_at

To summarize just variables `number_1` and `number_2`, we'll use `summarize_at().` The `_at` verbs take an additional argument: a list of columns specified inside the function `vars()`.

``` r
x %>% 
  summarize_at(vars(number_1, number_2), n_distinct)
```

    ## # A tibble: 1 x 2
    ##   number_1 number_2
    ##      <int>    <int>
    ## 1        2        3

Inside `vars()`, you can specify variables using the same syntax as `select()`. You can give their full names, use `contains()`, remove some with `-`, etc.

``` r
x %>% 
  summarize_at(vars(contains("number")), n_distinct)
```

    ## # A tibble: 1 x 2
    ##   number_1 number_2
    ##      <int>    <int>
    ## 1        2        3

### Scoped `mutate()`

If you want to apply `mutate()` to multiple columns, the same logic applies. `mutate_all()` will apply the same function to each column, changing all of them in the same way.

``` r
x %>% 
  mutate_all(lag)
```

    ## # A tibble: 3 x 3
    ##   number_1 number_2 letter
    ##      <dbl>    <dbl> <chr> 
    ## 1       NA       NA <NA>  
    ## 2        1        3 w     
    ## 3        1       42 x

And `mutate_at()` changes just the variables specified inside `vars()`.

``` r
x %>% 
  mutate_at(vars(starts_with("number")), lag)
```

    ## # A tibble: 3 x 3
    ##   number_1 number_2 letter
    ##      <dbl>    <dbl> <chr> 
    ## 1       NA       NA w     
    ## 2        1        3 x     
    ## 3        1       42 w

### Anonymous functions

`n_distinct()` and `lag()` are both named functions. However, scoped verbs can also take anonymous functions.

To declare an anonymous function in a scoped verb, you use the helper function `funs()` with `.` to refer to the function's argument.

For example, the following code tells us which variables have more than two distinct values.

``` r
x %>% 
  summarise_all(funs(n_distinct(.) > 2))
```

    ## # A tibble: 1 x 3
    ##   number_1 number_2 letter
    ##   <lgl>    <lgl>    <lgl> 
    ## 1 FALSE    TRUE     FALSE

The `.` is a placeholder. It refers to each column specified in the scoped verb in turn. In this case, it refers to `number_1`, then `number_2`, then `letter`.

### `...`

The scoped verbs all take `...` as a final argument. You can use `...` to specify arguments to a named function without having to write an anonymous function.

For example, you might not want to count `NA`s as distinct values. We could write an anonymous function that doesn't count `NA`s.

``` r
x %>% 
  summarize_all(funs(n_distinct(., na.rm = TRUE)))
```

    ## # A tibble: 1 x 3
    ##   number_1 number_2 letter
    ##      <int>    <int>  <int>
    ## 1        2        2      2

It's simpler, however, to just specify the additional argument after the function name.

``` r
x %>% 
  summarize_all(n_distinct, na.rm = TRUE)
```

    ## # A tibble: 1 x 3
    ##   number_1 number_2 letter
    ##      <int>    <int>  <int>
    ## 1        2        2      2

The `...` functionality makes the code easier to read, avoiding the extra syntax involved in anonymous functions. You can use it to add any number of arguments.

### Multiple functions

You can also use `funs()` to supply the scoped variants of `mutate()`, `summarize()`, and `transmute()` with multiple functions.

``` r
x %>% 
  summarise_at(vars(number_1, number_2), funs(mean, median), na.rm = TRUE)
```

    ## # A tibble: 1 x 4
    ##   number_1_mean number_2_mean number_1_median number_2_median
    ##           <dbl>         <dbl>           <dbl>           <dbl>
    ## 1          17.7          22.5               1            22.5

The scoped verb will create identifying column names.

### Scoped `select()` and `rename()`

The scoped variants of `select()` and `rename()` work very similarly to those of `mutate()`, `transmute()`, and `summarize()`. However, they apply the specified function(s) to *column names*, instead of to column values.

The following code changes all column names to lowercase.

``` r
capitals <-
  tribble(
    ~Country, ~Capital,
    "Namibia", "Windhoek",
    "Georgia", "Tbilisi"
  )

capitals %>% 
  rename_all(str_to_lower)
```

    ## # A tibble: 2 x 2
    ##   country capital 
    ##   <chr>   <chr>   
    ## 1 Namibia Windhoek
    ## 2 Georgia Tbilisi

The scoped variants of `rename()` will generally be more helpful than those of `select()`.

