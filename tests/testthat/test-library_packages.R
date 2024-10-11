
test_that("library packages", {
    library(using)
    options(opt_whatever = "whatever")
    Sys.setenv(envvar_whatever = "whatever")

    expect_match(search(), "using", all = FALSE)
    expect_equal(getOption("opt_whatever"), "whatever")
    expect_equal(Sys.getenv("envvar_whatever"), "whatever")
})
