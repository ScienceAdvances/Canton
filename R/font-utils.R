#' List available font families
#'
#' List font families detected by the operating system and by the systemfonts
#' registry.
#'
#' @param pattern Optional regular expression used to filter family names.
#'
#' @return A sorted character vector of font family names.
#' @export
#'
#' @examples
#' head(fontlist(), 10)
#' fontlist("Arial")
fontlist <- function(pattern = NULL) {
    if (!base::is.null(pattern)) {
        .imagesave_validate_scalar(pattern, "pattern", type = "character")
    }
    families <- c(
        systemfonts::system_fonts()$family,
        systemfonts::registry_fonts()$family
    )
    families <- base::sort(base::unique(families[base::nzchar(families)]))
    if (!base::is.null(pattern)) {
        families <- families[base::grepl(pattern, families, ignore.case = TRUE)]
    }
    families
}

#' Check whether a plotting font is available
#'
#' @param family Font family to check.
#' @param error Whether to throw an informative error when the font is missing.
#' @param quiet Whether to suppress the status message.
#'
#' @return A logical scalar.
#' @export
#'
#' @examples
#' fontcheck("sans", quiet = TRUE)
fontcheck <- function(family = "Arial", error = FALSE, quiet = FALSE) {
    .imagesave_validate_scalar(family, "family", type = "character")
    .imagesave_validate_scalar(error, "error", type = "logical")
    .imagesave_validate_scalar(quiet, "quiet", type = "logical")
    available <- .canton_font_available(base::trimws(family))

    if (!available && error) {
        base::stop(.canton_font_install_message(family), call. = FALSE)
    }
    if (!quiet) {
        base::message(
            "Font `", family, "` is ",
            if (available) "available." else "not available."
        )
    }
    available
}

#' Restore plotting font settings
#'
#' Restore the ggplot2 theme and default graphics family saved by the first
#' call to [setfont()] in the current R session.
#'
#' @param quiet Whether to suppress the status message.
#'
#' @return Invisibly, `TRUE` when settings were restored and `FALSE` when no
#'   saved settings were available.
#' @export
#'
#' @examples
#' setfont("sans", quiet = TRUE)
#' resetfont(quiet = TRUE)
resetfont <- function(quiet = FALSE) {
    .imagesave_validate_scalar(quiet, "quiet", type = "logical")
    state <- base::getOption("Canton.previous_font_state", NULL)
    if (base::is.null(state)) {
        if (!quiet) base::message("No Canton font settings to restore.")
        return(base::invisible(FALSE))
    }

    ggplot2::theme_set(state$theme)
    base::options(
        Canton.font_family = state$family,
        Canton.previous_font_state = NULL
    )
    if (grDevices::dev.cur() != 1L) {
        current_family <- if (base::is.null(state$family)) "" else state$family
        base::try(graphics::par(family = current_family), silent = TRUE)
    }

    if (!quiet) base::message("Previous plotting font settings restored.")
    base::invisible(TRUE)
}
