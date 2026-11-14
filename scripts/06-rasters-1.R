# Module 06: raster terrain analysis
# Run from the project root; requires terra.
# Example DEM and boundaries are supplied with terra.

# Read the elevation model and inspect its grid
library(terra)
dem <- rast(system.file("ex/elev.tif", package = "terra"))
boundaries <- vect(system.file("ex/lux.shp", package = "terra"))
print(dem)
print(res(dem))
print(crs(dem, describe = TRUE))
print(global(dem, c("min", "max", "mean"), na.rm = TRUE))
stopifnot(same.crs(dem, boundaries))
plot(dem, col = hcl.colors(60, "Terrain"), main = "Example elevation (m)")
lines(boundaries, col = "#40554b", lwd = 0.6)

# Build a mosaic from aligned tiles
tile_west <- crop(dem, ext(5.74, 6.20, 49.44, 50.20))
tile_east <- crop(dem, ext(6.10, 6.54, 49.44, 50.20))
joined_dem <- mosaic(tile_west, tile_east, fun = "mean")
stopifnot(compareGeom(joined_dem, dem))
error <- global(abs(joined_dem - dem), "max", na.rm = TRUE)
print(error)
stopifnot(error[1, 1] == 0)
for (view in c("West tile", "East tile", "Mosaic")) {
  x <- switch(view, "West tile" = tile_west, "East tile" = tile_east, "Mosaic" = joined_dem)
  plot(x, ext = ext(dem), col = hcl.colors(60, "Terrain"),
       range = c(141, 547), main = paste(view, "- elevation (m)"))
}

# Crop a rectangle, then mask a polygon
study <- boundaries[boundaries$NAME_2 == "Clervaux", ]
rectangle <- crop(dem, study)
masked <- mask(rectangle, study)
print(data.frame(cropped_cells = ncell(rectangle),
                 cropped_values = global(!is.na(rectangle), "sum")[1, 1],
                 masked_values = global(!is.na(masked), "sum")[1, 1]))
for (view in c("Crop", "Crop and mask")) {
  x <- if (view == "Crop") rectangle else masked
  plot(x, ext = ext(study) * 1.05, col = hcl.colors(60, "Terrain"), range = c(141, 547),
       main = paste(view, "- elevation (m)"))
  lines(study, col = "black", lwd = 1.5)
}

# Change the grid and compare resampling methods
coarse <- aggregate(dem, fact = 3, fun = "mean", na.rm = TRUE)
nearest <- resample(coarse, dem, method = "near")
bilinear <- resample(coarse, dem, method = "bilinear")
print(data.frame(grid = c("Original", "Coarse"),
                 rows = c(nrow(dem), nrow(coarse)),
                 columns = c(ncol(dem), ncol(coarse))))
for (view in c("Original", "Nearest", "Bilinear")) {
  x <- switch(view, "Original" = dem, "Nearest" = nearest, "Bilinear" = bilinear)
  plot(x, col = hcl.colors(60, "Terrain"), range = c(141, 547),
       main = paste(view, "- elevation (m)"))
}
print(global(abs(bilinear - dem), "mean", na.rm = TRUE))

# Compute slope and aspect on the original elevation grid
slope_deg <- terrain(dem, v = "slope", unit = "degrees", neighbors = 8)
aspect_deg <- terrain(dem, v = "aspect", unit = "degrees", neighbors = 8)
slope_rad <- terrain(dem, v = "slope", unit = "radians", neighbors = 8)
aspect_rad <- terrain(dem, v = "aspect", unit = "radians", neighbors = 8)
aspect_deg <- ifel(slope_deg == 0, NA, aspect_deg)
print(global(slope_deg, c("min", "max", "mean"), na.rm = TRUE))
plot(slope_deg, col = hcl.colors(60, "YlOrRd"), main = "Slope (degrees)")
plot(aspect_deg, col = hsv(seq(0, 1, length.out = 61)), range = c(0, 360),
     main = "Aspect (degrees clockwise from north)")

