# Canton

> Consistent fonts and figure export for scientific publication workflows in R

## Overview

Canton is a small R package for preparing figures for scientific manuscripts.
It addresses two recurring problems:

1. text and font settings are inconsistent across R graphics systems; and
2. journals request figures in different combinations of physical size,
   resolution, and file format.

R does not have one universal plot object. A `ggplot2` plot, a grid grob,
`pheatmap` and `ComplexHeatmap` results, and a base R plot are represented and
rendered differently. Canton provides a single `imagesave()` interface that
detects common plot types and selects an appropriate rendering strategy. It
also provides checked font configuration, reusable export presets, a
publication-oriented ggplot2 theme, and colour scales.

The package does not submit files, contact journals, install system fonts, or
silently download external resources. Output is written only when the user
explicitly calls a saving function and selects an output directory.

## Main functionality

| Function | Purpose |
|---|---|
| `imagesave()` | Save supported R plots to one or more formats |
| `figure_preset()` | Create reusable size, resolution, and format settings |
| `setfont()` | Validate a font or apply it within a code block |
| `fontcheck()` | Test whether a font family is available |
| `fontlist()` | List or search available system font families |
| `resetfont()` | Compatibility helper; restoration is automatic |
| `theme_canton()` | Apply a compact publication-oriented ggplot2 theme |
| `scale_*_canton_d()` | Apply Canton palettes to discrete ggplot2 scales |
| `scale_*_canton_c()` | Apply Canton palettes to continuous ggplot2 scales |
| `hue()` | Return a Canton colour palette |
| `using()` | Attach multiple installed packages quietly |
| `mkdir()` | Create output directories recursively and idempotently |
| `pwd()` | Return the current working directory |

## Installation

Install the development version from GitHub:

```r
install.packages("remotes")
remotes::install_github("ScienceAdvances/Canton")
```

Load the package:

```r
library(Canton)
```

## A unified figure-saving interface

### Why type-specific rendering is necessary

`imagesave()` does not coerce every input into a ggplot object. Instead, it
dispatches internally according to the input type:

| Input | Rendering strategy |
|---|---|
| `ggplot` | Saved with `ggplot2::ggsave()` |
| `pheatmap` | Extracts and saves the returned `$gtable` |
| ComplexHeatmap `Heatmap` or `HeatmapList` | Drawn with `ComplexHeatmap::draw()` on each output device |
| `grob`, `gTree`, `gtable`, or `gList` | Saved as a grid graphical object |
| `recordedplot` | Replayed with `grDevices::replayPlot()` |
| `trellis` | Printed on a format-specific graphics device |
| zero-argument function | Executed on each requested graphics device |
| `NULL` | Captures the current plot with `grDevices::recordPlot()` |

This approach preserves the intended rendering method of each graphics system.
Unsupported objects produce an informative error rather than being passed
implicitly to `plot()`.

### Supported output formats

`imagesave()` supports:

- PDF (`"pdf"`);
- PNG (`"png"`);
- JPEG (`"jpg"` or `"jpeg"`); and
- TIFF (`"tif"` or `"tiff"`).

One call can create one file or several formats. Each format is rendered
directly from the original plot; Canton does not convert a previously created
raster image into PDF.

```r
library(ggplot2)

p <- ggplot(mtcars, aes(mpg, wt, colour = factor(cyl))) +
  geom_point(size = 2.5) +
  labs(
    x = "Fuel economy (mpg)",
    y = "Weight (1000 lbs)",
    colour = "Cylinders"
  )

paths <- imagesave(
  p,
  name = "figure_1",
  outdir = file.path(tempdir(), "canton-figures"),
  format = c("png", "pdf", "tiff"),
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)

paths
```

The return value is an invisible named character vector containing the complete
paths of the generated files. Missing output directories are created
recursively. Existing files are overwritten by default; use
`overwrite = FALSE` to prevent replacement.

### Saving ggplot2 figures

ggplot2 objects are saved through `ggplot2::ggsave()`. Device-specific settings
such as JPEG quality and TIFF compression are forwarded only to the relevant
device.

```r
imagesave(
  p,
  name = "figure_ggplot",
  outdir = file.path(tempdir(), "canton-figures"),
  format = c("pdf", "png"),
  width = 180,
  height = 120,
  units = "mm",
  dpi = 300
)
```

### Saving the current base R plot

Base R plotting functions generally draw immediately and do not return a
reusable object equivalent to a ggplot. After drawing a base plot,
`imagesave()` can capture the current device display list:

