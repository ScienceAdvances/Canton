#' Create directories
#'
#' Create one or more directories recursively. Existing directories are left
#' unchanged, making the function safe to call repeatedly.
#'
#' @param directory One or more directory paths.
#'
#' @return Invisibly, normalized directory paths.
#'
#' @export
#' @examples
#' mkdir(file.path(tempdir(), "canton-example"))
mkdir <- function(directory) {
    if (!base::is.character(directory) || base::length(directory) < 1L ||
        base::anyNA(directory) || base::any(!base::nzchar(directory))) {
        base::stop("`directory` must contain one or more non-empty paths.", call. = FALSE)
    }

    directory <- base::path.expand(directory)
    for (path in directory) {
        if (base::file.exists(path) && !base::dir.exists(path)) {
            base::stop("A file already exists at the requested path: ", path, call. = FALSE)
        }
        if (!base::dir.exists(path) &&
            !base::dir.create(path, showWarnings = FALSE, recursive = TRUE)) {
            base::stop("Unable to create directory: ", path, call. = FALSE)
        }
    }

    result <- base::normalizePath(directory, mustWork = TRUE)
    base::names(result) <- base::names(directory)
    base::invisible(result)
}
