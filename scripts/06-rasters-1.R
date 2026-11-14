# Chapter 06 adapted to Ille-et-Vilaine (35) and Morbihan (56)
# Run from repository root. Inputs: numeric IGN BD ALTI 25 m extraction tiles.

# 6.1 Data: departments 35 and 56 and an ASCII header
library(terra)
terraOptions(memfrac = 0.25)
dept <- vect("data/vectors/departments-35-56.gpkg")
stopifnot(setequal(dept$code, c("35", "56")), same.crs(dept, "EPSG:2154"))
ascii_file <- "data/rasters/bdalti-35-56-ascii-example.asc"
print(readLines(ascii_file, n = 6))
sample_tile <- rast(ascii_file)
crs(sample_tile) <- "EPSG:2154"
print(sample_tile)
print(as.data.frame(dept)[, c("code", "nom")])
plot(sample_tile, col = hcl.colors(60, "Terrain"), main = "ASCII example: elevation (m)")

# 6.2 Merging: collect tiles, build a collection and mosaic
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

# 6.3 Masking, cropping and trimming
dem <- mask(merged_raster, dept, filename = "outputs/module-06/work/masked25.tif", overwrite = TRUE)
dem <- trim(dem)
dept56 <- dept[dept$code == "56", ]
masks <- list(
  Mask = mask(merged_raster, dept56),
  Crop = crop(merged_raster, dept56),
  Mask_and_trim = trim(mask(merged_raster, dept56))
)
dem56 <- masks$Mask_and_trim
height_range <- as.numeric(global(dem, c("min", "max"), na.rm = TRUE)[1, ])
print(data.frame(operation = names(masks), cells = sapply(masks, ncell)))
for (operation in names(masks)) {
  plot(masks[[operation]], col = hcl.colors(60, "Terrain"), range = height_range,
       main = paste(operation, "- elevation (m)"))
  lines(dept56, col = "black", lwd = 1)
}

# 6.4.1 Colours: relate the map to its elevation distribution
z56 <- values(dem56, mat = FALSE)
z56 <- z56[is.finite(z56)]
linear_breaks <- seq(min(z56), max(z56), length.out = 21)
palette <- hcl.colors(20, "Spectral")
plot(dem56, col = palette, main = "Morbihan: linear elevation palette (m)")
lines(dept56)
hist(z56, breaks = linear_breaks, col = palette, xlab = "Elevation (m)",
     ylab = "Number of cells", main = "Morbihan elevation: equal-width bins")
print(quantile(z56, probs = c(0, 0.25, 0.5, 0.75, 1)))

# 6.4.1 Quantiles: compare equal-width and equal-frequency classes
qt <- quantile(z56, probs = seq(0, 1, 0.05))
quantile_breaks <- unique(as.numeric(qt))
stopifnot(length(quantile_breaks) > 2)
print(qt)
for (method in c("Equal width", "Quantiles")) {
  bk <- if (method == "Equal width") linear_breaks else quantile_breaks
  hist(z56, breaks = bk, probability = TRUE,
       col = hcl.colors(length(bk) - 1, "Spectral"),
       main = paste(method, "- elevation density"), xlab = "Elevation (m)",
       ylab = "Density (1/m)")
  abline(v = quantile_breaks, lty = 2, col = "#374b42")
}

# 6.4.1 Map the quantile-based elevation intervals
colour_table <- data.frame(from = quantile_breaks[-length(quantile_breaks)],
                           to = quantile_breaks[-1],
                           color = hcl.colors(length(quantile_breaks) - 1, "Spectral"))
print(colour_table)
plot(dem56, col = hcl.colors(20, "Spectral"), main = "Linear colour scale: elevation (m)")
lines(dept56)
class_matrix <- cbind(colour_table$from, colour_table$to, seq_len(nrow(colour_table)))
colour_classes <- classify(dem56, class_matrix, include.lowest = TRUE)
levels(colour_classes) <- data.frame(ID = seq_len(nrow(colour_table)),
    interval = sprintf("%.1f to %.1f m", colour_table$from, colour_table$to))
plot(colour_classes, col = colour_table$color, mar = c(3, 3, 3, 11),
     plg = list(cex = 0.7), main = "Quantile intervals: elevation (m)")
lines(dept56)

# 6.4.2 Shading and a reusable plotting function
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

# 6.5 Resampling: construct an aligned 250 m template
target_resolution <- 250
ext_dept <- ext(dept)
ext_resample <- ext(floor(ext_dept[1] / target_resolution) * target_resolution,
                    ceiling(ext_dept[2] / target_resolution) * target_resolution,
                    floor(ext_dept[3] / target_resolution) * target_resolution,
                    ceiling(ext_dept[4] / target_resolution) * target_resolution)
width <- as.numeric(round((ext_resample[2] - ext_resample[1]) / target_resolution))
height <- as.numeric(round((ext_resample[4] - ext_resample[3]) / target_resolution))
template250 <- rast(nrows = height, ncols = width, ext = ext_resample, crs = crs(dept))
print(template250)
coarse <- list(
  Nearest = trim(mask(resample(merged_raster, template250, method = "near"), dept)),
  Bilinear = trim(mask(resample(merged_raster, template250, method = "bilinear"), dept)),
  Mean = trim(mask(resample(merged_raster, template250, method = "average"), dept))
)
dem_resampled <- coarse$Bilinear
for (method in names(coarse)) {
  plot(coarse[[method]], col = hcl.colors(60, "Terrain"), range = height_range,
       main = paste(method, "resampling: elevation (m), 250 m"))
  lines(dept)
}

