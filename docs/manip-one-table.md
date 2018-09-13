---
title: Other single table verbs
---

<!-- Generated automatically from manip-one-table.yml. Do not edit by hand -->

# Other single table verbs <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>


You’ve learned the most important verbs for data analysis: `filter()`,
`mutate()`, `group_by()` and `summarise()`. There are a number of other
verbs that are not quite as important but still come in handy from
time-to-time. The goal of this document is to familiarise you with their
purpose and basic operation

``` r
library(tidyverse)
library(nycflights13)
```

## Select

Most of the datasets you’ll work with in this class only have a
relatively small number of variables, and generally you don’t need to
reduce further. In real life, you’ll sometimes encounter datasets with
hundreds or even thousands of variables, and the first challenge is just
to narrow down to a useful subset. Solving that problem is the job of
`select()`.

`select()` allows you to work with column names using a handful of
helper functions:

  - `starts_with("x")` and `ends_with("x")` select variables that start
    with a common prefix or end with a common suffix.

  - `contains("x")` selects variables that contain a phrase.
    `matches("x.y")` select all variables that match a given regular
    expression (which you’ll learn about later in the course).

  - `a:e` selects all variables from variable `a` to variable `e`
    inclsive.

You can also select a single varible just by using its name directly.

``` r
flights %>% select(year:day, ends_with("delay"))
#> # A tibble: 336,776 x 5
#>     year month   day dep_delay arr_delay
#>    <int> <int> <int>     <dbl>     <dbl>
#>  1  2013     1     1      2.00     11.0 
#>  2  2013     1     1      4.00     20.0 
#>  3  2013     1     1      2.00     33.0 
#>  4  2013     1     1     -1.00    -18.0 
#>  5  2013     1     1     -6.00    -25.0 
#>  6  2013     1     1     -4.00     12.0 
#>  7  2013     1     1     -5.00     19.0 
#>  8  2013     1     1     -3.00    -14.0 
#>  9  2013     1     1     -3.00    - 8.00
#> 10  2013     1     1     -2.00      8.00
#> # ... with 336,766 more rows
```

To remove variables from selection, put a `-` in front of the
expression.

