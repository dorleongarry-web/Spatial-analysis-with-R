# Chapter 07: real Sentinel-2 imagery across departments 35 and 56
# Run from the repository root. Requires terra and stringr.

# 7.1 Import and organise the ten bands
library(terra)
library(stringr)
sentinel_files <- list.files("data/rasters/sentinel2-35-56", pattern = "_B[0-9A]{2}\\.tif$", full.names = TRUE)
band_names <- str_extract(basename(sentinel_files), "B[0-9A]{2}")
expected <- c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B11", "B12", "B8A")
stopifnot(length(band_names) == 10, setequal(band_names, expected), !anyDuplicated(band_names))
sentinel_files <- sentinel_files[match(expected, band_names)]
tmp <- lapply(sentinel_files, rast)
stopifnot(all(vapply(tmp, function(x) compareGeom(x, tmp[[1]], stopOnError = FALSE), logical(1))))
sentinel <- rast(tmp)
names(sentinel) <- expected
print(names(sentinel))
print(sentinel)
print(read.csv("data/MODULE_07_BANDS.csv"))
plot(sentinel$B01, col = gray.colors(100, 0, 1), main = "B01: prepared surface reflectance")

# 7.2 Locate and crop a shared region in departments 35 and 56
dept <- project(vect("data/vectors/departments-35-56.gpkg"), crs(sentinel))
X0 <- 559660
Y0 <- 5318840
DX <- 8000
DY <- 6000
ext0 <- ext(X0 - DX, X0 + DX, Y0 - DY, Y0 + DY)
plot(sentinel$B01, col = gray.colors(100, 0, 1), main = "B01 context: crop window in red")
lines(dept, col = "#dd9b32", lwd = 1.5)
lines(ext0, col = "red", lwd = 2)
sentinel_roi <- crop(sentinel, ext0)
print(sentinel_roi)
plot(sentinel_roi$B01, col = gray.colors(100, 0, 1), main = "B01 after crop: reflectance")
lines(dept, col = "#dd9b32", lwd = 1.5)

# Preparation Check scene classes before adjusting contrast
scl <- crop(rast("data/rasters/sentinel2-35-56/sentinel2_SCL.tif"), ext0)
stopifnot(compareGeom(scl, sentinel_roi))
clear <- scl %in% c(2, 4, 5, 6, 7)
sentinel_clean <- mask(sentinel_roi, clear, maskvalues = 0)
print(freq(scl))
print(data.frame(retained_cells = global(clear, "sum", na.rm = TRUE)[1, 1], total_cells = ncell(clear)))
scl_display <- scl
levels(scl_display) <- data.frame(ID = 0:11, category = c("No data", "Defective", "Dark/topographic shadow",
  "Cloud shadow", "Vegetation", "Not vegetated", "Water", "Unclassified",
  "Medium-probability cloud", "High-probability cloud", "Cirrus", "Snow/ice"))
plot(scl_display, col = c("#ffffff", "#a80000", "#424242", "#705950", "#4c9b4b", "#c8b67e",
                        "#448cbe", "#a8a8a8", "#dbdbdb", "#eeeeee", "#a7d3ee", "#df9ed4"),
     all_levels = TRUE, mar = c(3, 3, 3, 13), plg = list(cex = 0.75), main = "Sentinel-2 scene classification")
retained_display <- as.factor(clear)
levels(retained_display) <- data.frame(ID = 0:1, status = c("Excluded", "Retained"))
plot(retained_display, col = c("#bcbcbc", "#6b9d63"), all_levels = TRUE,
     main = "Pixels retained for visualisation")

# 7.3 Inspect the band histogram and numerical distribution
b01_values <- values(sentinel_clean$B01, mat = FALSE)
b01_values <- b01_values[is.finite(b01_values)]
print(summary(b01_values))
cutoffs <- quantile(b01_values, probs = c(0.05, 0.95))
print(cutoffs)
hist(b01_values, breaks = 100, col = "#9aa8a2", xlab = "B01 surface reflectance",
     ylab = "Number of cells", main = "B01 before contrast stretch")