# 6.6 Locate a 10 km terrain-analysis window
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

# 6.6 Terrain: slope, aspect, flow direction, TRI and roughness
terrain_maps <- list(
  Slope = crop(terrain(local_halo, "slope", unit = "degrees"), ext_subset),
  Aspect = crop(terrain(local_halo, "aspect", unit = "degrees"), ext_subset),
  Flow_direction = crop(terrain(local_halo, "flowdir"), ext_subset),
  TRI_Riley = crop(terrain(local_halo, "TRIriley"), ext_subset),
  Roughness = crop(terrain(local_halo, "roughness"), ext_subset)
)
print(sapply(terrain_maps[c("Slope", "TRI_Riley", "Roughness")],
             function(x) global(x, "mean", na.rm = TRUE)[1, 1]))
print(freq(terrain_maps$Flow_direction))
for (property in names(terrain_maps)) {
  x <- terrain_maps[[property]]
  if (property == "Aspect") {
    x <- ifel(terrain_maps$Slope == 0, NA, x)
    plot(x, col = hsv(seq(0, 1, length.out = 61)), range = c(0, 360),
         main = "Aspect: clockwise from north (degrees)")
  } else if (property == "Flow_direction") {
    flow <- classify(x, cbind(c(0, 1, 2, 4, 8, 16, 32, 64, 128), 1:9))
    levels(flow) <- data.frame(ID = 1:9,
       direction = c("No lower neighbour", "E", "SE", "S", "SW", "W", "NW", "N", "NE"))
    plot(flow, col = hcl.colors(9, "Dark 3"), main = "D8 flow direction: categorical")
  } else {
    units <- if (property == "Slope") "degrees" else "m"
    plot_raster(x, dem2, p = "Plasma", title = paste(property, "(", units, ")"))
  }
}

# 6.7 Interpolation: construct irregular exercise points and a 10 m template
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

# 6.7 Compare IDW, nearest neighbour, moving window and linear TIN
interpolations <- list(
  IDW = interpIDW(r, elev, "z", radius = 400, power = 2, maxPoints = 12, minPoints = 3),
  Nearest = interpNear(r, elev, "z", radius = 400),
  Moving_window = rasterizeWin(elev, r, "z", win = "circle", pars = 400, fun = "mean", minPoints = 3),
  TIN = interpNear(r, elev, "z", radius = 0, interpolate = TRUE)
)
interpolation_limits <- range(elev$z)
for (method in names(interpolations)) {
  plot(interpolations[[method]], col = hcl.colors(60, "Terrain"), range = interpolation_limits,
       main = paste(method, "interpolation: elevation (m)"))
  lines(ext_zoom, lty = 2, col = "black")
}
print(sapply(interpolations, function(x) global(!is.na(x), "sum")[1, 1]))

# 6.7 Inspect a shared close-up
for (method in names(interpolations)) {
  closeup <- crop(interpolations[[method]], ext_zoom)
  plot(closeup, col = hcl.colors(60, "Terrain"), range = interpolation_limits,
       main = paste(method, "close-up: elevation (m)"))
}

# 6.7 Compare the reconstructed surfaces to their source DEM
reference <- resample(point_source, r, method = "bilinear")
all_maps <- c(rast(interpolations), reference)
common <- app(is.na(all_maps), sum) == 0
scores <- data.frame(method = names(interpolations), RMSE_m = NA_real_, MAE_m = NA_real_)
for (i in seq_along(interpolations)) {
  difference <- mask(interpolations[[i]] - reference, common, maskvalues = 0)
  scores$RMSE_m[i] <- sqrt(global(difference^2, "mean", na.rm = TRUE)[1, 1])
  scores$MAE_m[i] <- global(abs(difference), "mean", na.rm = TRUE)[1, 1]
}
print(scores)
comparison_values <- as.data.frame(rast(interpolations), na.rm = TRUE)
boxplot(comparison_values, col = c("#78a76a", "#e6a367", "#8d9ed0", "#c68ca9"),
        ylab = "Interpolated elevation (m)", main = "Interpolated elevation distributions", ylim = c(120, 280))
legend("topright", legend = names(interpolations),
       fill = c("#78a76a", "#e6a367", "#8d9ed0", "#c68ca9"), cex = 0.7, bty = "n")

# Export Export useful rasters, point data and numerical checks
dir.create("outputs/module-06/brittany", recursive = TRUE, showWarnings = FALSE)
writeRaster(dem_resampled, "outputs/module-06/brittany/dem-35-56-250m.tif", overwrite = TRUE)
writeRaster(dem2, "outputs/module-06/brittany/local-dem-25m.tif", overwrite = TRUE)
writeRaster(rast(terrain_maps), "outputs/module-06/brittany/local-terrain.tif", overwrite = TRUE)
writeRaster(rast(interpolations), "outputs/module-06/brittany/interpolations-10m-grid.tif", overwrite = TRUE)
writeVector(elev, "outputs/module-06/brittany/derived-exercise-points.gpkg", overwrite = TRUE)
write.csv(scores, "outputs/module-06/brittany/reconstruction-scores.csv", row.names = FALSE)
saved <- rast("outputs/module-06/brittany/local-dem-25m.tif")
stopifnot(compareGeom(saved, dem2))
error <- global(abs(saved - dem2), "max", na.rm = TRUE)[1, 1]
print(data.frame(max_export_difference_m = error))
stopifnot(error < 0.0001)
plot(saved, col = hcl.colors(60, "Terrain"), main = "Reopened local 25 m DEM: elevation (m)")
