test_that("hue lists and returns palettes", {
    expect_message(palettes <- hue(), "Available palettes")
    expect_true(all(c("NPG", "Dark2", "GK") %in% palettes))
    expect_identical(hue("dark2"), hue("Dark2"))
    expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", hue("NPG"))))
    expect_error(hue("not-a-palette"), "Unknown palette")
})

test_that("using supports empty, bare, string, and vector input", {
    empty <- using()
    expect_identical(empty, structure(logical(), names = character()))

    bare <- using(grid)
    expect_named(bare, "grid")
    expect_true(unname(bare))

    packages <- c("grid", "tools")
    vector <- using(packages)
    expect_named(vector, packages)
    expect_true(all(vector))

    expect_error(using(1), "names or character vectors")
})

test_that("using reports packages that cannot be loaded", {
    package <- paste0("CantonMissingPackage", Sys.getpid())
    expect_warning(result <- using(package), "Failed to load")
    expect_false(unname(result))
    expect_named(result, package)
})

test_that("mkdir is recursive and idempotent", {
    root <- file.path(tempdir(), paste0("canton-mkdir-", Sys.getpid()))
    nested <- file.path(root, "one", "two")

    path <- mkdir(nested)
    expect_true(dir.exists(path))
    expect_silent(second <- mkdir(nested))
    expect_identical(second, path)

    file_path <- tempfile("canton-file-")
    writeLines("file", file_path)
    expect_error(mkdir(file_path), "file already exists")
})

test_that("pwd returns the current working directory", {
    expect_identical(pwd(), getwd())
    expect_length(pwd(), 1L)
})
