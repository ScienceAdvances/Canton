#' Save ggplot2 object plot
#'
#' Save ggplot2 object plot
#'
#' @param p ggplot2 object plot
#' @param outdir output directory
#' @param name output filename
#' @param w width
#' @param h height
#' @return nothing
#'
#' @export
#' @examples
#' gs(p = plot, outdir = "Result", name = "A", w = 7, h = 7)

gs <- function(p, outdir = base::getwd(), name = "", w = 7, h = 7) {
    mkdir(outdir)
    grDevices::pdf(file = base::file.path(outdir, base::paste0("F_", name, ".pdf")), width = w, height = h)
    invisible(print(p))
    dev.off()
    grDevices::png(filename = base::file.path(outdir, base::paste0("F_", name, ".png")),res=300,units='in',bg='white', width = w, height = h)
    invisible(print(p))
    dev.off()
}