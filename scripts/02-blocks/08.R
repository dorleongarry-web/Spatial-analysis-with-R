earth <- rast("data/rasters/relief_mondial.tif")
plot(earth)
plot(earth, legend = FALSE, col = gray(seq(0, 1, length.out = 101)))
lines(countries, col = "darkblue")