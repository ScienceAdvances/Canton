test_that("setfont configures ggplot2 and imagesave defaults", {
    old_theme <- ggplot2::theme_get()
    old_family <- getOption("Canton.font_family", NULL)
    old_state <- getOption("Canton.previous_font_state", NULL)
    on.exit({
        ggplot2::theme_set(old_theme)
        options(Canton.font_family = old_family)
        options(Canton.previous_font_state = old_state)
    }, add = TRUE)

    result <- setfont("sans", quiet = TRUE)

    expect_identical(result, "sans")
    expect_identical(getOption("Canton.font_family"), "sans")
    expect_identical(ggplot2::theme_get()$text$family, "sans")
})

test_that("resetfont restores the original theme and family", {
    old_theme <- ggplot2::theme_get()
    old_family <- getOption("Canton.font_family", NULL)
    old_state <- getOption("Canton.previous_font_state", NULL)
    on.exit({
        ggplot2::theme_set(old_theme)
        options(Canton.font_family = old_family)
        options(Canton.previous_font_state = old_state)
    }, add = TRUE)

    options(Canton.previous_font_state = NULL)
    setfont("sans", quiet = TRUE)
    expect_true(resetfont(quiet = TRUE))
    expect_identical(ggplot2::theme_get(), old_theme)
    expect_identical(getOption("Canton.font_family", NULL), old_family)
    expect_false(resetfont(quiet = TRUE))
})

test_that("setfont applies the family to future base plots", {
    old_family <- getOption("Canton.font_family", NULL)
    on.exit(options(Canton.font_family = old_family), add = TRUE)

    setfont("sans", quiet = TRUE)
    device_file <- tempfile(fileext = ".png")
    grDevices::png(device_file)
    on.exit(grDevices::dev.off(), add = TRUE)
    graphics::plot(1:3)

    expect_identical(graphics::par("family"), "sans")
})

test_that("setfont explains how to install a missing font", {
    missing_family <- paste0("CantonMissingFont", Sys.getpid())
    expect_error(
        setfont(missing_family, quiet = TRUE),
        "is not installed"
    )
    expect_warning(
        expect_identical(
            setfont(missing_family, fallback = "sans", quiet = TRUE),
            "sans"
        ),
        "using `sans`"
    )
})