# Create hillshade with consistent angular units
hillshades <- list(
  Northwest = shade(slope_rad, aspect_rad, angle = 45, direction = 315, normalize = TRUE),
  Northeast = shade(slope_rad, aspect_rad, angle = 45, direction = 45, normalize = TRUE),
  Southeast = shade(slope_rad, aspect_rad, angle = 45, direction = 135, normalize = TRUE)
)
for (view in names(hillshades)) {
  plot(hillshades[[view]], col = gray.colors(100, start = 0, end = 1),
       range = c(0, 255), main = paste(view, "illumination - brightness (0-255)"))
}
print(global(hillshades$Northwest, c("min", "max"), na.rm = TRUE))

# Compare neighbourhood terrain indices
indices <- terrain(dem, v = c("TPI", "TRI", "roughness"))
print(global(indices, c("min", "max", "mean"), na.rm = TRUE))
for (index in names(indices)) {
  x <- indices[[index]]
  if (index == "TPI") {
    limit <- global(abs(x), "max", na.rm = TRUE)[1, 1]
    plot(x, col = hcl.colors(61, "Blue-Red 3"), range = c(-limit, limit),
         main = "TPI - local relative elevation (m)")
  } else {
    plot(x, col = hcl.colors(60, "YlOrRd"), main = paste(index, "(m)"))
  }
}

# Test how coarser resolution changes the slope map
coarse_slope <- terrain(coarse, v = "slope", unit = "degrees", neighbors = 8)
coarse_slope_aligned <- resample(coarse_slope, slope_deg, method = "bilinear")
slope_difference <- coarse_slope_aligned - slope_deg
limit_slope <- global(slope_deg, "max", na.rm = TRUE)[1, 1]
for (view in c("Original grid", "Coarse grid")) {
  x <- if (view == "Original grid") slope_deg else coarse_slope
  plot(x, col = hcl.colors(60, "YlOrRd"), range = c(0, limit_slope),
       main = paste(view, "- slope (degrees)"))
}
limit_change <- global(abs(slope_difference), "max", na.rm = TRUE)[1, 1]
plot(slope_difference, col = hcl.colors(61, "Blue-Red 3"),
     range = c(-limit_change, limit_change), main = "Coarse minus original slope (degrees)")
print(global(slope_difference, c("min", "max", "mean"), na.rm = TRUE))

# Summarise elevation distributions with labelled boxplots
groups <- aggregate(boundaries, by = "NAME_1")
values <- extract(dem, groups)
values$group <- groups$NAME_1[values$ID]
values <- values[!is.na(values$elevation), ]
group_names <- sort(unique(values$group))
colours <- c("#80aa68", "#e6aa74", "#8b9dce")
boxplot(elevation ~ group, data = values, col = colours,
        ylab = "Elevation (m)", xlab = "Source administrative group",
        main = "Elevation distribution by source group", ylim = c(100, 650))
legend("topright", legend = group_names, fill = colours, bty = "n", cex = 0.75)
print(aggregate(elevation ~ group, data = values, FUN = mean))
print(table(values$group))

# Export rasters and check what was saved
dir.create("outputs/module-06", recursive = TRUE, showWarnings = FALSE)
writeRaster(dem, "outputs/module-06/elevation.tif", overwrite = TRUE)
writeRaster(slope_deg, "outputs/module-06/slope-degrees.tif", overwrite = TRUE)
writeRaster(aspect_deg, "outputs/module-06/aspect-degrees.tif", overwrite = TRUE)
writeRaster(hillshades$Northwest, "outputs/module-06/hillshade-northwest.tif", overwrite = TRUE)
writeRaster(indices, "outputs/module-06/terrain-indices.tif", overwrite = TRUE)
saved <- rast("outputs/module-06/slope-degrees.tif")
stopifnot(compareGeom(saved, slope_deg))
export_error <- global(abs(saved - slope_deg), "max", na.rm = TRUE)[1, 1]
print(data.frame(max_export_difference = export_error))
stopifnot(export_error < 0.00001)
print(list.files("outputs/module-06", pattern = "tif$"))
plot(saved, col = hcl.colors(60, "YlOrRd"), main = "Reopened slope GeoTIFF (degrees)")