``` r
flights %>% select(-starts_with("dep"))
#> # A tibble: 336,776 x 17
#>     year month   day sched_… arr_t… sched_… arr_d… carr… flig… tail… orig…
#>    <int> <int> <int>   <int>  <int>   <int>  <dbl> <chr> <int> <chr> <chr>
#>  1  2013     1     1     515    830     819  11.0  UA     1545 N142… EWR  
#>  2  2013     1     1     529    850     830  20.0  UA     1714 N242… LGA  
#>  3  2013     1     1     540    923     850  33.0  AA     1141 N619… JFK  
#>  4  2013     1     1     545   1004    1022 -18.0  B6      725 N804… JFK  
#>  5  2013     1     1     600    812     837 -25.0  DL      461 N668… LGA  
#>  6  2013     1     1     558    740     728  12.0  UA     1696 N394… EWR  
#>  7  2013     1     1     600    913     854  19.0  B6      507 N516… EWR  
#>  8  2013     1     1     600    709     723 -14.0  EV     5708 N829… LGA  
#>  9  2013     1     1     600    838     846 - 8.00 B6       79 N593… JFK  
#> 10  2013     1     1     600    753     745   8.00 AA      301 N3AL… LGA  
#> # ... with 336,766 more rows, and 6 more variables: dest <chr>, air_time
#> #   <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

There’s one last helper that’s useful if you just want to move a few
variables to the start: `everything()`.

``` r
flights %>% select(dep_delay, arr_delay, everything())
#> # A tibble: 336,776 x 19
#>    dep_d… arr_de…  year month   day dep_t… sched… arr_… sched… carr… flig…
#>     <dbl>   <dbl> <int> <int> <int>  <int>  <int> <int>  <int> <chr> <int>
#>  1   2.00   11.0   2013     1     1    517    515   830    819 UA     1545
#>  2   4.00   20.0   2013     1     1    533    529   850    830 UA     1714
#>  3   2.00   33.0   2013     1     1    542    540   923    850 AA     1141
#>  4  -1.00  -18.0   2013     1     1    544    545  1004   1022 B6      725
#>  5  -6.00  -25.0   2013     1     1    554    600   812    837 DL      461
#>  6  -4.00   12.0   2013     1     1    554    558   740    728 UA     1696
#>  7  -5.00   19.0   2013     1     1    555    600   913    854 B6      507
#>  8  -3.00  -14.0   2013     1     1    557    600   709    723 EV     5708
#>  9  -3.00  - 8.00  2013     1     1    557    600   838    846 B6       79
#> 10  -2.00    8.00  2013     1     1    558    600   753    745 AA      301
#> # ... with 336,766 more rows, and 8 more variables: tailnum <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>
```

## Rename

To change the name of a variable use `df %>% rename(new_name =
old_name)`. If you have trouble remembering which sides old and new go
on, remember it’s the same order as `mutate()`.

``` r
flights %>% rename(tail_num = tailnum)
#> # A tibble: 336,776 x 19
#>     year month   day dep_t… sched_… dep_d… arr_… sched… arr_d… carr… flig…
#>    <int> <int> <int>  <int>   <int>  <dbl> <int>  <int>  <dbl> <chr> <int>
#>  1  2013     1     1    517     515   2.00   830    819  11.0  UA     1545
#>  2  2013     1     1    533     529   4.00   850    830  20.0  UA     1714
#>  3  2013     1     1    542     540   2.00   923    850  33.0  AA     1141
#>  4  2013     1     1    544     545  -1.00  1004   1022 -18.0  B6      725
#>  5  2013     1     1    554     600  -6.00   812    837 -25.0  DL      461
#>  6  2013     1     1    554     558  -4.00   740    728  12.0  UA     1696
#>  7  2013     1     1    555     600  -5.00   913    854  19.0  B6      507
#>  8  2013     1     1    557     600  -3.00   709    723 -14.0  EV     5708
#>  9  2013     1     1    557     600  -3.00   838    846 - 8.00 B6       79
#> 10  2013     1     1    558     600  -2.00   753    745   8.00 AA      301
#> # ... with 336,766 more rows, and 8 more variables: tail_num <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>
```

If you’re selecting and renaming, note that you can also use `select()`
to rename. This sometimes allows you to save a step.

``` r
flights %>% select(year:day, tail_num = tailnum)
#> # A tibble: 336,776 x 4
#>     year month   day tail_num
#>    <int> <int> <int> <chr>   
#>  1  2013     1     1 N14228  
#>  2  2013     1     1 N24211  
#>  3  2013     1     1 N619AA  
#>  4  2013     1     1 N804JB  
#>  5  2013     1     1 N668DN  
#>  6  2013     1     1 N39463  
#>  7  2013     1     1 N516JB  
#>  8  2013     1     1 N829AS  
#>  9  2013     1     1 N593JB  
#> 10  2013     1     1 N3ALAA  
#> # ... with 336,766 more rows
```

## Transmute

Transmute is a minor variation of `mutate()`. The main difference is
that it drops any variables that you didn’t explicitly mention. It’s a
useful shortcut for `mutate()` + `select()`.

``` r
df <- tibble(x = 1:3, y = 3:1)

# mutate() keeps all the variables
df %>% mutate(z = x + y)
#> # A tibble: 3 x 3
#>       x     y     z
#>   <int> <int> <int>
#> 1     1     3     4
#> 2     2     2     4
#> 3     3     1     4

