#' Load Multiple Packages Without Starting Messages at Once
#'
#' Load Multiple Packages Without Starting Messages at Once
#'
#' @param ... multiple package names without double quotation marks and seperated by comma
#'
#' @return nothing
#'
#' @export
#' @examples
#' using(ggplot, magrittr)
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
