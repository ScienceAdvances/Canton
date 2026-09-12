#' Save plots in one or more image formats
#'
#' `imagesave()` saves ggplot2 plots, pheatmap and ComplexHeatmap objects, grid
#' graphical objects, recorded base R plots, lattice plots, and plotting
#' functions. When `plot` is `NULL`, the current plot is captured with
#' [grDevices::recordPlot()].
#'
#' ggplot2 and grid-based objects are saved with [ggplot2::ggsave()]. Recorded
#' plots and plotting functions are redrawn on a format-specific graphics
#' device.
#'
#' @param plot A plot object or a zero-argument function that draws a plot.
#'   Supported objects include `ggplot`, `pheatmap`, ComplexHeatmap `Heatmap`
#'   and `HeatmapList` objects, `grob`/`gtable`, `recordedplot`, and `trellis`.
#'   If `NULL`, capture the current plot.
#' @param name Output filename stem. A supported extension in `name` is used
#'   when `format` is omitted.
#' @param outdir Required output directory. No files are written unless an
#'   explicit, non-empty directory is supplied.
#' @param format One or more of `"pdf"`, `"png"`, `"jpg"`, `"jpeg"`,
#'   `"tif"`, or `"tiff"`.
#' @param preset Optional built-in preset name or an object returned by
#'   [figure_preset()]. Explicitly supplied arguments override preset values.
#' @param width,height Plot dimensions.
#' @param units Units for `width` and `height`: `"in"`, `"cm"`, or `"mm"`.
#' @param dpi Resolution for raster formats.
#' @param bg Background colour.
#' @param quality JPEG quality from 0 to 100.
#' @param compression TIFF compression method.
#' @param pointsize Default text point size for graphics devices.
#' @param family Optional font family passed to graphics devices.
#' @param overwrite Whether existing files may be overwritten.
#'
#' @return Invisibly, a named character vector containing the output paths.
#' @export
#'
#' @examples
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
#'   ggplot2::geom_point()
#' imagesave(p, "scatter", outdir = tempdir(), format = c("png", "pdf"))
#'
#' imagesave(function() plot(mtcars$mpg, mtcars$wt),
#'           name = "base-plot", outdir = tempdir(), format = "png")
imagesave <- function(plot = NULL,
                      name = "plot",
                      outdir,
                      format = "pdf",
                      preset = NULL,
                      width = 9,
                      height = 9,
                      units = "in",
                      dpi = 300,
                      bg = "white",
                      quality = 95,
                      compression = "lzw",
                      pointsize = 12,
                      family = base::getOption("Canton.font_family", NULL),
                      overwrite = TRUE) {
    if (missing(outdir)) {
        base::stop("Supply an explicit `outdir`.", call. = FALSE)
    }
    format_missing <- missing(format)
    width_missing <- missing(width)
    height_missing <- missing(height)
    units_missing <- missing(units)
    dpi_missing <- missing(dpi)
    bg_missing <- missing(bg)
    quality_missing <- missing(quality)
    compression_missing <- missing(compression)
    pointsize_missing <- missing(pointsize)

    if (!base::is.null(preset)) {
        preset <- .figure_preset_resolve(preset)
        if (format_missing) format <- preset$format
        if (width_missing) width <- preset$width
        if (height_missing) height <- preset$height
        if (units_missing) units <- preset$units
        if (dpi_missing) dpi <- preset$dpi
        if (bg_missing) bg <- preset$bg
        if (quality_missing) quality <- preset$quality
        if (compression_missing) compression <- preset$compression
        if (pointsize_missing) pointsize <- preset$pointsize
    }

    .imagesave_validate_scalar(name, "name", type = "character")
    .imagesave_validate_scalar(outdir, "outdir", type = "character")
    if (!base::nzchar(base::trimws(outdir))) {
        base::stop("`outdir` must not be empty.", call. = FALSE)
    }
    .imagesave_validate_number(width, "width", lower = 0, strict = TRUE)
    .imagesave_validate_number(height, "height", lower = 0, strict = TRUE)
    .imagesave_validate_number(dpi, "dpi", lower = 0, strict = TRUE)
    .imagesave_validate_number(quality, "quality", lower = 0, upper = 100)
    .imagesave_validate_number(pointsize, "pointsize", lower = 0, strict = TRUE)

    units <- base::match.arg(units, c("in", "cm", "mm"))
    .imagesave_validate_scalar(bg, "bg", type = "character")
    .imagesave_validate_scalar(compression, "compression", type = "character")
    .imagesave_validate_scalar(overwrite, "overwrite", type = "logical")
    if (!base::is.null(family)) {
        .imagesave_validate_scalar(family, "family", type = "character")
        if (!.canton_font_available(family)) {
            base::stop(.canton_font_install_message(family), call. = FALSE)
        }
    }

    supported <- c("pdf", "png", "jpg", "jpeg", "tif", "tiff")
    supplied_extension <- .imagesave_extension(name)

    if (format_missing && supplied_extension %in% supported) {
        format <- supplied_extension
    }
    if (base::length(format) < 1L || !base::is.character(format) ||
        base::anyNA(format)) {
        base::stop("`format` must contain at least one image format.", call. = FALSE)
    }

    format <- base::tolower(format)
    invalid_format <- base::setdiff(format, supported)
    if (base::length(invalid_format) > 0L) {
        base::stop(
            "Unsupported format: ",
            base::paste(invalid_format, collapse = ", "),
            ". Supported formats are: ",
            base::paste(supported, collapse = ", "),
            ".",
            call. = FALSE
        )
    }
    format <- base::unique(format)

    if (supplied_extension %in% supported) {
        name <- base::substr(
            name,
            1L,
            base::nchar(name) - base::nchar(supplied_extension) - 1L
        )
    }
    if (!base::nzchar(name)) {
        base::stop("`name` must contain a filename stem.", call. = FALSE)
    }

    plot_info <- .imagesave_prepare_plot(plot)
    if (!base::dir.exists(outdir) &&
        !base::dir.create(outdir, recursive = TRUE, showWarnings = FALSE)) {
        base::stop("Unable to create output directory: ", outdir, call. = FALSE)
    }
    outdir <- base::normalizePath(outdir, mustWork = TRUE)

    paths <- base::file.path(outdir, base::paste0(name, ".", format))
    base::names(paths) <- format
    parent_dirs <- base::unique(base::dirname(paths))
    for (directory in parent_dirs) {
        if (!base::dir.exists(directory) &&
            !base::dir.create(directory, recursive = TRUE, showWarnings = FALSE)) {
            base::stop("Unable to create output directory: ", directory, call. = FALSE)
        }
    }

    if (!overwrite && base::any(base::file.exists(paths))) {
        existing <- paths[base::file.exists(paths)]
        base::stop(
            "Output file already exists: ",
            base::paste(existing, collapse = ", "),
            call. = FALSE
        )
    }

    for (i in base::seq_along(paths)) {
        if (plot_info$method == "ggsave") {
            .imagesave_ggsave(
                plot = plot_info$plot,
                filename = paths[[i]],
                format = format[[i]],
                width = width,
                height = height,
                units = units,
                dpi = dpi,
                bg = bg,
                quality = quality,
                compression = compression,
                pointsize = pointsize,
                family = family
            )
        } else {
            .imagesave_device(
                draw = plot_info$draw,
                filename = paths[[i]],
                format = format[[i]],
                width = width,
                height = height,
                units = units,
                dpi = dpi,
                bg = bg,
                quality = quality,
                compression = compression,
                pointsize = pointsize,
                family = family
            )
        }
    }

    base::invisible(paths)
}

