display_dem <- aggregate(dem, fact = 10, fun = "mean", na.rm = TRUE)
a <- terrain(display_dem, v = c("slope", "aspect"), unit = "radians")
sh <- shade(a$slope, a$aspect, angle = 45, direction = 315, normalize = TRUE)
plot(sh, col = gray.colors(100, 0, 1), main = "Regional hillshade: brightness (0-255)")
plot_raster <- function(r, s = r, p = "Viridis", title = "", limits = NULL) {
  stopifnot(compareGeom(r, s), p %in% hcl.pals())
  a <- terrain(s, v = c("slope", "aspect"), unit = "radians")
  sh <- shade(a$slope, a$aspect, angle = 45, direction = 315, normalize = TRUE)
  plot(sh, col = gray.colors(100, 0, 1), legend = FALSE, main = title)
  plot(r, add = TRUE, alpha = 0.65, col = hcl.colors(100, p), range = limits)
}
plot_raster(display_dem, p = "Terrain", title = "Regional shaded elevation (m), 250 m display")
lines(dept)
