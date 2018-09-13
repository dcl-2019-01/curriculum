---
title: Scoped verbs
---

<!-- Generated automatically from manip-scoped.yml. Do not edit by hand -->

# Scoped verbs <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Programming with dplyr](manip-programming.md), [Tidy evaluation](tidy-eval.md))</small>


Introduction
------------

Each of the single table verbs comes in three additional forms with the suffixes `_if`, `_at`, and `_all`. These **scoped** variants allow you to work with multiple variables with a single call:

-   `_if` allows you to pick variables based on a predicate function like `is.numeric()` or `is.character()`.

-   `_at` allows you to pick variables using the same syntax as `select()`.

-   `_all` operates on all variables.

These variants are coupled with `funs()` and `vars()` helpers that let you describe which functions you want to apply to which variables.

The scoped verbs are useful because they can allow you to save a lot of typing. For example, imagine that you want to group `nycflights13::flights` by destination, then compute the mean the delay variables, the distance, and the time in the air. That's a lot of typing!

``` r
library(nycflights13)

flights %>%
  group_by(dest) %>%
  summarise(
    dep_delay = mean(dep_delay, na.rm = TRUE),
    arr_delay = mean(arr_delay, na.rm = TRUE),
    distance = mean(distance, na.rm = TRUE),
    air_time = mean(air_time, na.rm = TRUE)
  )
```

We can save a bunch of typing by using `summarise_ar()` instead:

``` r
flights %>%
  group_by(dest) %>%
  summarise_at(
    vars(dep_delay, arr_delay, distance, air_time),
    funs(mean(., na.rm = TRUE))
  )
#> # A tibble: 105 x 5
#>   dest  dep_delay arr_delay distance air_time
#>   <chr>     <dbl>     <dbl>    <dbl>    <dbl>
#> 1 ABQ       13.7       4.38     1826    249  
#> 2 ACK        6.46      4.85      199     42.1
#> 3 ALB       23.6      14.4       143     31.8
#> 4 ANC       12.9     - 2.50     3370    413  
#> 5 ATL       12.5      11.3       757    113  
#> # ... with 100 more rows
```

You can imagine that this gets even more helpful as the number of variables increases.

I'll illustrate the three variants in detail for `summarise()`, then show how you can use the same ideas with `mutate()` and `filter()`. You'll need the scoped variants of the other verbs less frequently, but when you do, it should be straightforward to generalise what you've learn here.

Summarise
---------

### `summarise_all()`

The simplest variant to understand is `summarise_all()`. The first argument is a tibble. The second argument is one of more functions wrapped inside of the `funs()` helper:

``` r
df <- tibble(
  x = runif(100),
  y = runif(100),
  z = runif(100)
)
summarise_all(df, funs(mean))
#> # A tibble: 1 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 0.462 0.499 0.536
summarise_all(df, funs(min, max))
#> # A tibble: 1 x 6
#>      x_min  y_min  z_min x_max y_max z_max
#>      <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1 0.000941 0.0258 0.0264 0.998 0.968 0.995
```

You might wonder why we need `funs()`. You don't actually need it if you have a single function, but it's necessary for technical reasons for more than one function, and always using it makes your code more consistent.

You can also use `funs()` with custom expressions: just use a `.` as a pronoun to denote the "current" column:

``` r
summarise_all(df, funs(mean(., na.rm = TRUE)))
#> # A tibble: 1 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 0.462 0.499 0.536
```

NB: unfortunately `funs()` does not use the same syntax as purrr - you don't need the `~` in front of a custom function like you do in purrr. This is an unfortunate oversight that is relatively hard to fix, but will hopefully be resolved in dplyr one day.

### `summarise_at()`

`summarise_at()` allows you to pick columns to summarise in the same way as `select()`. There is one small difference: you need to wrap the complete selection with the `vars()` helper:

``` r
summarise_at(df, vars(-z), funs(mean))
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.462 0.499
```