# transmute() drops all the variables
df %>% transmute(z = x + y)
#> # A tibble: 3 x 1
#>       z
#>   <int>
#> 1     4
#> 2     4
#> 3     4
```

## Arrange

`arrange()` lets you change the order of the rows. To put a column in
descending order, use `desc()`.

``` r
flights %>% arrange(desc(dep_delay))
#> # A tibble: 336,776 x 19
#>     year month   day dep_… sche… dep_… arr_… sche… arr_… carr… flig… tail…
#>    <int> <int> <int> <int> <int> <dbl> <int> <int> <dbl> <chr> <int> <chr>
#>  1  2013     1     9   641   900  1301  1242  1530  1272 HA       51 N384…
#>  2  2013     6    15  1432  1935  1137  1607  2120  1127 MQ     3535 N504…
#>  3  2013     1    10  1121  1635  1126  1239  1810  1109 MQ     3695 N517…
#>  4  2013     9    20  1139  1845  1014  1457  2210  1007 AA      177 N338…
#>  5  2013     7    22   845  1600  1005  1044  1815   989 MQ     3075 N665…
#>  6  2013     4    10  1100  1900   960  1342  2211   931 DL     2391 N959…
#>  7  2013     3    17  2321   810   911   135  1020   915 DL     2119 N927…
#>  8  2013     6    27   959  1900   899  1236  2226   850 DL     2007 N376…
#>  9  2013     7    22  2257   759   898   121  1026   895 DL     2047 N671…
#> 10  2013    12     5   756  1700   896  1058  2020   878 AA      172 N5DM…
#> # ... with 336,766 more rows, and 7 more variables: origin <chr>, dest
#> #   <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>
flights %>% arrange(year, month, day)
#> # A tibble: 336,776 x 19
#>     year month   day dep_t… sched_… dep_d… arr_… sched… arr_d… carr… flig…
#>    <int> <int> <int>  <int>   <int>  <dbl> <int>  <int>  <dbl> <chr> <int>
#>  1  2013     1     1    517     515   2.00   830    819  11.0  UA     1545
#>  2  2013     1     1    533     529   4.00   850    830  20.0  UA     1714
#>  3  2013     1     1    542     540   2.00   923    850  33.0  AA     1141
#>  4  2013     1     1    544     545  -1.00  1004   1022 -18.0  B6      725
#>  5  2013     1     1    554     600  -6.00   812    837 -25.0  DL      461
#>  6  2013     1     1    554     558  -4.00   740    728  12.0  UA     1696
#>  7  2013     1     1    555     600  -5.00   913    854  19.0  B6      507
#>  8  2013     1     1    557     600  -3.00   709    723 -14.0  EV     5708
#>  9  2013     1     1    557     600  -3.00   838    846 - 8.00 B6       79
#> 10  2013     1     1    558     600  -2.00   753    745   8.00 AA      301
#> # ... with 336,766 more rows, and 8 more variables: tailnum <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>
```

## Distinct

`distinct()` removes duplicates from a dataset. The result is ordered by
first occurence in original dataset.

``` r
flights %>% distinct(carrier, flight)
#> # A tibble: 5,725 x 2
#>    carrier flight
#>    <chr>    <int>
#>  1 UA        1545
#>  2 UA        1714
#>  3 AA        1141
#>  4 B6         725
#>  5 DL         461
#>  6 UA        1696
#>  7 B6         507
#>  8 EV        5708
#>  9 B6          79
#> 10 AA         301
#> # ... with 5,715 more rows
```

## Sample

When working with very large datasets, sometimes it’s convenient to
reduce to a smaller dataset, just by taking a random sample. That’s the
job of `sample_n()` and `sample_frac()`. `sample_n()` selects the same
number of observations from each group, `sample_frac()` selects the same
proportion.

``` r
popular_dest <- flights %>%
  group_by(dest) %>%
  filter(n() > 1000)

# Creates a dataset with the same number of flights to each dest
popular_dest %>% sample_n(100)
#> # A tibble: 5,800 x 19
#> # Groups: dest [58]
#>     year month   day dep_t… sched_… dep_d… arr_… sched… arr_d… carr… flig…
#>    <int> <int> <int>  <int>   <int>  <dbl> <int>  <int>  <dbl> <chr> <int>
#>  1  2013     6    18   1934    1805  89.0   2150   2040  70.0  DL       73
#>  2  2013    12    15    828     830 - 2.00  1059   1105 - 6.00 DL      433
#>  3  2013     7    18    745     745   0      953    959 - 6.00 DL      807
#>  4  2013     5     2   1810    1815 - 5.00  2028   2043 -15.0  DL      926
#>  5  2013     9    24   1842    1840   2.00  2110   2116 - 6.00 DL       87
#>  6  2013    10     5    554     600 - 6.00   845    828  17.0  DL      563
#>  7  2013    12    19    840     840   0     1102   1115 -13.0  MQ     3419
#>  8  2013     8    21   1553    1559 - 6.00  1821   1843 -22.0  DL      847
#>  9  2013     1    29   1143    1145 - 2.00  1402   1410 - 8.00 DL      401
#> 10  2013     4     5   2010    2020 -10.0   2236   2245 - 9.00 MQ     4662
#> # ... with 5,790 more rows, and 8 more variables: tailnum <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>

