# Run from the repository root: source("scripts/02-build-figures.R")
# Execute the teaching script, then export the exact datasets it creates.
dir.create("outputs", showWarnings = FALSE)
pdf("outputs/02-teaching-plots.pdf", width = 11, height = 7)
tryCatch(source("scripts/02-basics.R", encoding = "UTF-8"),
         finally = dev.off())
dir.create("assets/figures", recursive = TRUE, showWarnings = FALSE)
save_plot <- function(name, draw, width = 1500, height = 800) {
  png(file.path("assets/figures", paste0(name, ".png")),
      width = width, height = height, res = 140, type = "cairo")
  tryCatch({par(mar = c(4, 4, 3, 2)); draw()}, finally = dev.off())
}
save_plot("countries", function() {
  plot(countries, col = "#dbe8df", border = "#5f757a", main = "Natural Earth country boundaries")
  plot(france, col = "#f5b942", add = TRUE)
})
save_plot("gdp-per-capita", function() {
  plot(countries2, col = gdp_palette[as.integer(countries2$gdp_hab_cat)],
       border = "#788787", main = "GDP per capita (USD; source teaching dataset)")
  legend("bottomleft", legend = labels, fill = gdp_palette, bty = "n", cex = 0.85)
})
save_plot("gdp-distribution", function() {
  par(mfrow = c(1, 2), mar = c(12, 5, 4.5, 2))
  hist(log10(countries2$gdp_hab), col = "#86b6a5", border = "white",
       main = "GDP per capita", xlab = "log10(USD per person)")
  boxplot(gdp_hab ~ economy, data = as.data.frame(countries2), log = "y",
          las = 2, cex.axis = 0.65, col = "#dbe8df", xlab = "", ylab = "USD per person")
}, height = 1100)
save_plot("france-projections", function() {
  par(mfrow = c(1, 2))
  plot(france_met_wgs84, col = "#ead4b5", main = "WGS84 / EPSG:4326 (degrees)")
  plot(france_met_l93, col = "#91bfc2", main = "Lambert-93 / EPSG:2154 (metres)")
})
save_plot("nuclear-plants", function() {
  plot(france_met_wgs84, col = "#e8eee6", main = "Nuclear reactors (historical teaching dataset)")
  points(npp2, bg = start_palette[cat_index], pch = 21,
         cex = sqrt(npp$Net_power_Mwe / 700))
  legend("bottomleft", legend = levels(npp2$start_cat), fill = start_palette, bty = "n")
}, width = 1000, height = 1000)
save_plot("global-raster", function() {
  plot(earth, col = gray(seq(0, 1, length.out = 101)),
       main = "Natural Earth shading: pixel intensity, not elevation")
  lines(countries, col = "#3a646c", lwd = 0.4)
})
save_plot("raster-histogram", function() {
  hist(values(earth), breaks = 30, col = "#86b6a5", border = "white",
       main = "Distribution of all preview raster pixels", xlab = "Image intensity (not elevation)")
})
save_plot("raster-crop-mask", function() {
  par(mfrow = c(1, 2))
  common_range <- range(values(topo_crop), na.rm = TRUE)
  plot(topo_crop, range = common_range, main = "Crop: rectangular extent")
  lines(france_met_wgs84, col = "#174c53")
  plot(topo_mask, range = common_range, main = "Mask: pixels outside France are NA")
  lines(france_met_wgs84, col = "#174c53")
})
capture.output(sessionInfo(), file = "outputs/02-session-info.txt")
# Export raster overlays with no axes, borders or margins: one image pixel
# corresponds to one raster cell, including transparent cells outside France.
dir.create("assets/maps", recursive = TRUE, showWarnings = FALSE)
overlay <- function(x, name) {
  v <- as.vector(t(as.matrix(x, wide = TRUE)))
  rgba <- rep("#00000000", length(v))
  good <- is.finite(v)
  rgba[good] <- gray(pmin(255, pmax(0, v[good])) / 255)
  png(file.path("assets/maps", name), width = ncol(x), height = nrow(x), bg = "transparent")
  par(mar = rep(0, 4), xaxs = "i", yaxs = "i")
  plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1))
  rasterImage(as.raster(matrix(rgba, nrow = nrow(x), byrow = TRUE)),
              0, 0, 1, 1, interpolate = FALSE)
  dev.off()
}
overlay(earth, "global-raster.png")
overlay(topo_crop, "france-crop.png")
overlay(topo_mask, "france-mask.png")
e <- as.vector(ext(topo_crop))
w <- as.vector(ext(earth))
writeLines(sprintf('{"world_bounds":[[%s,%s],[%s,%s]],"france_bounds":[[%s,%s],[%s,%s]],"source":"GRAY_50M_SR_OB_preview.tif","note":"Image intensities, not elevation."}',
                   w[3], w[1], w[4], w[2], e[3], e[1], e[4], e[2]),
           "assets/maps/raster-bounds.json")
message("Module 02: 8 PNG figures exported to assets/figures/")