```r
grDevices::pdf(tempfile(fileext = ".pdf"))
grDevices::dev.control("enable")
plot(
  mtcars$mpg,
  mtcars$wt,
  pch = 19,
  xlab = "Fuel economy (mpg)",
  ylab = "Weight (1000 lbs)"
)
abline(lm(wt ~ mpg, data = mtcars), col = "red", lwd = 2)

imagesave(
  name = "figure_base",
  outdir = file.path(tempdir(), "canton-figures"),
  format = c("png", "pdf"),
  width = 7,
  height = 5,
  dpi = 300
)
grDevices::dev.off()
```

Current-plot capture is intended for the current R session. For scripts,
pipelines, and non-interactive rendering, a plotting function is more robust
because it can be executed separately on every output device:

```r
draw_base_figure <- function() {
  plot(mtcars$mpg, mtcars$wt, pch = 19)
  abline(lm(wt ~ mpg, data = mtcars), col = "red", lwd = 2)
}

imagesave(
  draw_base_figure,
  name = "figure_base_function",
  outdir = file.path(tempdir(), "canton-figures"),
  format = c("png", "pdf", "tiff"),
  width = 7,
  height = 5,
  dpi = 300
)
```

### Saving pheatmap figures

`pheatmap::pheatmap()` invisibly returns a list that contains a `gtable`.
Canton extracts this component and saves it as a grid object.

```r
if (requireNamespace("pheatmap", quietly = TRUE)) {
  set.seed(1)
  mat <- matrix(stats::rnorm(100), nrow = 10)

  ph <- pheatmap::pheatmap(
    mat,
    main = "Expression heatmap",
    silent = TRUE
  )

  imagesave(
    ph,
    name = "figure_heatmap",
    outdir = file.path(tempdir(), "canton-figures"),
    format = c("png", "pdf", "tiff"),
    width = 7,
    height = 7,
    dpi = 300
  )
}
```

`pheatmap` is a suggested package, not a required dependency. Canton can be
installed and used for other plot types without it.

### Saving ComplexHeatmap figures

ComplexHeatmap objects are not equivalent to `pheatmap` objects and do not
contain a `$gtable` component. A `Heatmap` or `HeatmapList` is laid out and
rendered by `ComplexHeatmap::draw()`. Canton opens each requested output device
and calls that method directly.

```r
if (requireNamespace("ComplexHeatmap", quietly = TRUE)) {
  set.seed(2)
  mat <- matrix(stats::rnorm(100), nrow = 10)

  ht <- ComplexHeatmap::Heatmap(
    mat,
    name = "z-score",
    column_title = "ComplexHeatmap example"
  )

  imagesave(
    ht,
    name = "figure_complex_heatmap",
    outdir = file.path(tempdir(), "canton-figures"),
    format = c("png", "pdf", "tiff"),
    width = 7,
    height = 7,
    dpi = 300
  )
}
```

The same interface also accepts a `HeatmapList`, including objects constructed
with the ComplexHeatmap `+` operator. `ComplexHeatmap` is a suggested
Bioconductor package; it is needed only when saving these object types.

## Figure export presets

`figure_preset()` supplies reusable starting points for common output layouts:

```r
figure_preset("publication")
figure_preset("single_column")
figure_preset("double_column")
figure_preset("high_resolution")
figure_preset("presentation")
```

For example:

```r
imagesave(
  p,
  name = "figure_single_column",
  outdir = file.path(tempdir(), "canton-figures"),
  preset = "single_column"
)
```

Preset values can be customised:

```r
custom_preset <- figure_preset(
  "publication",
  format = c("pdf", "png"),
  width = 6.5,
  height = 4.5,
  dpi = 600
)

imagesave(
  p,
  name = "figure_custom",
  outdir = file.path(tempdir(), "canton-figures"),
  preset = custom_preset
)
```

Explicit arguments supplied to `imagesave()` override the corresponding preset
values. Presets are convenience defaults, not permanent representations of any
journal's author instructions. Users should always compare the selected values
with the current requirements of the target journal.

## Font configuration

Font validation leaves session settings unchanged:

```r
family <- setfont("sans", quiet = TRUE)
p <- p + theme_canton(base_family = family)
imagesave(p, outdir = tempdir(), family = family)
```

Use a code block for temporary defaults. Settings restore automatically on
normal return and errors. Print ggplot objects inside the block.

```r
setfont("sans", code = {
  print(p)
  imagesave(p, outdir = tempdir())
})
```

For base plots, pass `family` to `imagesave()` and draw on its output device.
No permanent graphics hooks or system font registrations are installed.
`resetfont()` remains as a compatibility no-op because restoration is automatic.
Use `fontcheck()` and `fontlist()` to inspect installed fonts.

