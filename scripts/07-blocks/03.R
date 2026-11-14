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
