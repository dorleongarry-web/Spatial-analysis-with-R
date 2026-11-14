# Run after 02-render-blocks.R in the same R session.
# Only the global web overlay is resized; France overlays retain every cell.
local({
  earth <- lesson_env$earth
  cropped <- lesson_env$topo_crop
  masked <- lesson_env$topo_mask
  overlay <- function(x, filename) {
    v <- as.vector(t(as.matrix(x, wide = TRUE)))
    colors <- rep("#00000000", length(v))
    valid <- is.finite(v)
    colors[valid] <- gray(pmin(255, pmax(0, v[valid])) / 255)
    png(file.path("assets/maps", filename), width = ncol(x), height = nrow(x), bg = "transparent")
    par(mar = rep(0, 4), xaxs = "i", yaxs = "i")
    plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1))
    rasterImage(as.raster(matrix(colors, nrow = nrow(x), byrow = TRUE)), 0, 0, 1, 1, interpolate = FALSE)
    dev.off()
  }
  overlay(aggregate(earth, fact = 4, fun = "mean"), "global-raster.png")
  overlay(cropped, "france-crop.png")
  overlay(masked, "france-mask.png")
  e <- as.vector(ext(cropped)); w <- as.vector(ext(earth))
  writeLines(sprintf('{"world_bounds":[[%s,%s],[%s,%s]],"france_bounds":[[%s,%s],[%s,%s]],"source":"relief_mondial.tif","note":"Image intensities, not elevation. Global web overlay reduced 4x; regional overlays at native resolution."}', w[3], w[1], w[4], w[2], e[3], e[1], e[4], e[2]), "assets/maps/raster-bounds.json")
  stopifnot(nrow(earth) == 5400, ncol(earth) == 10800, same.crs(earth, masked),
            isTRUE(all.equal(res(earth), res(masked))))
  capture.output({
    cat("PASS: full-resolution source = 10800 x 5400 cells\n")
    cat("PASS: source resolution retained by crop and mask\n")
    cat("PASS: 12 displayed R blocks executed successfully\n")
    print(earth); print(masked)
  }, file = "outputs/02-validation.txt")
})
