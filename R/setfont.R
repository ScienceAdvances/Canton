#' Configure a font locally
#'
#' Without `code`, validate and return a font family without changing settings.
#' With `code`, apply the font during evaluation and restore the previous
#' options, ggplot2 theme, and existing device's font on exit, including errors.
#' No graphics device is opened and no persistent plotting hook is installed.
#' Print ggplot objects inside the block to render them with the temporary theme.
#'
#' @param family Font family. Defaults to `"Arial"`.
#' @param fallback Optional available fallback, used with a warning.
#' @param quiet Suppress the status message.
#' @param code Optional expression evaluated with temporary font settings.
#'   For base graphics, open an explicit device before calling this function.
#' @return Without `code`, invisibly the validated family; otherwise the
#'   result of evaluating `code`.
#' @export
#' @examples
#' family <- setfont("sans", quiet = TRUE)
#' theme_canton(base_family = family)
#' setfont("sans", quiet = TRUE, code = {
#'   theme_canton()
#' })
setfont <- function(family = "Arial", fallback = NULL, quiet = FALSE, code) {
    .imagesave_validate_scalar(family, "family", type = "character")
    .imagesave_validate_scalar(quiet, "quiet", type = "logical")
    if (!base::nzchar(base::trimws(family))) {
        base::stop("`family` must not be empty.", call. = FALSE)
    }
    family <- base::trimws(family)

    if (!base::is.null(fallback)) {
        .imagesave_validate_scalar(fallback, "fallback", type = "character")
        fallback <- base::trimws(fallback)
        if (!base::nzchar(fallback)) {
            base::stop("`fallback` must not be empty.", call. = FALSE)
        }
    }

    if (!.canton_font_available(family)) {
        if (base::is.null(fallback)) {
            base::stop(.canton_font_install_message(family), call. = FALSE)
        }
        if (!.canton_font_available(fallback)) {
            base::stop(
                .canton_font_install_message(family),
                "\nThe fallback font is also unavailable: ", fallback,
                call. = FALSE
            )
        }
        base::warning(
            "Font `", family, "` is unavailable; using `", fallback, "`.",
            call. = FALSE
        )
        family <- fallback
    }


    if (missing(code)) {
        if (!quiet) base::message("Validated font family: ", family)
        return(base::invisible(family))
    }
    old_options <- base::options(Canton.font_family = family)
    base::on.exit(base::options(old_options), add = TRUE)
    old_theme <- ggplot2::theme_get()
    base::on.exit(ggplot2::theme_set(old_theme), add = TRUE)
    ggplot2::theme_update(text = ggplot2::element_text(family = family))
    device <- grDevices::dev.cur()
    if (device != 1L) {
        old_family <- graphics::par("family")
        base::on.exit({
            if (device %in% grDevices::dev.list()) {
                active <- grDevices::dev.cur()
                grDevices::dev.set(device)
                graphics::par(family = old_family)
                if (active %in% grDevices::dev.list()) grDevices::dev.set(active)
            }
        }, add = TRUE)
        graphics::par(family = family)
    }
    if (!quiet) base::message("Temporarily using font family: ", family)
    base::eval(base::substitute(code), envir = base::parent.frame())
}

.canton_font_available <- function(family) {
    generic <- c("sans", "serif", "mono", "symbol", "emoji", "")
    if (base::tolower(family) %in% generic) {
        return(TRUE)
    }

    fonts <- systemfonts::system_fonts()
    registered <- systemfonts::registry_fonts()
    families <- c(fonts$family, registered$family)

    base::tolower(family) %in% base::tolower(base::unique(families))
}

.canton_font_install_message <- function(family) {
    platform <- base::Sys.info()[["sysname"]]
    guidance <- if (base::identical(platform, "Darwin")) {
        "Install a legally obtained font file with Font Book, then restart R."
    } else if (base::identical(.Platform$OS.type, "windows")) {
        paste0(
            "Install it through Settings > Personalization > Fonts, or install ",
            "a Microsoft product that includes it, then restart R."
        )
    } else {
        paste0(
            "Copy legally obtained font files to ~/.local/share/fonts, run ",
            "`fc-cache -f`, then restart R."
        )
    }

    base::paste0(
        "Font `", family, "` is not installed. ", guidance,
        " Canton does not automatically download proprietary fonts."
    )
}
