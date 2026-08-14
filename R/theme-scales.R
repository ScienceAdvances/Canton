#' A publication-oriented ggplot2 theme
#'
#' A compact classic theme with explicit font, line, tick, legend, and grid
#' defaults suitable as a starting point for scientific figures.
#'
#' @param base_size Base font size in points.
#' @param base_family Base font family. Defaults to the family configured by
#'   [setfont()], or `"sans"` when no family has been configured.
#' @param grid Which panel grid lines to show: `"none"`, `"major"`, or
#'   `"both"`.
#' @param legend_position ggplot2 legend position.
#'
#' @return A ggplot2 theme object.
#' @export
#'
#' @examples
#' ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
#'   ggplot2::geom_point() +
#'   theme_canton()
theme_canton <- function(
    base_size = 10,
    base_family = base::getOption("Canton.font_family", "sans"),
    grid = c("none", "major", "both"),
    legend_position = "right"
) {
    .imagesave_validate_number(
        base_size, "base_size", lower = 0, strict = TRUE
    )
    if (base::is.null(base_family)) base_family <- "sans"
    .imagesave_validate_scalar(
        base_family, "base_family", type = "character"
    )
    grid <- base::match.arg(grid)

    result <- ggplot2::theme_classic(
        base_size = base_size,
        base_family = base_family
    ) +
        ggplot2::theme(
            plot.title = ggplot2::element_text(
                face = "bold", size = ggplot2::rel(1.1), hjust = 0
            ),
            axis.title = ggplot2::element_text(size = ggplot2::rel(1)),
            axis.text = ggplot2::element_text(
                colour = "black", size = ggplot2::rel(0.9)
            ),
            axis.line = ggplot2::element_line(
                colour = "black", linewidth = 0.4
            ),
            axis.ticks = ggplot2::element_line(
                colour = "black", linewidth = 0.4
            ),
            legend.position = legend_position,
            legend.title = ggplot2::element_text(face = "bold"),
            legend.key = ggplot2::element_blank(),
            strip.background = ggplot2::element_blank(),
            strip.text = ggplot2::element_text(face = "bold"),
            plot.margin = ggplot2::margin(5.5, 5.5, 5.5, 5.5)
        )

    if (grid == "none") {
        result <- result + ggplot2::theme(panel.grid = ggplot2::element_blank())
    } else if (grid == "major") {
        result <- result + ggplot2::theme(
            panel.grid.major = ggplot2::element_line(
                colour = "grey88", linewidth = 0.3
            ),
            panel.grid.minor = ggplot2::element_blank()
        )
    } else {
        result <- result + ggplot2::theme(
            panel.grid.major = ggplot2::element_line(
                colour = "grey88", linewidth = 0.3
            ),
            panel.grid.minor = ggplot2::element_line(
                colour = "grey94", linewidth = 0.2
            )
        )
    }

    result
}

#' Canton colour scales for ggplot2
#'
#' Apply a palette returned by [hue()] to discrete or continuous ggplot2
#' colour and fill scales.
#'
#' @param palette Canton palette name.
#' @param ... Additional arguments passed to the corresponding ggplot2 scale.
#'
#' @return A ggplot2 scale object.
#' @name canton_scales
NULL

#' @rdname canton_scales
#' @export
scale_colour_canton_d <- function(palette = "NPG", ...) {
    ggplot2::scale_colour_manual(values = hue(palette), ...)
}

#' @rdname canton_scales
#' @export
scale_color_canton_d <- scale_colour_canton_d

#' @rdname canton_scales
#' @export
scale_fill_canton_d <- function(palette = "NPG", ...) {
    ggplot2::scale_fill_manual(values = hue(palette), ...)
}

#' @rdname canton_scales
#' @export
scale_colour_canton_c <- function(palette = "NPG", ...) {
    ggplot2::scale_colour_gradientn(colours = hue(palette), ...)
}

#' @rdname canton_scales
#' @export
scale_color_canton_c <- scale_colour_canton_c

#' @rdname canton_scales
#' @export
scale_fill_canton_c <- function(palette = "NPG", ...) {
    ggplot2::scale_fill_gradientn(colours = hue(palette), ...)
}
