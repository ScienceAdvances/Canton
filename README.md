
# Canton

> Data Analysis Toolkit

<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/using)](https://cran.r-project.org/package=using)
<!-- badges: end -->

Data Analysis Toolkit

## Install Canton from github

``` r
install.packages("remotes")
remotes::install_github("ScienceAdvances/Canton")
```

## Use using to load packages
load installed packages without starting messages

``` r
library(Canton)
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
Canton::using(ggplot2)
p=ggplot(mpg, aes(cty, hwy)) +
  # to create a scatterplot
  geom_point() +
  # to fit and overlay a loess trendline
  geom_smooth(formula = y ~ x, method = "lm")
Canton::gs(p, outdir = "Result", name = "mpg_point", w = 7, h = 7)
```

## Return a palette
``` r
Canton::hue(name = "NPG")
#  [1] "#E54B34" "#4CBAD4" "#009F86" "#3B5387" "#F29A7F" "#8491B3" "#91D1C1" "#DC0000" "#7E6047" "#CCCCCC" "#BC8B83" "#33ADAD" "#347988" "#9F7685" "#C1969A" "#8BB0BB" "#CE8662" "#B04929" "#A59487" "#E3907E" "#D46F5B" "#41B4C1"
# [23] "#278C87" "#726486" "#DA988C" "#88A0B7" "#B9AC91" "#C63517" "#927A66" "#DBAEA4" "#97A4AB" "#21A69A" "#3A6688" "#C98882" "#A593A7" "#8EC0BE" "#D85935" "#985738" "#B9AFA9" "#E67059" "#E5BFB9" "#B2CED4" "#779F99" "#747A87"
# [45] "#F2DCD5" "#A7ABB3" "#C1D1CD" "#DCA5A5" "#7E7770" "#CCCCCC"
```