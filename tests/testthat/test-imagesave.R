test_that("imagesave saves a ggplot in multiple formats", {
    output <- file.path(tempdir(), paste0("canton-ggplot-", Sys.getpid()))
    dir.create(output, recursive = TRUE, showWarnings = FALSE)
    plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
        ggplot2::geom_point()

    paths <- imagesave(
        plot,
        name = "scatter",
        outdir = output,
        format = c("png", "pdf", "jpg", "tiff"),
        width = 2,
        height = 2,
        dpi = 72
    )

    expect_named(paths, c("png", "pdf", "jpg", "tiff"))
    expect_true(all(file.exists(paths)))
    expect_true(all(file.info(paths)$size > 0))
})

test_that("imagesave saves an actual pheatmap object", {
    skip_if_not_installed("pheatmap")
    set.seed(1)
    plot <- pheatmap::pheatmap(
        matrix(stats::rnorm(25), nrow = 5),
        silent = TRUE
    )
    output <- file.path(tempdir(), paste0("canton-real-pheatmap-", Sys.getpid()))

    paths <- imagesave(
        plot,
        name = "heatmap",
        outdir = output,
        format = c("png", "pdf"),
        width = 2,
        height = 2,
        dpi = 72
    )

    expect_true(all(file.exists(paths)))
    expect_true(all(file.info(paths)$size > 0))
})

test_that("imagesave saves ComplexHeatmap objects", {
    skip_if_not_installed("ComplexHeatmap")
    set.seed(2)
    matrix_data <- matrix(stats::rnorm(25), nrow = 5)
    heatmap <- ComplexHeatmap::Heatmap(matrix_data, name = "value")
    heatmap_list <- heatmap +
        ComplexHeatmap::Heatmap(matrix_data, name = "value_2")
    output <- file.path(tempdir(), paste0("canton-complexheatmap-", Sys.getpid()))

    heatmap_paths <- imagesave(
        heatmap,
        name = "heatmap",
        outdir = output,
        format = c("png", "pdf"),
        width = 2,
        height = 2,
        dpi = 72
    )
    list_path <- imagesave(
        heatmap_list,
        name = "heatmap-list",
        outdir = output,
        format = "png",
        width = 3,
        height = 2,
        dpi = 72
    )

    paths <- c(heatmap_paths, list_path)
    expect_true(all(file.exists(paths)))
    expect_true(all(file.info(paths)$size > 0))
})

test_that("imagesave replays a recorded base plot", {
    capture_file <- tempfile(fileext = ".pdf")
    grDevices::pdf(capture_file, width = 2, height = 2)
    grDevices::dev.control("enable")
    graphics::plot(1:5, 5:1)
    plot <- grDevices::recordPlot()
    grDevices::dev.off()

    output <- file.path(tempdir(), paste0("canton-recorded-", Sys.getpid()))
    paths <- imagesave(
        plot,
        name = "base-plot",
        outdir = output,
        format = c("png", "pdf"),
        width = 2,
        height = 2,
        dpi = 72
    )

    expect_true(all(file.exists(paths)))
    expect_true(all(file.info(paths)$size > 0))
})

test_that("imagesave accepts a zero-argument plotting function", {
    output <- file.path(tempdir(), paste0("canton-function-", Sys.getpid()))
    path <- imagesave(
        function() graphics::plot(1:5, 1:5),
        name = "function-plot",
        outdir = output,
        format = "jpeg",
        width = 2,
        height = 2,
        dpi = 72
    )

    expect_true(file.exists(path))
    expect_gt(file.info(path)$size, 0)
})

test_that("imagesave infers a format from the filename extension", {
    output <- file.path(tempdir(), paste0("canton-extension-", Sys.getpid()))
    plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
        ggplot2::geom_point()

    path <- imagesave(
        plot,
        name = "inferred.png",
        outdir = output,
        width = 2,
        height = 2,
        dpi = 72
    )

    expect_named(path, "png")
    expect_true(file.exists(path))
})

test_that("imagesave rejects unsupported objects and formats", {
    expect_error(imagesave(mtcars), "Unsupported plot object")
    expect_error(
        imagesave(function() graphics::plot(1), format = "svg"),
        "Unsupported format"
    )
})