.imagesave_prepare_plot <- function(plot) {
    if (base::is.null(plot)) {
        if (grDevices::dev.cur() == 1L) {
            base::stop(
                "There is no current plot to capture. Supply a plot object or draw a plot first.",
                call. = FALSE
            )
        }
        plot <- grDevices::recordPlot()
    }

    if (base::inherits(plot, "pheatmap")) {
        if (base::is.null(plot$gtable) ||
            !base::inherits(plot$gtable, c("grob", "gTree", "gtable", "gList"))) {
            base::stop("The pheatmap object does not contain a valid `$gtable`.", call. = FALSE)
        }
        return(base::list(method = "ggsave", plot = plot$gtable))
    }

    if (base::inherits(plot, c("Heatmap", "HeatmapList"))) {
        if (!base::requireNamespace("ComplexHeatmap", quietly = TRUE)) {
            base::stop(
                "Saving a ComplexHeatmap object requires the suggested ",
                "package `ComplexHeatmap`.",
                call. = FALSE
            )
        }
        return(base::list(
            method = "device",
            draw = function() {
                draw_heatmap <- base::getExportedValue("ComplexHeatmap", "draw")
                draw_heatmap(plot)
            }
        ))
    }

    if (base::inherits(plot, "ggplot")) {
        return(base::list(method = "ggsave", plot = plot))
    }

    if (base::inherits(plot, c("grob", "gTree", "gtable", "gList"))) {
        return(base::list(method = "ggsave", plot = plot))
    }

    if (base::inherits(plot, "recordedplot")) {
        return(base::list(
            method = "device",
            draw = function() grDevices::replayPlot(plot)
        ))
    }

    if (base::inherits(plot, "trellis")) {
        return(base::list(
            method = "device",
            draw = function() base::print(plot)
        ))
    }

    if (base::is.function(plot)) {
        return(base::list(method = "device", draw = plot))
    }

    base::stop(
        "Unsupported plot object with class: ",
        base::paste(base::class(plot), collapse = "/"),
        ". Supply a supported plot object, a recorded plot, or a zero-argument plotting function.",
        call. = FALSE
    )
}

