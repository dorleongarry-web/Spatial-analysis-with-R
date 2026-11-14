# Geospatial Analysis with R
# Raster analysis: terrain
# Adapted original teaching example

library(terra)
dem <- rast(system.file("ex/elev.tif", package = "terra"))
# Compute slope in degrees and hillshade
slope <- terrain(dem, v = "slope", unit = "degrees")
aspect <- terrain(dem, v = "aspect", unit = "radians")
shade <- shade(slope, aspect)
par(mfrow = c(1, 2))
plot(dem, main = "Elevation")
plot(shade, col = gray.colors(100), legend = FALSE,
     main = "Shaded relief")
