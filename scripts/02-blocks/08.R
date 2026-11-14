earth <- rast("data/rasters/GRAY_50M_SR_OB_preview.tif")
plot(earth)
plot(earth, legend = FALSE, col = gray(seq(0, 1, length.out = 101)))
lines(countries, col = "darkblue")