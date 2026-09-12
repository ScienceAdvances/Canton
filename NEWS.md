# Canton 0.0.8

- Require an explicit, non-empty output directory in imagesave().
- Validate unsupported plot objects before creating directories.
- Make setfont() validation side-effect-free; code blocks apply temporary
  settings restored on exit, including errors and nested calls.
- Remove persistent font hooks and platform font registration.
- Retain resetfont() as a documented compatibility no-op.
- Add a verified reference for the ggplot2 graphics framework.
- Add regression tests for state restoration and export failure handling.

# Canton 0.0.7

## New features

- Added `imagesave()` for saving ggplot2, pheatmap/grid, ComplexHeatmap,
  recorded base R, lattice, and function-generated plots in one or more formats.
- Added `setfont()` for checked, cross-platform plotting font configuration.
- Added reusable `figure_preset()` settings for publication, single-column,
  double-column, high-resolution, and presentation output.
- Added `theme_canton()` and discrete/continuous ggplot2 colour and fill scales.
- Added `fontlist()`, `fontcheck()`, and `resetfont()` for safer font workflows.

## Improvements and fixes

- Fixed `hue()` for unknown palettes and added case-insensitive matching.
- Fixed `using()` with no arguments and added support for strings and character
  vectors.
- Made `mkdir()` idempotent and added explicit validation and useful returns.
- Updated package metadata, documentation, examples, and tests.