.imagesave_ggsave <- function(plot, filename, format, width, height, units,
                              dpi, bg, quality, compression, pointsize,
                              family) {
    device <- base::switch(format,
        jpg = "jpeg",
        jpeg = "jpeg",
        tif = "tiff",
        tiff = "tiff",
        format
    )
    if (format == "pdf" && !base::is.null(family)) {
        device <- .imagesave_pdf_device(family)
    }
    args <- base::list(
        filename = filename,
        plot = plot,
        device = device,
        width = width,
        height = height,
        units = units,
        dpi = dpi,
        bg = bg,
        pointsize = pointsize
    )
    if (format %in% c("jpg", "jpeg")) {
        args$quality <- quality
    }
    if (format %in% c("tif", "tiff") &&
        .imagesave_supports_tiff_compression()) {
        args$compression <- compression
    }
    if (!base::is.null(family)) {
        args$family <- family
    }
    base::do.call(ggplot2::ggsave, args)
    base::invisible(filename)
}

.imagesave_device <- function(draw, filename, format, width, height, units,
                              dpi, bg, quality, compression, pointsize,
                              family) {
    inches <- base::switch(units,
        "in" = 1,
        "cm" = 1 / 2.54,
        "mm" = 1 / 25.4
    )
    width_in <- width * inches
    height_in <- height * inches
    device <- base::switch(format,
        pdf = grDevices::pdf,
        png = grDevices::png,
        jpg = grDevices::jpeg,
        jpeg = grDevices::jpeg,
        tif = grDevices::tiff,
        tiff = grDevices::tiff
    )

    if (format == "pdf") {
        if (!base::is.null(family)) {
            device <- .imagesave_pdf_device(family, direct = TRUE)
        }
        args <- base::list(
            file = filename,
            width = width_in,
            height = height_in,
            bg = bg,
            pointsize = pointsize
        )
    } else {
        args <- base::list(
            filename = filename,
            width = width,
            height = height,
            units = units,
            res = dpi,
            bg = bg,
            pointsize = pointsize
        )
        if (format %in% c("jpg", "jpeg")) {
            args$quality <- quality
        }
        if (format %in% c("tif", "tiff") &&
            .imagesave_supports_tiff_compression()) {
            args$compression <- compression
        }
    }
    if (!base::is.null(family)) {
        args$family <- family
    }

    base::do.call(device, args)
    device_number <- grDevices::dev.cur()
    device_is_open <- TRUE
    base::on.exit({
        devices <- grDevices::dev.list()
        if (device_is_open && !base::is.null(devices) &&
            device_number %in% devices) {
            grDevices::dev.off(device_number)
        }
    }, add = TRUE)

    draw()
    grDevices::dev.off(device_number)
    device_is_open <- FALSE
    base::invisible(filename)
}

.imagesave_extension <- function(path) {
    filename <- base::basename(path)
    if (!base::grepl("\\.", filename)) {
        return("")
    }
    base::tolower(base::sub("^.*\\.", "", filename))
}

.imagesave_supports_tiff_compression <- function() {
    # The default Quartz TIFF device on macOS ignores compression and warns.
    !base::identical(base::Sys.info()[["sysname"]], "Darwin")
}

.imagesave_pdf_device <- function(family, direct = FALSE) {
    standard <- c("sans", "serif", "mono", "Helvetica", "Times", "Courier")
    platform <- base::Sys.info()[["sysname"]]

    if (family %in% standard) {
        return(grDevices::pdf)
    }
    if (base::isTRUE(base::capabilities("cairo"))) {
        if (direct) {
            return(function(file, ...) grDevices::cairo_pdf(filename = file, ...))
        }
        return(grDevices::cairo_pdf)
    }
    if (base::identical(platform, "Darwin")) {
        if (direct) {
            return(function(file, ...) {
                grDevices::quartz(file = file, type = "pdf", ...)
            })
        }
        return(function(filename, ...) {
            grDevices::quartz(file = filename, type = "pdf", ...)
        })
    }

    base::stop(
        "Saving a PDF with font `", family,
        "` requires a Cairo-capable R graphics device on this system.",
        call. = FALSE
    )
}

.imagesave_validate_scalar <- function(x, name, type) {
    valid <- base::typeof(x) == type && base::length(x) == 1L &&
        !base::is.na(x)
    if (!valid) {
        base::stop("`", name, "` must be a single ", type, " value.", call. = FALSE)
    }
    base::invisible(x)
}

.imagesave_validate_number <- function(x, name, lower = -Inf, upper = Inf,
                                       strict = FALSE) {
    valid <- base::length(x) == 1L && base::is.numeric(x) &&
        !base::is.na(x) && base::is.finite(x)
    if (strict) {
        valid <- valid && x > lower && x <= upper
    } else {
        valid <- valid && x >= lower && x <= upper
    }
    if (!valid) {
        base::stop("Invalid value for `", name, "`.", call. = FALSE)
    }
    base::invisible(x)
}
