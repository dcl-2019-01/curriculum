---
title: Tidy evaluation
---

<!-- Generated automatically from tidy-eval.yml. Do not edit by hand -->

# Tidy evaluation <small class='program'>[program]</small>
<small>(Builds on: [Scoped verb basics](manip-scoped.md), [Function basics](function-basics.md))</small>


Introduction
------------

At some point during the quarter, you may have noticed that you were copy-and-pasting the same dplyr snippets again and again. You then might have remembered it's a bad idea to have more than three copies of the same code and tried to create a function. Unfortunately, if you tried this, you would have failed because dplyr verbs work a little differently than most other R functions. In this reading, you'll learn what makes dplyr verbs different, and a new set of techniques that allow you to wrap them in functions. The underlying idea that makes this possible is **tidy evaluation**, and is used throughout the tidyverse.

Tidy evaluation is a complicated subject. This reading will focus on how to do the most common operations, without explaining the theory in-depth. If you're curious and want to learn more, the following are useful resources:

-   The [Programming with dplyr](https://dplyr.tidyverse.org/articles/programming.html) vignette
-   The [Tidy evaluation with rlang](https://github.com/rstudio/cheatsheets/blob/master/tidyeval.pdf) cheat sheet
-   Ian Lyttle's [Tidyeval](https://ijlyttle.shinyapps.io/tidyeval/) interactive tutorial

Quoted arguments
----------------

To understand what makes dplyr (and many other tidyverse functions) different, we need some new vocabulary. In R, we can divide function arguments into two classes:

-   **Evaluated** arguments are the default. Code in an evaluated argument executes the same regardless of whether or not it's in a function argument.

-   Automatically **quoted** arguments are special. They behave differently depending on whether or not they're inside a function. You can tell if anargument is an automatically quoted argument by running the code outside of the function call: if you get a different result (like an error!), it's a quoted argument.

Let's make this concrete by talking about two important base R functions that you learned about early in the class: `$` and `[[`.

`$` automatically quotes the variable name. You can see this if you try to use the name outside of `$`.

``` r
df <- 
  tibble(
    y = 1,
    var = 2
  )

df$y
#> [1] 1
y
#> Error in eval(expr, envir, enclos): object 'y' not found
```

Why do we say that `$` automatically quotes the variable name? Well, take `[[`. It evaluates its argument, so you have to put quotes around it:

``` r
df[["y"]]
#> [1] 1
```

The advantage of `$` is concision. The advantage of `[[` is that you can refer to variables in the data frame indirectly:

``` r
var <- "y"
df[[var]]
#> [1] 1
```

Is there a way to allow `$` to work indirectly? i.e. is there some way to make this code do what we want?

``` r
df$var
#> [1] 2
```

Unfortunately there's no way to do this with base R.

|          | Quoted | Evaluated               |
|----------|--------|-------------------------|
| Direct   | `df$y` | `df[["y"]]`             |
| Indirect | 😢      | `var <- "y"; df[[var]]` |

The tidyverse, however, supports **unquoting** which makes it possible to evaluate arguments that would otherwise be automatically quoted. This gives the concision of automatically quoted arguments, while still allowing us to use indirection. Take `pull()`, the dplyr equivalent to `$`. If we use it naively, it works like `$`:

``` r
df %>% pull(y)
#> [1] 1
```

But with `quo()` and `!!` (pronounced bang-bang), which you'll learn about shortly, you can also refer to a variable indirectly:

``` r
var <- quo(y)
df %>% pull(!!var)
#> [1] 1
```

Here, we're not going to focus on what they actually do, but instead learn how you apply them in practice.

Wrapping quoting functions
--------------------------

Let's see how to apply your knowledge of quoting vs. evaluating arguments to write a wrapper around some duplicated dplyr code. Take this hypothetical duplicated dplyr code:

``` r
df %>% group_by(x1) %>% summarize(mean = mean(y1))
df %>% group_by(x2) %>% summarize(mean = mean(y2))
df %>% group_by(x3) %>% summarize(mean = mean(y3))
df %>% group_by(x4) %>% summarize(mean = mean(y4))
```

To create a function we need to perform three steps:

1.  Identify what is constant and what we might want to vary, and which varying parts are automatically quoted.

2.  Create a function template.

3.  Quote and unquote the automatically quoted arguments.

Looking at the above code, I'd say there are three primary things that we might want to vary:

-   The input data, which I'll call `df`.
-   The grouping variable, which I'll call `group_var`.
-   The summary variable, which I'll call `summary_var`.

`group_var` and `summary_var` need to be automatically quoted: they won't work when evaluated outside of the dplyr code.

Now we can create the function template using these names for our arguments.

``` r
grouped_mean_1 <- function(df, group_var, summary_var) {
}
```

We then copied in the duplicated code and replaced the varying parts with the variable names:

``` r
grouped_mean_1 <- function(df, group_var, summary_var) {
  df %>% 
    group_by(group_var) %>% 
    summarize(mean = mean(summary_var))
}
```

This function doesn't work (yet), but it's useful to see the error message we get:

``` r
grouped_mean_1(df = mpg, group_var = manufacturer, summary_var = hwy)
#> Error: Column `group_var` is unknown
```

The error complains that there's no column called `group_var` - that shouldn't be a surprise, because we don't want to use the variable `group_var` directly; we want to use its contents to refer to `manufacturer`. To fix this problem, we need to perform the final step: quoting and unquoting. You can think of quoting as being infectious: if you want your function to vary an automatically quoted argument, you also need to quote the corresponding argument. Then to refer to the variable indirectly, you need to unquote it.

``` r
grouped_mean_1 <- function(df, group_var, summary_var) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  
  df %>% 
    group_by(!!group_var) %>% 
    summarize(mean = mean(!!summary_var))
}

grouped_mean_1(df = mpg, group_var = manufacturer, summary_var = hwy)
#> # A tibble: 15 x 2
#>   manufacturer  mean
#>   <chr>        <dbl>
#> 1 audi          26.4
#> 2 chevrolet     21.9
#> 3 dodge         17.9
#> 4 ford          19.4
#> 5 honda         32.6
#> # … with 10 more rows
```

If you have eagle eyes, you'll have spotted that I used `enquo()` here but I showed you `quo()` before. That's because they have slightly different uses: `quo()` captures what you, the function writer types, `enquo()` captures what the user has typed:

``` r
fun_1 <- function(x) quo(x)
fun_1(a + b)
#> <quosure>
#> expr: ^x
#> env:  0x7fc4d9108260
fun_2 <- function(x) enquo(x)
fun_2(a + b)
#> <quosure>
#> expr: ^a + b
#> env:  0x7fc4d489f510
```

As a rule of thumb, use `quo()` when you're experimenting interactively at the console, and `enquo()` when you're creating a function.

Passing `...`
-------------

What if you want to allow the user to pass in any number of variables to `group_by()`? You might have noticed that some functions, like scoped verbs and the purrr functions, take `...` as a final argument, allowing you to specify additional arguments to their functions. We can use that same functionality here.

``` r
grouped_mean_2 <- function(df, summary_var, ...) {
  summary_var <- enquo(summary_var)
  
  df %>% 
    group_by(...) %>% 
    summarize(mean = mean(!!summary_var))
}

grouped_mean_2(df = mpg, summary_var = hwy, manufacturer, model)
#> # A tibble: 38 x 3
#> # Groups:   manufacturer [15]
#>   manufacturer model               mean
#>   <chr>        <chr>              <dbl>
#> 1 audi         a4                  28.3
#> 2 audi         a4 quattro          25.8
#> 3 audi         a6 quattro          24  
#> 4 chevrolet    c1500 suburban 2wd  17.8
#> 5 chevrolet    corvette            24.8
#> # … with 33 more rows
```

Notice that with `...`, we didn't have to use `enquo()` or `!!`. `...` takes care of all the quoting and unquoting for you.

You can also use `...` to pass in full expressions to dplyr verbs.

``` r
filter_fun <- function(df, ...) {
  df %>% 
    filter(...)
}

filter_fun(df = mpg, year == 1999)
#> # A tibble: 117 x 11
#>   manufacturer model  displ  year   cyl trans drv     cty   hwy fl    class
#>   <chr>        <chr>  <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#> 1 audi         a4       1.8  1999     4 auto… f        18    29 p     comp…
#> 2 audi         a4       1.8  1999     4 manu… f        21    29 p     comp…
#> 3 audi         a4       2.8  1999     6 auto… f        16    26 p     comp…
#> 4 audi         a4       2.8  1999     6 manu… f        18    26 p     comp…
#> 5 audi         a4 qu…   1.8  1999     4 manu… 4        18    26 p     comp…
#> # … with 112 more rows
```

This will work with any number of expressions. For example, say we wanted to filter on multiple conditions.

``` r
filter_fun(df = mpg, year == 1999, class == "minivan")
#> # A tibble: 6 x 11
#>   manufacturer model  displ  year   cyl trans drv     cty   hwy fl    class
#>   <chr>        <chr>  <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#> 1 dodge        carav…   2.4  1999     4 auto… f        18    24 r     mini…
#> 2 dodge        carav…   3    1999     6 auto… f        17    24 r     mini…
#> 3 dodge        carav…   3.3  1999     6 auto… f        16    22 r     mini…
#> 4 dodge        carav…   3.3  1999     6 auto… f        16    22 r     mini…
#> 5 dodge        carav…   3.8  1999     6 auto… f        15    22 r     mini…
#> # … with 1 more row
```

Assigning names
---------------

`grouped_mean_1()` doesn't name its new variables in an informative way.

``` r
grouped_mean_1(df = mpg, group_var = manufacturer, summary_var = hwy)
#> # A tibble: 15 x 2
#>   manufacturer  mean
#>   <chr>        <dbl>
#> 1 audi          26.4
#> 2 chevrolet     21.9
#> 3 dodge         17.9
#> 4 ford          19.4
#> 5 honda         32.6
#> # … with 10 more rows
```

It would be nice if we could name the `mean` column something like `hwy_mean` or `cty_mean`, depending on what `summary_var` the user passed in.

Maybe we can just apply what we've learned about `enquo()` and `!!`.

``` r
grouped_mean_3 <- function(df, group_var, summary_var, summary_var_name) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  summary_var_name <- enquo(summary_var_name)
  
  df %>% 
    group_by(!!group_var) %>% 
    summarize(!!summary_var_name = mean(!!summary_var))
}

grouped_mean_3(
  df = mpg,
  group_var = manufacturer,
  summary_var = hwy,
  summary_var_name = hwy_mean
)
#> Error: <text>:8:34: unexpected '='
#> 7:     group_by(!!group_var) %>% 
#> 8:     summarize(!!summary_var_name =
#>                                     ^
```

Unfortunately, that doesn't quite work. It turns out that you can't use `!!` on both sides of an `=`. Instead, you have to use `:=`.

``` r
grouped_mean_3 <- function(df, group_var, summary_var, summary_var_name) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  summary_var_name <- enquo(summary_var_name)
  
  df %>% 
    group_by(!!group_var) %>% 
    summarize(!!summary_var_name := mean(!!summary_var))
}

grouped_mean_3(
  df = mpg,
  group_var = manufacturer,
  summary_var = hwy,
  summary_var_name = hwy_mean
)
#> # A tibble: 15 x 2
#>   manufacturer hwy_mean
#>   <chr>           <dbl>
#> 1 audi             26.4
#> 2 chevrolet        21.9
#> 3 dodge            17.9
#> 4 ford             19.4
#> 5 honda            32.6
#> # … with 10 more rows
```

Passing vectors with `!!!`
--------------------------

Say you want to use `recode()` to recode a variable.

``` r
mpg %>% 
  mutate(drv = recode(drv, "f" = "front", "r" = "rear", "4" = "four")) %>% 
  select(drv)
#> # A tibble: 234 x 1
#>   drv  
#>   <chr>
#> 1 front
#> 2 front
#> 3 front
#> 4 front
#> 5 front
#> # … with 229 more rows
```

It will often be useful to place your recoding mapping in a parameter. For example, say you want to recode multiple variables in the same way, or you envision having to change the mapping later on.

We can store the mapping in a named character vector.

``` r
recode_key <- c("f" = "front", "r" = "rear", "4" = "four")
```

However, now `recode()` doesn't work.

``` r
mpg %>% 
  mutate(drv = recode(drv, recode_key)) %>% 
  select(drv)
#> Error: Argument 2 must be named, not unnamed
```

`recode()`, like `group_by()`, `summarize()`, and the other dplyr functions, quotes its input. We therefore need to tell it to evaluate `recode_key` immediately. Let's try `!!`.

``` r
mpg %>% 
  mutate(drv = recode(drv, !!recode_key)) %>% 
  select(drv)
#> Error: Argument 2 must be named, not unnamed
```

`!!` doesn't work because `recode_key` is a vector. Not only do we need to immediately evaluate `recode_key`, we also need to unpack its contents. To do so, we'll use `!!!`.

``` r
mpg %>% 
  mutate(drv = recode(drv, !!!recode_key)) %>% 
  select(drv)
#> # A tibble: 234 x 1
#>   drv  
#>   <chr>
#> 1 front
#> 2 front
#> 3 front
#> 4 front
#> 5 front
#> # … with 229 more rows
```