abline(v = cutoffs, col = "#b14532", lty = 2, lwd = 2)
legend("topright", legend = "5% and 95% quantiles", col = "#b14532", lty = 2, bty = "n")

# 7.3 Stretch the contrast and compare before and after
sentinel_str <- stretch(sentinel_clean, minq = 0.05, maxq = 0.95, minv = 0, maxv = 1000,
                        maxcell = ncell(sentinel_clean), bylayer = TRUE)
print(global(sentinel_str, c("min", "max"), na.rm = TRUE))
plot(sentinel_clean$B01, col = gray.colors(100, 0, 1), main = "Before stretch: B01 reflectance")
plot(sentinel_str$B01, col = gray.colors(100, 0, 1), range = c(0, 1000),
     main = "After 5–95% stretch: B01 display values")
stretched_values <- values(sentinel_str$B01, mat = FALSE)
stretched_values <- stretched_values[is.finite(stretched_values)]
hist(stretched_values, breaks = 100, col = "#6b9482", xlab = "Display value (0–1000)",
     ylab = "Number of cells", main = "B01 after contrast stretch")

# Your turn Compare different contrast cutoffs
stretch_options <- list(c(0, 1), c(0.02, 0.98), c(0.05, 0.95))
for (limits in stretch_options) {
  display <- stretch(sentinel_clean, minq = limits[1], maxq = limits[2], maxv = 1000,
                     maxcell = ncell(sentinel_clean), bylayer = TRUE)
  channels <- match(c("B04", "B03", "B02"), names(display))
  plotRGB(display, r = channels[1], g = channels[2], b = channels[3], scale = 1000,
          smooth = FALSE, axes = TRUE, mar = c(3, 3, 4, 1),
          main = paste("True colour: quantiles", paste(limits, collapse = " to ")))
}

# Your turn Explore the other spectral bands
for (band in names(sentinel_str)) {
  plot(sentinel_str[[band]], col = gray.colors(100, 0, 1), range = c(0, 1000),
       main = paste(band, "- stretched display values (0–1000)"))
}

# 7.4 Create the four composite images from the chapter
composites <- list(
  True_colour = c("B04", "B03", "B02"),
  Vegetation_false_colour = c("B8A", "B04", "B03"),
  SWIR_NIR_red = c("B12", "B8A", "B04"),
  SWIR_comparison = c("B12", "B11", "B02")
)
for (view in names(composites)) {
  channels <- match(composites[[view]], names(sentinel_str))
  stopifnot(!anyNA(channels))
  plotRGB(sentinel_str, r = channels[1], g = channels[2], b = channels[3], scale = 1000,
          smooth = FALSE, axes = TRUE, mar = c(3, 3, 4, 1),
          main = paste(view, "- R/G/B:", paste(composites[[view]], collapse = "/")))
}
print(composites)

# Export Export reflectance and display data separately
dir.create("outputs/module-07", recursive = TRUE, showWarnings = FALSE)
writeRaster(sentinel_clean, "outputs/module-07/sentinel2-reflectance-20m.tif", overwrite = TRUE)
writeRaster(sentinel_str, "outputs/module-07/sentinel2-display-0-1000.tif", overwrite = TRUE)
writeRaster(clear, "outputs/module-07/retained-pixels.tif", overwrite = TRUE)
reopened <- rast("outputs/module-07/sentinel2-reflectance-20m.tif")
stopifnot(compareGeom(reopened, sentinel_clean))
error <- global(abs(reopened - sentinel_clean), "max", na.rm = TRUE)
print(error)
stopifnot(all(error[, 1] < 0.000001))
plot(reopened$B04, col = gray.colors(100, 0, 1), main = "Reopened red band: physical reflectance")
