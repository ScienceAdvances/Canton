#' Create a figure export preset
#'
#' Create reusable dimensions and output settings for [imagesave()]. Presets
#' are starting points rather than journal-specific guarantees; always compare
#' them with the current author instructions for the target journal.
#'
#' @param name Built-in preset name: `"publication"`, `"single_column"`,
#'   `"double_column"`, `"high_resolution"`, or `"presentation"`.
#' @param format,width,height,units,dpi,bg,quality,compression,pointsize
#'   Optional values that override the built-in preset.
#'
#' @return An object of class `canton_figure_preset`.
#' @export
#'
#' @examples
#' figure_preset("single_column")
#' figure_preset("publication", format = c("pdf", "png"), dpi = 600)
figure_preset <- function(
    name = c(
        "publication", "single_column", "double_column",
        "high_resolution", "presentation"
    ),
    format = NULL,
    width = NULL,
    height = NULL,
    units = NULL,
    dpi = NULL,
    bg = NULL,
    quality = NULL,
    compression = NULL,
    pointsize = NULL
) {
    name <- base::match.arg(name)
    preset <- base::switch(name,
        publication = base::list(
            format = c("pdf", "tiff"), width = 7, height = 5,
            units = "in", dpi = 300, bg = "white", quality = 95,
            compression = "lzw", pointsize = 10
        ),
        single_column = base::list(
            format = c("pdf", "tiff"), width = 3.5, height = 3,
            units = "in", dpi = 300, bg = "white", quality = 95,
            compression = "lzw", pointsize = 8
        ),
        double_column = base::list(
            format = c("pdf", "tiff"), width = 7.2, height = 4.8,
            units = "in", dpi = 300, bg = "white", quality = 95,
            compression = "lzw", pointsize = 10
        ),
        high_resolution = base::list(
            format = c("png", "tiff"), width = 7, height = 5,
            units = "in", dpi = 600, bg = "white", quality = 100,
            compression = "lzw", pointsize = 10
        ),
        presentation = base::list(
            format = "png", width = 10, height = 5.625,
            units = "in", dpi = 150, bg = "white", quality = 95,
            compression = "lzw", pointsize = 18
        )
    )

    overrides <- base::list(
        format = format, width = width, height = height, units = units,
        dpi = dpi, bg = bg, quality = quality, compression = compression,
        pointsize = pointsize
    )
    for (field in base::names(overrides)) {
        if (!base::is.null(overrides[[field]])) {
            preset[[field]] <- overrides[[field]]
        }
    }

    .figure_preset_validate(preset)
    preset$name <- name
    preset <- preset[c(
        "name", "format", "width", "height", "units", "dpi", "bg",
        "quality", "compression", "pointsize"
    )]
    base::structure(preset, class = c("canton_figure_preset", "list"))
}

.figure_preset_validate <- function(preset) {
    supported <- c("pdf", "png", "jpg", "jpeg", "tif", "tiff")
    if (!base::is.character(preset$format) || base::length(preset$format) < 1L ||
        base::anyNA(preset$format) ||
        base::any(!base::tolower(preset$format) %in% supported)) {
        base::stop("The preset contains an unsupported `format`.", call. = FALSE)
    }
    .imagesave_validate_number(preset$width, "width", lower = 0, strict = TRUE)
    .imagesave_validate_number(preset$height, "height", lower = 0, strict = TRUE)
    .imagesave_validate_number(preset$dpi, "dpi", lower = 0, strict = TRUE)
    .imagesave_validate_number(preset$quality, "quality", lower = 0, upper = 100)
    .imagesave_validate_number(
        preset$pointsize, "pointsize", lower = 0, strict = TRUE
    )
    if (!base::is.character(preset$units) || base::length(preset$units) != 1L ||
        !preset$units %in% c("in", "cm", "mm")) {
        base::stop("The preset contains invalid `units`.", call. = FALSE)
    }
    .imagesave_validate_scalar(preset$bg, "bg", type = "character")
    .imagesave_validate_scalar(
        preset$compression, "compression", type = "character"
    )
    base::invisible(preset)
}

.figure_preset_resolve <- function(preset) {
    if (base::is.character(preset) && base::length(preset) == 1L) {
        return(figure_preset(preset))
    }
    if (!base::inherits(preset, "canton_figure_preset")) {
        base::stop(
            "`preset` must be a built-in preset name or an object returned by `figure_preset()`.",
            call. = FALSE
        )
    }
    .figure_preset_validate(preset)
    preset
}
