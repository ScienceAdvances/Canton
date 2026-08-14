#' Return the current working directory
#'
#' Return the absolute path of the current working directory.
#'
#' @return A character scalar containing the current working directory.
#'
#' @export
#' @examples
#' pwd()
pwd <- function() {
    base::getwd()
}
