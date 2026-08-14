
test_that("Canton can be attached without changing user state", {
    library(Canton)
    old_option <- getOption("opt_whatever", NULL)
    old_environment <- Sys.getenv("envvar_whatever", unset = NA_character_)
    on.exit({
        options(opt_whatever = old_option)
        if (is.na(old_environment)) {
            Sys.unsetenv("envvar_whatever")
        } else {
            Sys.setenv(envvar_whatever = old_environment)
        }
    }, add = TRUE)

    options(opt_whatever = "whatever")
    Sys.setenv(envvar_whatever = "whatever")

    expect_match(search(), "Canton", all = FALSE)
    expect_equal(getOption("opt_whatever"), "whatever")
    expect_equal(Sys.getenv("envvar_whatever"), "whatever")
})
