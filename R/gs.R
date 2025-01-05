#' Save ggplot2 object plot
#'
#' Save ggplot2 object plot
#'
#' @param p ggplot2 object plot
#' @param outdir output directory
#' @param name output filename
#' @param format output image format, pdf or png or both
#' @param w width
#' @param h height
#' @return nothing
#'
#' @export
#' @examples
#' gs(p = plot, outdir = "Result", name = "gplot", w = 9, h = 9)
gs <- function(p, name = "gplot", outdir = base::getwd(), format = "pdf", w = 9, h = 9) {
    mkdir(outdir)
    if ("pdf" %in% format) {
        Cairo::CairoPDF(file = base::file.path(outdir, base::paste0(name, ".pdf")), width = w, height = h)
        invisible(print(p))
        dev.off()
    } else if ("png" %in% format) {
        Cairo::CairoPNG(filename = base::file.path(outdir, base::paste0(name, ".png")), res = 300, units = "in", bg = "white", width = w, height = h)
        invisible(print(p))
        dev.off()
    }
}
