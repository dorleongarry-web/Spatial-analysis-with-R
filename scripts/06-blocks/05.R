slope_deg <- terrain(dem, v = "slope", unit = "degrees", neighbors = 8)
aspect_deg <- terrain(dem, v = "aspect", unit = "degrees", neighbors = 8)
slope_rad <- terrain(dem, v = "slope", unit = "radians", neighbors = 8)
aspect_rad <- terrain(dem, v = "aspect", unit = "radians", neighbors = 8)
aspect_deg <- ifel(slope_deg == 0, NA, aspect_deg)
print(global(slope_deg, c("min", "max", "mean"), na.rm = TRUE))
plot(slope_deg, col = hcl.colors(60, "YlOrRd"), main = "Slope (degrees)")
plot(aspect_deg, col = hsv(seq(0, 1, length.out = 61)), range = c(0, 360),
     main = "Aspect (degrees clockwise from north)")
