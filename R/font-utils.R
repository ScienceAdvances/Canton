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
    family <- base::trimws(family)
    if (!base::nzchar(family)) {
        base::stop("`family` must not be empty.", call. = FALSE)
    }
    available <- .canton_font_available(family)

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

#' Compatibility helper for scoped font settings
#'
#' Font settings now restore automatically when the `code` block in
#' [setfont()] exits. This compatibility helper does not modify user settings.
#' @param quiet Suppress the status message.
#' @return Invisibly, `FALSE`; no persistent settings need restoring.
#' @export
#' @examples
#' resetfont(quiet = TRUE)
resetfont <- function(quiet = FALSE) {
    .imagesave_validate_scalar(quiet, "quiet", type = "logical")
    if (!quiet) base::message("Font settings restore automatically after setfont(code = ...).")
    base::invisible(FALSE)
}
