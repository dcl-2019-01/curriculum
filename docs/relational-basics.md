---
title: Essentials of relational data
---

<!-- Generated automatically from relational-basics.yml. Do not edit by hand -->

# Essentials of relational data <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Exploratory data analysis (1D)](eda-1d.md))</small>  
<small>(Leads to: [dplyr and databases](dplyr-databases.md))</small>

It is extremely rare to only require a single table of data for an analysis.
Far more often you will need to combine together multiple sources of
information. Interconnected datasets are often called __relational__ because
you need to care about the relationships between the datasets.

Here you'll first learn about the __keys__ that define the relationship.
You'll then learn about __mutating__ joins, so called because their primary
impact is to add new columns, like a `mutate()`. It’s also useful to learn
about the __filtering__ joins, `semi_join()` and `anti_join()`, which work
primarily like a `filter()`, restricting the rows.

## Readings

  * [Introduction](http://r4ds.had.co.nz/relational-data.html#introduction-7) [r4ds-13.1]

  * [nycflights13](http://r4ds.had.co.nz/relational-data.html#nycflights13-relational) [r4ds-13.2]

  * [Keys](http://r4ds.had.co.nz/relational-data.html#keys) [r4ds-13.3]

  * [Mutating joins](http://r4ds.had.co.nz/relational-data.html#mutating-joins) [r4ds-13.4]

  * [Filtering joins](http://r4ds.had.co.nz/relational-data.html#filtering-joins) [r4ds-13.5]


