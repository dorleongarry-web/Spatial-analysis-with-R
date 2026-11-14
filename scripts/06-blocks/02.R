raster_files <- list.files("data/rasters/bdalti-35-56-25m", pattern = "\\.tif$", full.names = TRUE)
stopifnot(length(raster_files) == 20)
rasters <- lapply(raster_files, rast)
stopifnot(all(vapply(rasters, function(x) same.crs(x, dept), logical(1))))
rasters_collection <- sprc(rasters)
dir.create("outputs/module-06/work", recursive = TRUE, showWarnings = FALSE)
merged_raster <- mosaic(rasters_collection, fun = "mean",
                       filename = "outputs/module-06/work/mosaic25.tif", overwrite = TRUE,
                       wopt = list(gdal = "COMPRESS=DEFLATE"))
names(merged_raster) <- "elevation"
stopifnot(all(res(merged_raster) == 25))
print(merged_raster)
plot(merged_raster, col = hcl.colors(60, "Terrain"), main = "25 m mosaic: elevation (m)")
lines(dept, col = "white", lwd = 1.2)
