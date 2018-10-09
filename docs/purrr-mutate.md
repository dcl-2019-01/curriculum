---
title: purrr inside mutate
---

<!-- Generated automatically from purrr-mutate.yml. Do not edit by hand -->

# purrr inside mutate <small class='program'>[program]</small>
<small>(Builds on: [purrr basics](purrr-basics.md), [Vector functions](vector-functions.md))</small>


In the vector functions unit, you learned to add new variables to tibbles by giving `mutate()` a vector with an element for each row in the tibble. You saw that you can do any of the following to create this vector:

-   Give `mutate()` a single value, which is then repeated for each row in the tibble.
-   Explicitly give `mutate()` a vector with an element for each row in the tibble.
-   Create a vector using a vector function like `+` or `case_when()`.

In this reading, you'll learn about a fourth option: supplying `mutate()` with a vector created by a `map` function.

Using `map` functions inside `mutate()`
---------------------------------------

Here's a simple scalar function that turns feelings into emoticons:

``` r
emoticons <- function(x) {
  if (x == "happy") {
    ":)"
  } else if (x == "sad") {
    ":("
  } else {
    "Feeling too complex for emoticons"
  }
}
```

Recall that scalar functions fail if you try to give them vectors of values:

``` r
feelings <- c("happy", "befuddled")
emoticons(feelings)
#> Warning in if (x == "happy") {: the condition has length > 1 and only the
#> first element will be used
#> [1] ":)"
```

As you already know, we can turn `emoticons()` into a vector function by rewriting it using `if_else()`, `case_when()`, or `recode()`. Another option, however, is to leave `emoticons()` as a scalar function and apply it to the elements of `feelings` one-by-one using a `map` function:

``` r
map_chr(feelings, emoticons)
#> [1] ":)"                                "Feeling too complex for emoticons"
```

Here, we place each feeling in `feelings` on the conveyor belt. The worker picks each feeling up, finds the appropriate emoticon, and then places the emoticon on the output belt.

If we want to use `emoticons()` to add a variable to a tibble, we can place this `map` call inside `mutate()`:

``` r
df <- 
  tibble(
    feeling = c("sad", "compunctious", "happy")
  ) 

df %>% 
  mutate(emoticon = map_chr(feeling, emoticons))
#> # A tibble: 3 x 2
#>   feeling      emoticon                         
#>   <chr>        <chr>                            
#> 1 sad          :(                               
#> 2 compunctious Feeling too complex for emoticons
#> 3 happy        :)
```

Remember that when you reference an existing column inside `mutate()`, you reference the entire vector of values. Therefore, the call to `map_chr()` works inside `mutate()` just as it does outside, applying `emoticons()` to each element of the `feeling` column and producing a vector with an emoticon for each feeling in the tibble.

This pattern will work with any scalar function, but remember to think about which `map` suffix to use. If the output type of the scalar function doesn't match the `map` suffix, you'll get an error about coercion:

``` r
df %>% 
  mutate(emoticon = map_int(feeling, emoticons))
#> Error in mutate_impl(.data, dots): Evaluation error: Can't coerce element 1 from a character to a integer.
```

Additional arguments and anonymous values
-----------------------------------------

You can use the `map` functions inside `mutate()` as you would outside `mutate()`, and so you can still specify additional arguments by listing them after the function:

``` r
emoticons_2 <- function(x, default = "???") {
  if (x == "happy") {
    ":)"
  } else if (x == "sad") {
    ":("
  } else {
    default
  }
}

df %>% 
  mutate(emoticon = map_chr(feeling, emoticons_2, default = NA_character_))
#> # A tibble: 3 x 2
#>   feeling      emoticon
#>   <chr>        <chr>   
#> 1 sad          :(      
#> 2 compunctious <NA>    
#> 3 happy        :)
```

as well as create anonymous functions:

``` r
df %>% 
  mutate(is_happy = map_chr(feeling, ~ str_c("I feel ", emoticons_2(.))))
#> # A tibble: 3 x 2
#>   feeling      is_happy  
#>   <chr>        <chr>     
#> 1 sad          I feel :( 
#> 2 compunctious I feel ???
#> 3 happy        I feel :)
```