## A publication-oriented ggplot2 theme

`theme_canton()` is based on `ggplot2::theme_classic()` and provides explicit
defaults for text, axes, ticks, legends, facet strips, margins, and optional
grid lines.

```r
p_publication <- ggplot(
  mtcars,
  aes(mpg, wt, colour = factor(cyl))
) +
  geom_point(size = 2.5) +
  labs(
    x = "Fuel economy (mpg)",
    y = "Weight (1000 lbs)",
    colour = "Cylinders"
  ) +
  theme_canton(
    base_size = 10,
    grid = "none",
    legend_position = "right"
  )
```

Grid options are `"none"`, `"major"`, and `"both"`. The font defaults to the
family inside a `setfont(code = ...)` block, or to the portable `"sans"` alias.

## Colour palettes and ggplot2 scales

List available palettes:

```r
hue()
```

Palette matching is case-insensitive:

```r
colours <- hue("NPG")
dark_colours <- hue("dark2")
```

Use Canton palettes directly with discrete ggplot2 scales:

```r
p_publication + scale_colour_canton_d("NPG")

ggplot(mtcars, aes(factor(cyl), fill = factor(am))) +
  geom_bar() +
  scale_fill_canton_d("Dark2") +
  theme_canton()
```

Continuous colour and fill scales are also available:

```r
ggplot(mtcars, aes(mpg, wt, colour = qsec)) +
  geom_point(size = 2.5) +
  scale_colour_canton_c("NPG") +
  theme_canton(grid = "major")
```

Both British (`colour`) and American (`color`) spellings are exported for
colour scales.

## Choosing an output format

| Format | Typical use | Important properties |
|---|---|---|
| PDF | manuscript submission, vector artwork, typesetting | text and vector lines scale without loss; embedded raster layers retain their own resolution |
| TIFF | journal submission and print workflows | commonly requested at 300 or 600 DPI; files can be large |
| PNG | reports, slides, web pages, line and text graphics | lossless raster format; supports transparent backgrounds on suitable devices |
| JPEG | photographs and continuous-tone images | lossy compression; generally not preferred for sharp text or statistical line art |

For raster output, physical size and DPI determine pixel dimensions. A
7-inch-wide image at 300 DPI is 2100 pixels wide. DPI does not define the
resolution of vector text and lines in a PDF, although raster content embedded
inside the PDF still has a finite resolution.

Example high-resolution TIFF output:

```r
imagesave(
  p,
  name = "figure_print",
  outdir = file.path(tempdir(), "canton-figures"),
  format = "tiff",
  width = 7,
  height = 5,
  units = "in",
  dpi = 600,
  compression = "lzw"
)
```

TIFF compression capabilities differ between graphics devices. Canton avoids
passing unsupported compression arguments to the default macOS Quartz TIFF
device.

## Additional workflow helpers

### Quiet package loading

`using()` accepts bare names, strings, or character vectors. It suppresses
package startup messages, returns a named logical vector, and reports packages
that could not be loaded. It never installs missing packages.

```r
using(ggplot2, grid)

packages <- c("ggplot2", "grid")
loaded <- using(packages)
loaded
```

### Directory management

`mkdir()` creates directories recursively. Calling it again for an existing
directory is silent and safe.

```r
figure_directory <- mkdir(
  file.path(tempdir(), "canton-project", "figures")
)
figure_directory
```

`pwd()` returns the current working directory:

```r
pwd()
```

## Error handling and side effects

Canton follows these principles:

- unsupported plot classes, formats, dimensions, fonts, and paths fail with
  informative errors;
- graphics devices are closed even when drawing fails;
- no package is automatically installed by `using()`;
- no font is downloaded or installed by `setfont()`;
- no files are written during package loading;
- output directories are created only after an explicit saving or directory
  request; and
- temporary font settings in `setfont(code = ...)` restore automatically on exit.

## Testing and package scope

The test suite covers:

- single- and multi-format ggplot2 output;
- current and recorded base graphics;
- function-based rendering;
- actual `pheatmap` output when the suggested package is available;
- actual ComplexHeatmap `Heatmap` and `HeatmapList` output when the suggested
  package is available;
- figure presets and explicit argument overrides;
- font configuration and restoration;
- discrete and continuous ggplot2 scales;
- palette validation;
- package loading behaviour; and
- recursive directory creation.

The package is intentionally focused on figure creation and small supporting
workflow helpers. It does not attempt to analyse scientific data, enforce a
particular journal's changing submission policy, inspect manuscript content,
or guarantee font embedding by third-party PDF software.

## License

GPL (>= 3)
