test_that("font settings are scoped and restored after errors", {
    opts <- options()
    theme <- ggplot2::theme_get()
    hook <- getHook("before.plot.new")
    expect_identical(setfont("sans", quiet = TRUE), "sans")
    expect_identical(options(), opts)
    grDevices::pdf(tempfile(fileext = ".pdf"))
    on.exit(grDevices::dev.off(), add = TRUE)
    family <- graphics::par("family")
    expect_identical(setfont("sans", quiet = TRUE, code = {
        expect_identical(graphics::par("family"), "sans")
        setfont("mono", quiet = TRUE, code = {
            expect_identical(getOption("Canton.font_family"), "mono")
        })
        expect_identical(getOption("Canton.font_family"), "sans")
        42
    }), 42)
    expect_error(setfont("mono", quiet = TRUE, code = stop("failure")), "failure")
    expect_identical(graphics::par("family"), family)
    expect_identical(options(), opts)
    expect_identical(ggplot2::theme_get(), theme)
    expect_identical(getHook("before.plot.new"), hook)
    expect_false(resetfont(quiet = TRUE))
})
test_that("invalid fonts fail clearly", {
    expect_error(setfont(""), "empty")
    expect_error(setfont(list("sans")), "single character")
    expect_error(setfont("CantonMissingFont"), "not installed")
    expect_warning(expect_identical(setfont("CantonMissingFont",
        fallback = "sans", quiet = TRUE), "sans"), "using")
})
