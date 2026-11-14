# Geospatial Analysis with R
# Working with spatial data
# Adapted original teaching example

library(terra)
# Built-in example data distributed with terra
v <- vect(system.file("ex/lux.shp", package = "terra"))
r <- rast(system.file("ex/elev.tif", package = "terra"))
print(v)
print(r)
crs(v)
ext(r)
plot(r)
lines(v)
dir.create("outputs", showWarnings = FALSE)
writeRaster(r, "outputs/elevation_copy.tif", overwrite = TRUE)
