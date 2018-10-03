---
title: purrr basics
---

<!-- Generated automatically from purrr-basics.yml. Do not edit by hand -->

# purrr basics <small class='program'>[program]</small>
<small>(Builds on: [Function basics](function-basics.md))</small>


``` r
library(tidyverse)
```

Iteration as an assembly line
-----------------------------

You'll often need to apply the same function to each element of a list or atomic vector. The purrr package supplies a variety of functions that allow you to easily iterate through a vector and do the same thing to each element. In this reading, you'll learn about the most basic purrr functions: the map functions.

(Take a look at the [purrr cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/purrr.pdf) for a preview of some other purrr functions.)

To get a sense of what the map functions do, imagine an assembly line in a factory. One conveyor belt, the *input belt*, transports various objects to a worker. The worker picks up each object and does something with it, but, importantly, never changes the object itself. For example, she might make a mold of the object, or grab a piece of plastic corresponding to the color of the object. Then, she places her new creation (the mold, piece of plastic, etc.) on the *output belt*, and the original object back on the input belt. She does this until there are no new objects to process on the input belt and the conveyor belt stops. The factory then ends up with the same number of objects on the input and output conveyor belts.

You can imagine the map functions as this factory. You supply the map function with a list or vector (the objects on the input conveyor belt) and a function (what the worker does with each object). Then, map makes the conveyor belts run, applying the function to each element in the original vector to create a new vector of the same length, while never changing the original.

The next section will explain how the map functions work in more detail.

The map functions
-----------------

`x` is a list of integer vectors:

``` r
x <- 
  list(
    a = c(1L, 2L, 4L),
    b = c(88L),
    c = c(9L, 10L, 55L, 2L)
  )
```

Say we want to know the length of each vector in `x`. First, let's just find the length of the first element (`a`) in `x`:

``` r
length(x$a)
#> [1] 3
```

`x` only has three elements, so we could repeat this process for `x$b` and `x$c` relatively quickly. However, you'll often encounter much longer vectors and manual repetition will not be possible. Additionally, as you learned with functions, it's a good idea to reduce code duplication, as your code will be easier to read and you won't have to find every spot you used a bit of code in order to make changes.

We'll use a map function to take the length of each element of `x` in one line. All map functions take the following arguments:

-   A list or vector: what items go on the input conveyor belt?
-   A function: what should the worker do with each item?

In this example, we want to put `a`, `b`, and `c`, the vectors in the list `x`, on the conveyor belt and we want the worker to take the length of each vector.

Each call to `length()` will return an integer, and so we'll use the map function designed to return a vector of integers. As you'll see later, there's a map function for each output type.

``` r
map_int(x, length)
#> a b c 
#> 3 1 4
```

We now have a vector of integers representing the length of each element of `x`.

(Notice that we use `length` as the argument, not `length()`. `length()` calls the function, while `length` refers to the function object itself.)

### Anonymous functions

`length` is a named function. You can call the function just by calling `length()`. However, it's possible to create a function, called an **anonymous function**, without assigning it a name. You won't have a name with which to call the anonymous function later, but that's okay if you don't plan on using the function again.

For example, say you want to multiply the length of each vector in `x` by 2. There's no named function for that, but you can write an anonymous function within `map_int()`:

``` r
map_int(x, ~ length(.) * 2L)
#> a b c 
#> 6 2 8
```

Notice the syntax: `~` marks the beginning of the function and `.` refers to each element in `x`. You can think of `.` as a placeholder, referring to `a`, then `b`, and then `c` as the conveyor belt delivers each object to the worker.

You could also write your own named function to use within `map_int()`:

``` r
double_length <- function(x) {
  length(x) * 2L
}

map_int(x, double_length)
#> a b c 
#> 6 2 8
```

You may want to write your a named function instead of using an anonymous function if you want to use the function again. Otherwise, you can just use an anonymous function.

### ...

If you look at the documentation for the map functions, you'll notice that they all take a third argument `...`. The `...` allows you to specify additional arguments to the function without having to create an anonymous function.

For example, instead of:

``` r
map_int(x, ~ nth(., n = 3))
#>  a  b  c 
#>  4 NA 55
```

which returns the third value of each vector, you can write:

``` r
map_int(x, nth, n = 3)
#>  a  b  c 
#>  4 NA 55
```

You can also specify more than one argument:

``` r
map_int(x, nth, n = 3, default = 0L)
#>  a  b  c 
#>  4  0 55
```

### Output type

So far, we've only used one map function: `map_int()`.

In the section above, we had to multiply the length of each vector by an integer (the `L` creates an integer) in order for the code to run. This won't work:

``` r
map_int(x, ~ length(.) * 2)
#> Error: Can't coerce element 1 from a double to a integer
```

Why? Because `length(.) * 2` returns a double, and `map_int()` requires that the function create integers.

If we want a vector of doubles, we need to use `map_dbl()`:

``` r
map_dbl(x, ~ length(.) * 2)
#> a b c 
#> 6 2 8
```

The other map functions work similarly.

If your function creates characters, use `map_chr()` to create a vector of characters:

``` r
map_chr(x, typeof)
#>         a         b         c 
#> "integer" "integer" "integer"
```

If your function creates logicals, use `map_lgl()`:

``` r
map_lgl(x, is_integer)
#>    a    b    c 
#> TRUE TRUE TRUE
```

You can also use `map()` to create a list. Remember that a list can contain any type of element. For example, the following code creates a list of integer vectors:

``` r
map(x, ~ c(99, .))
#> $a
#> [1] 99  1  2  4
#> 
#> $b
#> [1] 99 88
#> 
#> $c
#> [1] 99  9 10 55  2
```

In summary:

-   `map()` makes a list.
-   `map_lgl()` makes a logical vector.
-   `map_int()` makes an integer vector.
-   `map_dbl()` makes a double vector.
-   `map_chr()` makes a character vector.

`map()` is the most general function, since any R data structure can be stored in a list. But if your output is one of the four atomic vector types, it is better to use the corresponding map variant.

The `.`s can sometimes make anonymous functions look confusing:

``` r
map_int(x, ~ sum(.[. %% 2 == 0]))
#>  a  b  c 
#>  6 88 12
```

but you can always plug in a single element of your input vector to help you understand what's going on:

``` r
sum(x$a[x$a %% 2 == 0])
```

(In this case, the function sums the even elements of each vector.)

Similarly, when writing an anonymous function, it can be helpful to think about what the function looks like for a single element first. Then, just replace the name of the element with a `.` to create your anonymous function.

### Map functions with tibbles

All the examples so far have used the map function on `x`, a list of vectors, but the map functions work on any type of vector or list: atomic vectors, lists of lists, lists of lists of vectors, etc. They also work on tibbles:

``` r
x <- 
  tibble(
    a = c(1, 2, 6),
    b = c(3, 5, 3)
  )

x %>% map_dbl(median)
#> a b 
#> 2 3
```

Notice that the function `median()` is applied to each column. The assembly line objects are the *columns* of the tibble, not the rows. Tibbles are actually lists of vectors, where each column is its own vector (the creation of `x` with `tibble()` hints at this structure).

