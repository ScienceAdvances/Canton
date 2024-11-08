
# using

> Data Analysis Toolkit

<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/using)](https://cran.r-project.org/package=using)
<!-- badges: end -->

Data Analysis Toolkit

## Install using from CRAN or github

``` r
install.packages("using")
remotes::install_github("ScienceAdvances/using")
```

## Use using to load packages
load installed packages without starting messages
``` r
library(using)
using(tidyverse, data.table, Seurat)
```
Load installed and uninstalled packages.   
DummyA and DummyB did not exist, so we did not install them.   
When loading packages by `using` , a warning message in cyan color will show as below.
``` r
using(tidyverse, data.table, Seurat, DummyA, DummyB)
```
![](image.png)

## Save ggplot2 object plot
``` r
using::using(ggplot2)
p=ggplot(mpg, aes(cty, hwy)) +
  # to create a scatterplot
  geom_point() +
  # to fit and overlay a loess trendline
  geom_smooth(formula = y ~ x, method = "lm")
using::gs(p outdir = "Result", name = "mpg_point", w = 7, h = 7)
```
