#' Set the default plotting font
#'
#' `setfont()` checks that a font family is available and applies it to the
#' active ggplot2 theme, the current base graphics device, future base plots,
#' and [imagesave()]. It does not download or install proprietary fonts.
#'
#' Arial is proprietary and has no official standalone download. If it is not
#' installed, `setfont()` reports platform-specific installation guidance.
#'
#' @param family Font family to use. Defaults to `"Arial"`.
#' @param fallback Optional fallback family. If `family` is unavailable and
#'   `fallback` is available, use it after issuing a warning. The aliases
#'   `"sans"`, `"serif"`, and `"mono"` are always accepted.
#' @param quiet Whether to suppress the success message.
#'
#' @return Invisibly, the font family that was configured.
#' @export
#'
#' @examples
#' setfont("sans", quiet = TRUE)
#' resetfont(quiet = TRUE)
setfont <- function(family = "Arial", fallback = NULL, quiet = FALSE) {
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

    if (base::is.null(base::getOption("Canton.previous_font_state", NULL))) {
        base::options(Canton.previous_font_state = base::list(
            family = base::getOption("Canton.font_family", NULL),
            theme = ggplot2::theme_get()
        ))
    }

    .canton_register_font(family)
    base::options(Canton.font_family = family)

    ggplot2::theme_update(text = ggplot2::element_text(family = family))

    if (!base::isTRUE(base::getOption("Canton.font_hook_registered"))) {
        base::setHook(
            "before.plot.new",
            function() {
                current_family <- base::getOption("Canton.font_family", NULL)
                if (!base::is.null(current_family) && base::nzchar(current_family)) {
                    base::try(graphics::par(family = current_family), silent = TRUE)
                }
            },
            action = "append"
        )
        base::options(Canton.font_hook_registered = TRUE)
    }

    if (grDevices::dev.cur() != 1L) {
        base::try(graphics::par(family = family), silent = TRUE)
    }

    if (!quiet) {
        base::message("Default plotting font set to: ", family)
    }
    base::invisible(family)
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

.canton_register_font <- function(family) {
    if (base::tolower(family) %in% c("sans", "serif", "mono", "symbol", "emoji", "")) {
        return(base::invisible(family))
    }

    platform <- base::Sys.info()[["sysname"]]
    if (base::identical(platform, "Darwin")) {
        font_rows <- systemfonts::system_fonts()
        font_rows <- font_rows[base::tolower(font_rows$family) == base::tolower(family), ]
        face_names <- .canton_quartz_faces(font_rows, family)
        mapping <- base::structure(
            base::list(grDevices::quartzFont(face_names)),
            names = family
        )
        base::do.call(grDevices::quartzFonts, mapping)
    } else if (base::identical(.Platform$OS.type, "windows")) {
        mapping <- base::structure(
            base::list(grDevices::windowsFont(family)),
            names = family
        )
        base::do.call(grDevices::windowsFonts, mapping)
    }

    base::invisible(family)
}

.canton_quartz_faces <- function(font_rows, family) {
    choose <- function(bold, italic) {
        candidates <- font_rows[
            font_rows$italic == italic & (font_rows$weight == "bold") == bold,
        ]
        if (base::nrow(candidates) < 1L) {
            candidates <- font_rows
        }
        if (base::nrow(candidates) < 1L) family else candidates$name[[1L]]
    }
    c(
        choose(FALSE, FALSE),
        choose(TRUE, FALSE),
        choose(FALSE, TRUE),
        choose(TRUE, TRUE)
    )
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