You can put anything inside `vars()` that you can put inside a call to `select()`:

``` r
library(nycflights13)
summarise_at(flights, vars(contains("delay")), funs(mean), na.rm = TRUE)
#> # A tibble: 1 x 2
#>   dep_delay arr_delay
#>       <dbl>     <dbl>
#> 1      12.6      6.90
summarise_at(flights, vars(starts_with("arr")), funs(mean), na.rm = TRUE)
#> # A tibble: 1 x 2
#>   arr_time arr_delay
#>      <dbl>     <dbl>
#> 1     1502      6.90
```

(Note that `na.rm = TRUE` is passed on to `mean()` in the same way as in `purrr::map()`.)

If the function doesn't fit on one line, put each argument on a new line:

``` r
flights %>%
  group_by(dest) %>% 
  summarise_at(
    vars(contains("delay"), distance, air_time), 
    funs(mean), 
    na.rm = TRUE
  )
#> # A tibble: 105 x 5
#>   dest  dep_delay arr_delay distance air_time
#>   <chr>     <dbl>     <dbl>    <dbl>    <dbl>
#> 1 ABQ       13.7       4.38     1826    249  
#> 2 ACK        6.46      4.85      199     42.1
#> 3 ALB       23.6      14.4       143     31.8
#> 4 ANC       12.9     - 2.50     3370    413  
#> 5 ATL       12.5      11.3       757    113  
#> # ... with 100 more rows
```

By default, the newly created columns have the shortest names needed to uniquely identify the output. See the examples in the documentation if you want to force names when they're not otherwise needed.

``` r
# Note the use of extra spaces to make the 3rd argument line
# up - this makes it easy to scan the code and see what's different
summarise_at(df, vars(x),    funs(mean))
#> # A tibble: 1 x 1
#>       x
#>   <dbl>
#> 1 0.462
summarise_at(df, vars(x),    funs(min, max))
#> # A tibble: 1 x 2
#>        min   max
#>      <dbl> <dbl>
#> 1 0.000941 0.998
summarise_at(df, vars(x, y), funs(mean))
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.462 0.499
summarise_at(df, vars(x, y), funs(min, max))
#> # A tibble: 1 x 4
#>      x_min  y_min x_max y_max
#>      <dbl>  <dbl> <dbl> <dbl>
#> 1 0.000941 0.0258 0.998 0.968
```

### `summarise_if()`

`summarise_if()` allows you to pick variables to summarise based on some property of the column, specified by a **predicate** function. A predicate function is a function that takes a whole column and returns either a single `TRUE` or a single `FALSE`. Commonly this a function that tells you if a variable is a specific type like `is.numeric()`, `is.character()`, or `is.logical()`.

This makes it easier to summarise only numeric columns:

``` r
starwars %>%
  group_by(species) %>%
  summarise_if(is.numeric, funs(mean), na.rm = TRUE)
#> # A tibble: 38 x 4
#>   species  height  mass birth_year
#>   <chr>     <dbl> <dbl>      <dbl>
#> 1 Aleena     79.0  15.0      NaN  
#> 2 Besalisk  198   102        NaN  
#> 3 Cerean    198    82.0       92.0
#> 4 Chagrian  196   NaN        NaN  
#> 5 Clawdite  168    55.0      NaN  
#> # ... with 33 more rows
```

Mutate
------

`mutate_all()`, `mutate_if()` and `mutate_at()` work in a similar way to their summarise equivalents.

``` r
mutate_all(df, funs(log10))
#> # A tibble: 100 x 3
#>        x       y       z
#>    <dbl>   <dbl>   <dbl>
#> 1 -0.183 -0.243  -0.250 
#> 2 -0.380 -0.0805 -0.0945
#> 3 -0.266 -0.0280 -1.16  
#> 4 -0.100 -0.946  -0.0936
#> 5 -0.565 -0.120  -0.662 
#> # ... with 95 more rows
```

