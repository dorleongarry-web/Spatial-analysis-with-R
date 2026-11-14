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
