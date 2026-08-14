test_that("figure_preset returns validated built-in settings", {
    single <- figure_preset("single_column")
    expect_s3_class(single, "canton_figure_preset")
    expect_identical(single$width, 3.5)
    expect_identical(single$dpi, 300)
    expect_identical(single$format, c("pdf", "tiff"))

    custom <- figure_preset(
        "publication", format = "png", width = 6, dpi = 600
    )
    expect_identical(custom$format, "png")
    expect_identical(custom$width, 6)
    expect_identical(custom$dpi, 600)

    expect_error(figure_preset("publication", dpi = -1), "Invalid value")
    expect_error(
        figure_preset("publication", format = "unsupported"),
        "unsupported"
    )
})

test_that("imagesave applies a preset and explicit overrides", {
    output <- file.path(tempdir(), paste0("canton-preset-", Sys.getpid()))
    plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
        ggplot2::geom_point()
    preset <- figure_preset(
        "publication",
        format = c("png", "pdf"),
        width = 2,
        height = 2,
        dpi = 72
    )

    paths <- imagesave(plot, "preset", output, preset = preset)
    expect_named(paths, c("png", "pdf"))
    expect_true(all(file.exists(paths)))

    override <- imagesave(
        plot, "override", output,
        format = "png", preset = "single_column",
        width = 2, height = 2, dpi = 72
    )
    expect_named(override, "png")
    expect_true(file.exists(override))
})

test_that("theme_canton and Canton scales build ggplots", {
    discrete <- ggplot2::ggplot(
        mtcars,
        ggplot2::aes(mpg, wt, colour = factor(cyl))
    ) +
        ggplot2::geom_point() +
        theme_canton(grid = "major") +
        scale_colour_canton_d("Dark2")
    expect_s3_class(theme_canton(), "theme")
    expect_no_error(ggplot2::ggplot_build(discrete))

    continuous <- ggplot2::ggplot(
        mtcars,
        ggplot2::aes(mpg, wt, colour = qsec)
    ) +
        ggplot2::geom_point() +
        scale_color_canton_c("NPG")
    expect_no_error(ggplot2::ggplot_build(continuous))

    fill <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), fill = factor(am))) +
        ggplot2::geom_bar() +
        scale_fill_canton_d("Dark2")
    expect_no_error(ggplot2::ggplot_build(fill))
})

test_that("font utilities list and check families", {
    fonts <- fontlist()
    expect_type(fonts, "character")
    expect_true(length(fonts) > 0L)
    expect_true(fontcheck("sans", quiet = TRUE))

    missing <- paste0("CantonMissingFont", Sys.getpid())
    expect_false(fontcheck(missing, quiet = TRUE))
    expect_error(fontcheck(missing, error = TRUE, quiet = TRUE), "not installed")
})
