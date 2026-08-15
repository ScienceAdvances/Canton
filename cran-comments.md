## Test environments

* local macOS 26.6.1, R 4.6.1 (R-devel), aarch64

## R CMD check results

Standard check, including tests, examples, and PDF manual:

0 errors | 0 warnings | 0 notes

`R CMD check --as-cran` produced two environment-only notes:

* Pandoc is not installed locally, so `README.md` and `NEWS.md` could not be
  checked by Pandoc.
* The HTML Tidy executable available locally is not recent enough for HTML
  validation.

These notes concern local checking tools. Package installation, code,
documentation, examples, tests, and the PDF manual completed successfully.

## Submission

* This is a new release.
