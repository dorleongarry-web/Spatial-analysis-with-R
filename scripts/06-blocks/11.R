point_source <- crop(merged_raster, ext(x0 - 3000, x0 + 3000, y0 - 3000, y0 + 3000))
set.seed(356)
elev <- spatSample(point_source, size = 1600, method = "random", na.rm = TRUE, as.points = TRUE)
names(elev) <- "z"
target_resolution <- 10
ext_elev <- ext(x0 - 2500, x0 + 2500, y0 - 2500, y0 + 2500)
r <- rast(ext = ext_elev, resolution = target_resolution, crs = crs(elev))
ext_zoom <- ext(x0 - 1000, x0 + 1000, y0 - 1000, y0 + 1000)
print(r)
print(nrow(elev))
plot(elev, "z", type = "continuous", cex = 0.35, main = "DEM-derived exercise points: elevation (m)")
lines(ext_elev, lwd = 2)
lines(ext_zoom, col = "red", lwd = 2)
add_legend("topright", legend = c("Interpolation extent", "Zoom extent"),
           col = c("black", "red"), lty = 1, lwd = 2, cex = 0.7, bty = "n")
