---
title: Vector functions
---

<!-- Generated automatically from vector-functions.yml. Do not edit by hand -->

# Vector functions <small class='program'>[program]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>


Vector functions
----------------

It's often easy to create a **scalar function**, that is a function, that takes a length-one input and produces a length-one output. You can always apply a scalar function to a vector of values by using the appropriate purrr `map_` function, but you can often find a more efficient approach by relying on an existing vectorized function. It's also easy to accidentally use a vectorized function as if it's a scalar function; doing so makes life harder for yourself than it needs to be. This reading illustrates each problem with an example.

Letter grades
-------------

A common way to create a scalar function is by using a if-else statement. For example, you might write the following function that converts a numeric grade to a letter grade:

``` r
grade_1 <- function(x) {
  if (x >= 90) {
    "A"
  } else if (x >= 80) {
    "B"
  } else if (x >= 70) {
    "C"
  } else if (x >= 60) {
    "D"
  } else {
    "F"
  }
}
```

This works well when applied to single values:

``` r
grade_1(92)
#> [1] "A"
grade_1(76)
#> [1] "C"
grade_1(60)
#> [1] "D"
```

But it fails if you attempt to apply it to an entire column of a data frame:

``` r
set.seed(523)
df <- tibble(
  score = sample(100, 10, replace = TRUE)
)

df %>%
  mutate(grade = grade_1(score))
#> Warning in if (x >= 90) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 80) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 70) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 60) {: the condition has length > 1 and only the first
#> element will be used
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
#> 1    17 F    
#> 2    97 F    
#> 3    76 F    
#> 4    87 F    
#> 5    51 F    
#> # ... with 5 more rows
```

`if` can only work with a single element at a time, so if `grade_1()` is given a vector it will only use the first element. You can always work around this problem by using one of the `map_` functions from purrr. In this case, `grade_1()` returns a character vector so we'd use `map_chr()`:

``` r
df %>%
  mutate(grade = map_chr(score, grade_1))
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
#> 1    17 F    
#> 2    97 A    
#> 3    76 C    
#> 4    87 B    
#> 5    51 F    
#> # ... with 5 more rows
```

However, there is often an alternative, more elegant, approach by relying on an existing vector function. For example, you can always rewrite a set of nested if-else statements to use `case_when()`:

``` r
grade_2 <- function(x) {
  case_when(
    x >= 90 ~ "A",
    x >= 80 ~ "B",
    x >= 70 ~ "C",
    x >= 60 ~ "D",
    TRUE    ~ "F"
  )
}

grade_2(seq(0, 100, by = 10))
#>  [1] "F" "F" "F" "F" "F" "F" "D" "C" "B" "A" "A"

df %>%
  mutate(grade = grade_2(score))
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
#> 1    17 F    
#> 2    97 A    
#> 3    76 C    
#> 4    87 B    
#> 5    51 F    
#> # ... with 5 more rows
```

And for this particular case, there's an even more targeted function from base R: `cut()`. Its job is to divide a numeric range into named intervals. You give it a vector of breaks and a vector of labels, and it produces a factor for you. You use the `right` argument to tell it whether to include numbers on the right or left end of the range:

``` r
grade_3 <- function(x) {
  cut(x, 
    breaks = c(-Inf, 60, 70, 80, 90, Inf), 
    labels = c("F", "D", "C", "B", "A"),
    right = FALSE
  )
}

grade_3(seq(0, 100, by = 10))
#>  [1] F F F F F F D C B A A
#> Levels: F D C B A
```

(Note that you supply it one less `label` than `breaks`; if this is confusing, try drawing a picture.)

In general, there's no easy way to find out that there's an existing function that will make your life much easier. The best technique is to continually expand your knowledge of R by reading widely; a good place to start are the weekly highlights on <http://rweekly.org/>.

Matching many patterns
----------------------

A similar problem is accidentally using a vectorized function as if it's a scalar function, making life harder for yourself. I'll illustrate the problem with a function that you'll already familiar with `stringr::str_detect()`. So far when you've used stringr, we've always used a single `pattern`. But imagine you have a new challenge: you have a single string and you want see which of a possible set of patterns it matches:

``` r
private <- tribble(
  ~ name,  ~ pattern,
  "ssn",   "\\d{3}-\\d{2}-\\d{4}",
  "email", "[a-z]+@[a-z]+\\.[a-z]{2,4}",
  "phone", "\\d{3}[- ]?\\d{3}[- ]?\\d{4}"
)

string <- "My social security number is 231-57-7340 and my phone number is 712-458-2189"
```

You might be tempted to use `map_lgl()`:

``` r
match <- map_lgl(private$pattern, ~ str_detect(string, pattern = .))
private$name[match]
#> [1] "ssn"   "phone"
```

But if you carefully read the documentation for `str_detect()` you'll discover that this is unnecessary because `str_detect()` is vectored oven `pattern`. That means you don't need `map_lgl()`!

``` r
private$name[str_detect(string, private$pattern)]
#> [1] "ssn"   "phone"
```

It's sometimes hard to tell from the documentation whether or not an argument is vectored. If reading the docs doesn't help, just try it with a vector; if it works, you'll have learned something new and saved yourself a little typing.

