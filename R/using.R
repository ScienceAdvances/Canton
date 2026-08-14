#' Load multiple packages quietly
#'
#' Attach one or more installed packages while suppressing startup messages.
#' Package names may be supplied as bare names, strings, or character vectors.
#'
#' @param ... Package names supplied as bare names, character strings, or
#'   character vectors.
#'
#' @return Invisibly, a named logical vector indicating which packages were
#'   loaded successfully.
#'
#' @export
#' @examples
#' using(ggplot2)
#' using(c("ggplot2", "grid"))
using <- function(...) {
    expressions <- base::as.list(base::substitute(base::list(...)))[-1L]
    if (base::length(expressions) == 0L) {
        return(base::invisible(base::structure(logical(), names = character())))
    }

    calling_environment <- base::parent.frame()
    packages <- base::unlist(base::lapply(expressions, function(expression) {
        if (base::is.symbol(expression)) {
            symbol <- base::as.character(expression)
            if (base::exists(symbol, envir = calling_environment, inherits = TRUE)) {
                value <- base::get(symbol, envir = calling_environment, inherits = TRUE)
                if (base::is.character(value)) {
                    return(value)
                }
            }
            return(symbol)
        }

        value <- base::eval(expression, envir = calling_environment)
        if (!base::is.character(value)) {
            base::stop(
                "Package specifications must be names or character vectors.",
                call. = FALSE
            )
        }
        value
    }), use.names = FALSE)

    if (base::length(packages) == 0L || base::anyNA(packages) ||
        base::any(!base::nzchar(packages))) {
        base::stop("Package names must not be empty or missing.", call. = FALSE)
    }
    packages <- base::unique(packages)

    loaded <- base::vapply(packages, function(package) {
        base::suppressPackageStartupMessages(
            base::require(package, character.only = TRUE, quietly = TRUE)
        )
    }, logical(1))
    base::names(loaded) <- packages

    if (!base::all(loaded)) {
        failed <- packages[!loaded]
        base::warning(
            "Failed to load: ",
            base::paste(failed, collapse = ", "),
            call. = FALSE
        )
    }
    base::invisible(loaded)
}
