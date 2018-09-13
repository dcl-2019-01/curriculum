---
title: Tidy evaluation
---

<!-- Generated automatically from tidy-eval.yml. Do not edit by hand -->

# Tidy evaluation <small class='program'>[program]</small>
<small>(Builds on: [Scoped verbs](manip-scoped.md), [Function basics](function-basics.md))</small>


## Introduction

At some point during the quarter, you may have noticed that you were
copy-and-pasting the same dplyr snippets again and again. You then might
have remembered it’s a bad idea to have more than three copies of the
same code and tried to create a function. Unfortunately if you tried
this, you would have failed because dplyr verbs work a little
differently to most other R functions. In this reading, you’ll learn
exactly what makes dplyr verbs different, and a new set of techniques
that allow you to wrap them in functions. The underlying idea that makes
this possible is **tidy evaluation**, and is used throughout the
tidyverse.

## Quoted arguments

To understand what makes dplyr (and many other tidyverse functions)
different, we need some new vocabulary. In R, we can divide function
arguments into two classes:

  - **Evaluated** arguments are the default. Code in an evaluated
    argument executes the same regardless of whether or not its in a
    function argument.

  - Automatically **quoted** arguments are special; they behave
    differently depending on whether or not they’re inside a function.
    You can tell if an argument is automatically quoted argument by
    running the code outside of the function call: if you get a
    different result (like an error\!), it’s a quoted argument.

Let’s make this concrete by talking about two important base R functions
that you learned about early in the class: `$` and `[[`. When we use `$`
the variable name is automatically quoted; if we try and use the name
outside of `$` it doesn’t work.

``` r
df <- data.frame(
  y = 1,
  var = 2
)

df$y
#> [1] 1

y
#> Error in eval(expr, envir, enclos): object 'y' not found
```

Why do we say that `$` automatically quotes the variable name? Well,
take `[[`. It evaluates its argument so you have to put quotes around
it:

``` r
df[["y"]]
#> [1] 1
```

The advantage of `$` is concision. The advantage of `[[` is that you can
refer to variables in the data frame indirectly:

``` r
var <- "y"
df[[var]]
#> [1] 1
```

Is there a way to allow `$` to work indirectly? i.e. is there some way
to make this code do what we want?

``` r
df$var
#> [1] 2
```

Unfortunately there’s no way to do this with base R.

|          | Quoted | Evaluated               |
| -------- | ------ | ----------------------- |
| Direct   | `df$y` | `df[["y"]]`             |
| Indirect | 😢      | `var <- "y"; df[[var]]` |

The tidyverse, however, supports **unquoting** which makes it possible
to evaluate arguments that would otherwise be automatically quoted. This
gives the concision of automatically quoted arguments, while still
allowing us to use indirection. Take `pull()`, the dplyr equivalent to
`$`. If we use it naively, it works like `$`:

``` r
df %>% pull(y)
#> [1] 1
```

But with `quo()` and `!!` (pronounced bang-bang), which you’ll learn
about shortly, you can also refer to a variable indirectly:

``` r
var <- quo(y)
df %>% pull(!!var)
#> [1] 1
```

Here, we’re not going to focus on what they actually do, but instead
learn how you apply them in practice.

## Wrapping quoting functions

Let’s see how to apply your knowledge of quoting vs. evaluating
arguments to write a wrapper around some duplicated dplyr code. Take
this hypothetical duplicated dplyr code:

``` r
df %>% group_by(x1) %>% summarise(mean = mean(y1))
df %>% group_by(x2) %>% summarise(mean = mean(y2))
df %>% group_by(x3) %>% summarise(mean = mean(y3))
df %>% group_by(x4) %>% summarise(mean = mean(y4))
```

To create a function we need to perform three steps:

1.  Identify what is constant and what we might want to vary, and which
    varying parts are automatically quoted.

2.  Create a function template.

3.  Quote and unquote the automatically quoted arguments.

Looking at the above code, I’d say there are three primary things that
we might want to vary:

  - The input data, which I’ll call `df`.
  - The grouping variable, which I’ll call `group_var`.
  - The summary variable, which I’ll call `summary_var`.

`group_var` and `summary_var` need to be automatically quoted: they
won’t work when evaluated outside of the dplyr code.

Now we can create the function template using these names for our
arguments.

``` r
grouped_mean <- function(df, group_var, summary_var) {
}
```

I then copied in the duplicated code and replaced the varying parts with
the variable names:

``` r
grouped_mean <- function(df, group_var, summary_var) {
  df %>% 
    group_by(group_var) %>% 
    summarise(mean = mean(summary_var))
}
```

This function doesn’t work (yet), but it’s useful to see the error
message we get:

``` r
grouped_mean(mtcars, cyl, mpg)
#> Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

The error complains that there’s no column called `group_var` - that
shouldn’t be a surprise, because we don’t want to use the variable
`group_var` directly; we want to use its contents to refer to `cyl`. To
fix this problem we need to perform the final step: quoting and
unquoting. You can think of quoting as being infectious: if you want
your function to vary an automated quoted argument, you also need to
quote the corresponding argument. Then to refer to the variable
indirectly, you need to unquote it.

``` r
grouped_mean <- function(df, group_var, summary_var) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  
  df %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}
```

If you have eagle eyes, you’ll have spotted that I used `enquo()` here
but I showed you `quo()` before. That’s because they have slightly
different uses: `quo()` captures what you, the function writer types,
`enquo()` captures what the user has typed:

``` r
fun1 <- function(x) quo(x)
fun1(a + b)
#> <quosure>
#>   expr: ^x
#>   env:  0x7fbd01679110

fun2 <- function(x) enquo(x)
fun2(a + b)
#> <quosure>
#>   expr: ^a + b
#>   env:  0x7fbcfcd3da78
```

As a rule of thumb, use `quo()` when you’re experimenting interactively
at the console, and `enquo()` when you’re creating a function.

## Theory

To finish off, watch this short video to learn the basics of the
underlying
theory.

<iframe width="560" height="315" src="https://www.youtube.com/embed/nERXS3ssntw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen>

</iframe>

