test_that("invalid requests do not create directories", {
    expect_error(imagesave(), "explicit")
    expect_error(imagesave(outdir = ""), "empty")
    output <- tempfile("canton-invalid-")
    expect_error(imagesave(mtcars, outdir = output), "Unsupported")
    expect_false(dir.exists(output))
})
test_that("drawing failures close the export device", {
    device <- grDevices::dev.cur()
    expect_error(imagesave(function() stop("drawing failed"),
                           outdir = tempdir()), "drawing failed")
    expect_identical(grDevices::dev.cur(), device)
})

test_that("grid export and overwrite protection work", {
    output <- tempfile("canton-grid-")
    path <- imagesave(grid::rectGrob(), outdir = output, width = 2, height = 2)
    before <- readBin(path, "raw", n = file.info(path)$size)
    expect_error(imagesave(grid::rectGrob(), outdir = output,
                           overwrite = FALSE), "already exists")
    expect_identical(readBin(path, "raw", n = file.info(path)$size), before)
    expect_error(fontcheck("  ", quiet = TRUE), "empty")
})
