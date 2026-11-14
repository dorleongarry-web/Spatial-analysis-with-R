# Geospatial Analysis with R
# Advanced spatial analysis
# Adapted original teaching example

# A small, reproducible interpolation illustration
library(terra)
set.seed(5)
pts <- data.frame(x = runif(40), y = runif(40))
pts$z <- sin(3 * pts$x) + cos(4 * pts$y)
p <- vect(pts, geom = c("x", "y"), crs = "EPSG:3857")
plot(p, main = "Sample observations")
# Extend with gstat and spatial cross-validation for real data.
