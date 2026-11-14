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
