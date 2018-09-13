---
title: Documentation
---

<!-- Generated automatically from documentation.yml. Do not edit by hand -->

# Documentation <small class='workflow'>[workflow]</small>
<small>(Builds on: [Setup](setup.md))</small>  
<small>(Leads to: [Getting help](getting-help.md))</small>

R comes with rich built-in documentation that you can access by typing
`?` before the name of a function. The documentation isn't always
aimed at newcomers, and may use terminology that you're not familiar with.
But don't despair! Ignore what you don't understand, and persevere.
Often you'll find what you need in the examples at the bottom of the help
page.

There are three commands in R that you should be familiar with:

* `?function_name` opens the help for `function_name()`. If you know
  the name of the function, this will tell you how it works and how you
  can control its operation. (`?` also works for built-in datasets).

  If you ever wonder which package a function comes from, you can
  use `?` to figure it out - just look at the top-left of the help page;
  the package name is surrounded in `{}`.

* `browseVignettes(package = "package_name")` lists all the "vignettes"
  available for a package. Vignettes are longer documents that describe
  how multiple functions work. Many packages include an introductory vignette
  that give you the lay of the land: these are useful to read before
  you know the name of the function you need.

* `help(package = "package_name")` lists all the functions available in
  a package with links to their help pages. This mostly useful for packages
  that don't have a vignette.

Alternatively, you can use <https://www.rdocumentation.org>; this provides
exactly access to the same documentation pages and vignettes, but in
an attractive website.
