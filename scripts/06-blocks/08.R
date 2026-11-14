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
