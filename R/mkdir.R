#' Make Directory
#'
#' Make Directory
#'
#' @param directory directory path
#'
#' @return nothing
#'
#' @export
#' @examples
#' mkdir(getwd())
mkdir <- function(directory) {
    if (!dir.exists(directory)) {
        dir.create(directory, showWarnings = FALSE, recursive = TRUE, mode = "0777")
    } else {
        base::warning(crayon::cyan("\nDirectory alreday existed: ", directory))
    }
}
