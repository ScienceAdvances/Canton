#' Print Current Working Directory
#'
#' Print the full filename of the current working directory.
#'
#' @param
#'
#' @return a string of current working directory
#'
#' @export
#' @examples
#' pwd()
pwd <- function() {
    return(base::getwd())
}
