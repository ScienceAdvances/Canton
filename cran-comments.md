## Test environments

* local macOS 26.6.1, R 4.6.1 (R-devel), aarch64

## R CMD check results

Standard check, including tests, examples, and PDF manual:

0 errors | 0 warnings | 0 notes

`R CMD check --as-cran` produced one environment-only note because Pandoc is
not installed locally, so `README.md` and `NEWS.md` could not be converted by
the checker. No package code, documentation, example, or test notes remain.

## Submission

* This is a new release.
