---
title: purrr map with multiple inputs
---

<!-- Generated automatically from purrr-parallel.yml. Do not edit by hand -->

# purrr map with multiple inputs <small class='program'>[program]</small>
<small>(Builds on: [purrr inside mutate](purrr-mutate.md))</small>


In the previous purrr units, you learned how to use the `map()` functions to iterate over a single vector and apply a function to each element. `purrr` also contains functions that can iterate over several vectors in parallel, supplying the first elements of each vector to a given function, then the second, then the third, etc.

`purrr`'s parallel mapping functions allow the assembly line to have multiple, syncronized input conveyor belts. Our factory worker uses the nth item from each input conveyor belt to create a new object that becomes the nth item on the output conveyor belt.

Below, you'll learn about the `map2()` functions, which can handle two input vectors, and the `pmap()` functions, which can handle any number of input vectors.

`map2()`
--------

The `map2()` functions are very similar to the `map()` functions you learned about previously, but they take two input vectors instead of one.

``` r
x <- c(1, 2, 4)
y <- c(6, 5, 3)

map2_dbl(x, y, min)
```

    ## [1] 1 2 3

Since the `map2()` functions iterate along the two vectors in parallel, they need to be the same length.

``` r
x2 <- c(1, 2, 4)
y2 <- c(6, 5)

map2_dbl(x2, y2, min)
```

    ## Error: `.x` (3) and `.y` (2) are different lengths

Inside anonymous functions in the `map()` functions, you refer to each element of the input vector as `.`. In the `map2()` functions, you refer to elements of the first vector as `.x` and elements of the second as `.y`.

``` r
map2_chr(x, y, ~ str_glue("The minimum of {.x} and {.y} is {min(.x, .y)}."))
```

    ## [1] "The minimum of 1 and 6 is 1." "The minimum of 2 and 5 is 2."
    ## [3] "The minimum of 4 and 3 is 3."

If you don't create an anonymous function and use a named function instead, the first vector will be supplied as the first argument to the function and the second vector will be supplied as the second argument.

`pmap()`
--------

There are no `map3()` or `map4()` functions. Instead, you can use a `pmap()` ("p" for parallel) function to map over more than two vectors.

The `pmap()` functions work slightly differently than the `map()` and `map2()` functions. In `map()` and `map2()` functions, you specify the vector(s) to supply to the function. In `pmap()` functions, however, you specify a single list that contains all the vectors you want to supply to your function.

``` r
list(
  a = c(50, 60, 70),
  b = c(10, 90, 40),
  c = c(1, 105, 2000)
) %>% 
  pmap_dbl(min)
```

    ## [1]  1 60 40

`pmap_dbl()` takes the nth elements of `a`, `b`, and `c` and calls `min()` with these three values to obtain the nth output value.

Tibbles are lists, so they work in exactly the same way.

``` r
tibble(
  a = c(50, 60, 70),
  b = c(10, 90, 40),
  c = c(1, 105, 2000)
) %>% 
  pmap_dbl(min)
```

    ## [1]  1 60 40

### Anonymous functions

When using an anonymous function in `pmap()`, use `..1`, `..2`, `..3`, etc. to refer to the different vectors.

``` r
state_animals <- 
  tribble(
    ~state, ~type, ~animal, ~binomial,
    "Alaska", "land mammal", "Moose", "Alces alces",
    "Delaware", "bug", "7-spotted ladybug", "Coccinella septempunctata",
    "Hawaii", "fish", "Humuhumunukunukuāpuaʻa", "Rhinecanthus rectangulus",
    "Maine", "crustacean", "lobster", "Homarus americanus" 
  )

state_animals %>% 
  pmap_chr(~ str_glue("The {..1} state {..2} is the {..3}."))
```

    ## [1] "The Alaska state land mammal is the Moose."          
    ## [2] "The Delaware state bug is the 7-spotted ladybug."    
    ## [3] "The Hawaii state fish is the Humuhumunukunukuāpuaʻa."
    ## [4] "The Maine state crustacean is the lobster."

`..1` refers to the first variable (here, `state`), `..2` to the second, and so on.

### Named functions

For named functions, `pmap()` will match the names of the input list or tibble with the names of the function arguments. This can result in elegant code. But for this to work, it's important that:

-   The list or tibble input variable names match those of the function arguments.
-   You must have **the same number of input variables as function arguments**.

Let's start with an example of what doesn't work. First, we'll create a named function.

``` r
state_sentence <- function(animal, type, state) {
  str_glue("The {state} state {type} is the {animal}.")
}
```

This does not work:

``` r
state_animals %>% 
  pmap_chr(state_sentence)
```

    ## Error in .f(state = .l[[c(1L, i)]], type = .l[[c(2L, i)]], animal = .l[[c(3L, : unused argument (binomial = .l[[c(4, i)]])

`state_animals` has four variables, but `state_sentence` is expecting three. The number of input variables must match the number of function arguments.

You can fix the problem by simply getting rid of the unused variable.

``` r
state_animals %>% 
  select(-binomial) %>% 
  pmap_chr(state_sentence)
```

    ## [1] "The Alaska state land mammal is the Moose."          
    ## [2] "The Delaware state bug is the 7-spotted ladybug."    
    ## [3] "The Hawaii state fish is the Humuhumunukunukuāpuaʻa."
    ## [4] "The Maine state crustacean is the lobster."

Note that the order of the variables in `state_animals` is different than the order of the arguments in `state_sentence`. `pmap()` matches input variables with function arguments by name, so the orderings don't matter. However, this means that the two sets of names must be identical.

