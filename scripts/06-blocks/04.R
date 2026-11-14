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