If you need a transformation that is not already a function, it's easiest to create your own function:

``` r
double <- function(x) x * 2
half <- function(x) x / 2

mutate_all(df, funs(half, double))
#> # A tibble: 100 x 9
#>       x     y      z x_half y_half z_half x_double y_double z_double
#>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.656 0.572 0.563   0.328 0.286  0.281     1.31     1.14     1.13 
#> 2 0.417 0.831 0.804   0.208 0.415  0.402     0.834    1.66     1.61 
#> 3 0.542 0.938 0.0691  0.271 0.469  0.0345    1.08     1.88     0.138
#> 4 0.794 0.113 0.806   0.397 0.0567 0.403     1.59     0.227    1.61 
#> 5 0.272 0.759 0.218   0.136 0.379  0.109     0.545    1.52     0.435
#> # ... with 95 more rows
```

The default names are generated in the same way as `summarise()`. That means that you may want to use a `transmute()` variant if you want to apply multiple transformations and don't want the original values:

``` r
transmute_all(df, funs(half, double))
#> # A tibble: 100 x 6
#>   x_half y_half z_half x_double y_double z_double
#>    <dbl>  <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1  0.328 0.286  0.281     1.31     1.14     1.13 
#> 2  0.208 0.415  0.402     0.834    1.66     1.61 
#> 3  0.271 0.469  0.0345    1.08     1.88     0.138
#> 4  0.397 0.0567 0.403     1.59     0.227    1.61 
#> 5  0.136 0.379  0.109     0.545    1.52     0.435
#> # ... with 95 more rows
```

Filter
------

The `filter()` variants work a little differently to `summarise()` and `mutate()`. Like `summarise()` and `mutate()` you must choose between either all variables (`_all`), selecting variables by name (`_at`), or selecting by some property of the variable (`_if`). However, the `funs()` is no longer enough because you need to say whether the filtering functions should be combined with "and" (`&`) or "or" (`|`). That means that `funs()` is not enough:

``` r
diamonds %>% filter_all(funs(. == 0))
#> Error: `.vars_predicate` must be a call to `all_vars()` or `any_vars()`, not list
```

You have to be explicit and say you either want the rows where the all of the variables equal 0:

``` r
diamonds %>% filter_if(is.numeric, all_vars(. == 0))
#> # A tibble: 0 x 10
#> # ... with 10 variables: carat <dbl>, cut <ord>, color <ord>,
#> #   clarity <ord>, depth <dbl>, table <dbl>, price <int>, x <dbl>,
#> #   y <dbl>, z <dbl>
```

Or the rows where any of the variables equals zero:

``` r
diamonds %>% filter_if(is.numeric, any_vars(. == 0))
#> # A tibble: 20 x 10
#>   carat cut     color clarity depth table price     x     y     z
#>   <dbl> <ord>   <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
#> 1  1.00 Premium G     SI2      59.1  59.0  3142  6.55  6.48     0
#> 2  1.01 Premium H     I1       58.1  59.0  3167  6.66  6.60     0
#> 3  1.10 Premium G     SI2      63.0  59.0  3696  6.50  6.47     0
#> 4  1.01 Premium F     SI2      59.2  58.0  3837  6.50  6.47     0
#> 5  1.50 Good    G     I1       64.0  61.0  4731  7.15  7.04     0
#> # ... with 15 more rows
```

This is particularly useful if you're looking for missing values:

``` r
flights %>% filter_all(any_vars(is.na(.)))
#> # A tibble: 9,430 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1     1525           1530    - 5.00     1934
#> 2  2013     1     1     1528           1459     29.0      2002
#> 3  2013     1     1     1740           1745    - 5.00     2158
#> 4  2013     1     1     1807           1738     29.0      2251
#> 5  2013     1     1     1939           1840     59.0        29
#> # ... with 9,425 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

