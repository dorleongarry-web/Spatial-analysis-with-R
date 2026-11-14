centre <- project(vect(data.frame(lon = -2.20, lat = 48.02),
                       geom = c("lon", "lat"), crs = "EPSG:4326"), "EPSG:2154")
xy0 <- crds(centre)[1, ]
x0 <- round(xy0[1] / 25) * 25
y0 <- round(xy0[2] / 25) * 25
win <- 10000
ext_subset <- ext(x0 - win / 2, x0 + win / 2, y0 - win / 2, y0 + win / 2)
halo <- ext(x0 - win / 2 - 100, x0 + win / 2 + 100,
            y0 - win / 2 - 100, y0 + win / 2 + 100)
local_halo <- crop(merged_raster, halo)
dem2 <- crop(local_halo, ext_subset)
print(dem2)
plot_raster(dem_resampled, p = "Terrain", title = "35 and 56: local window shown in red")
lines(dept)
lines(ext_subset, col = "red", lwd = 2)
plot_raster(dem2, p = "Terrain", title = "10 km local DEM: elevation (m), 25 m grid")
