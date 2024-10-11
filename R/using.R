#' Library multiple packages
#'
#' Library multiple packages without starting messages.
#'
#' @param ... package names
#'
#' @return nothing.
#'
#' @export
#' @examples
#' using(Seurat,tidyverse,magrittr,data.table)

using <- function(...) {
    packages <- as.character(match.call(expand.dots = FALSE)[[2]])

    if (length(packages) == 0) {
        return(invisible())
    }
    loaded <- sapply(packages, function(x) {
        # Try to load package
        if (suppressPackageStartupMessages(require(x, character.only = TRUE, quietly = TRUE))) {
            return(TRUE)
        }
        # Couldn't load
        return(FALSE)
    })

    # Give a warning if some packags couldn't be loaded
    if (!all(loaded)) {
        failed <- packages[!loaded]
        base::warning(crayon::cyan("\nFailed to load: ", base::paste(failed, collapse = ", ")))
    }
    return(invisible(loaded))
}