# Creates a dataset with proportion number of flights to each dest
popular_dest %>% sample_frac(0.01)
#> # A tibble: 3,205 x 19
#> # Groups: dest [58]
#>     year month   day dep_t… sched_… dep_d… arr_… sched… arr_d… carr… flig…
#>    <int> <int> <int>  <int>   <int>  <dbl> <int>  <int>  <dbl> <chr> <int>
#>  1  2013     4    28   1056    1100 - 4.00  1330   1330   0    DL     1647
#>  2  2013     5    22    827     830 - 3.00  1044   1049 - 5.00 DL       27
#>  3  2013    11    14   1918    1900  18.0   2143   2136   7.00 DL      947
#>  4  2013     3    27   1143    1145 - 2.00  1347   1402 -15.0  DL      401
#>  5  2013    11     6   1214    1215 - 1.00  1449   1440   9.00 MQ     3670
#>  6  2013    11    30   1528    1530 - 2.00  1749   1753 - 4.00 DL     1942
#>  7  2013     9    16   1557    1600 - 3.00  1839   1835   4.00 DL      221
#>  8  2013     8     5   1420    1429 - 9.00  1707   1659   8.00 MQ     3669
#>  9  2013     6    22   1035     942  53.0   1247   1212  35.0  EV     4140
#> 10  2013     5    28   1952    1929  23.0   2225   2155  30.0  EV     5181
#> # ... with 3,195 more rows, and 8 more variables: tailnum <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>
```

## Slice rows

`slice()` allows to pick rows by position, by group. `head()` and
`tail()` just show the first (or last) few rows of the entire data
frame.

``` r
# first flights to each dest
flights %>% group_by(dest) %>% slice(1:5)
#> # A tibble: 517 x 19
#> # Groups: dest [105]
#>     year month   day dep_t… sched_… dep_d… arr_… sched… arr_d… carr… flig…
#>    <int> <int> <int>  <int>   <int>  <dbl> <int>  <int>  <dbl> <chr> <int>
#>  1  2013    10     1   1955    2001 - 6.00  2213   2248 -35.0  B6       65
#>  2  2013    10     2   2010    2001   9.00  2230   2248 -18.0  B6       65
#>  3  2013    10     3   1955    2001 - 6.00  2232   2248 -16.0  B6       65
#>  4  2013    10     4   2017    2001  16.0   2304   2248  16.0  B6       65
#>  5  2013    10     5   1959    1959   0     2226   2246 -20.0  B6       65
#>  6  2013    10     1   1149    1159 -10.0   1245   1259 -14.0  B6     1191
#>  7  2013    10     2   1152    1159 - 7.00  1259   1259   0    B6     1191
#>  8  2013    10     3   1211    1159  12.0   1316   1259  17.0  B6     1191
#>  9  2013    10     4    757     800 - 3.00   859    904 - 5.00 B6     1491
#> 10  2013    10     4   1154    1159 - 5.00  1258   1259 - 1.00 B6     1191
#> # ... with 507 more rows, and 8 more variables: tailnum <chr>, origin
#> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
#> #   <dbl>, time_hour <dttm>

# first flights overall
flights %>% head()
#> # A tibble: 6 x 19
#>    year month   day dep_t… sche… dep_… arr_… sche… arr_… carr… flig… tail…
#>   <int> <int> <int>  <int> <int> <dbl> <int> <int> <dbl> <chr> <int> <chr>
#> 1  2013     1     1    517   515  2.00   830   819  11.0 UA     1545 N142…
#> 2  2013     1     1    533   529  4.00   850   830  20.0 UA     1714 N242…
#> 3  2013     1     1    542   540  2.00   923   850  33.0 AA     1141 N619…
#> 4  2013     1     1    544   545 -1.00  1004  1022 -18.0 B6      725 N804…
#> 5  2013     1     1    554   600 -6.00   812   837 -25.0 DL      461 N668…
#> 6  2013     1     1    554   558 -4.00   740   728  12.0 UA     1696 N394…
#> # ... with 7 more variables: origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>

# last flights overall
flights %>% tail()
#> # A tibble: 6 x 19
#>    year month   day dep_t… sche… dep_… arr_… sche… arr_… carr… flig… tail…
#>   <int> <int> <int>  <int> <int> <dbl> <int> <int> <dbl> <chr> <int> <chr>
#> 1  2013     9    30     NA  1842    NA    NA  2019    NA EV     5274 N740…
#> 2  2013     9    30     NA  1455    NA    NA  1634    NA 9E     3393 <NA> 
#> 3  2013     9    30     NA  2200    NA    NA  2312    NA 9E     3525 <NA> 
#> 4  2013     9    30     NA  1210    NA    NA  1330    NA MQ     3461 N535…
#> 5  2013     9    30     NA  1159    NA    NA  1344    NA MQ     3572 N511…
#> 6  2013     9    30     NA   840    NA    NA  1020    NA MQ     3531 N839…
#> # ... with 7 more variables: origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

