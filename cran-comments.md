## Resubmission: Canton 0.0.8

- Added Wickham (2016, ISBN:978-3-319-24277-4) in DESCRIPTION for ggplot2.
- imagesave() now requires an explicit non-empty outdir; mkdir() requires
  an explicit directory. Examples/tests use temporary output paths.
- setfont() validates without changing settings, or evaluates code with
  temporary font settings restored by immediately registered on.exit()
  handlers. Removed permanent hooks and platform font registration.
- resetfont() is a documented compatibility no-op.
- Updated documentation and regression tests.

## Checks (macOS arm64, R 4.6.1, 2026-09-12)

- R CMD check: Status: OK, including examples, tests and PDF manual.
- Tests: 86 passed, 0 failed, 0 warnings, 0 skipped.
- R CMD check --as-cran with _R_CHECK_CRAN_INCOMING_=false:
  0 errors, 0 warnings, 1 NOTE (local HTML Tidy is too old).
- Full online --as-cran completed: 0 errors, 0 warnings, 2 NOTEs.
  The incoming NOTE reports a new submission and two GitHub URL connection
  timeouts (libcurl code 28); the other NOTE concerns outdated local HTML Tidy.
- Windows and Linux were not tested locally.
