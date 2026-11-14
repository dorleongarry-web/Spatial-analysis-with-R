# Geospatial Analysis with R
# Multispectral remote sensing
# Adapted original teaching example

library(terra)
# Illustrative synthetic 3-band raster; no download required
set.seed(42)
rgb <- rast(nrows = 100, ncols = 100, nlyrs = 3,
            xmin = 0, xmax = 100, ymin = 0, ymax = 100)
values(rgb) <- matrix(runif(ncell(rgb) * 3), ncol = 3)
names(rgb) <- c("red", "green", "blue")
plotRGB(rgb, r = 1, g = 2, b = 3, stretch = "lin")
# For real Sentinel-2 data, replace with aligned spectral bands.
