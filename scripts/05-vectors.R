# Geospatial Analysis with R
# Vector geoprocessing
# Adapted original teaching example

library(terra)
v <- vect(system.file("ex/lux.shp", package = "terra"))
# Aggregate municipalities into larger spatial units
regions <- aggregate(v, by = "NAME_1")
par(mfrow = c(1, 2))
plot(v, main = "Original polygons")
plot(regions, main = "Aggregated regions")
cat("Original:", nrow(v), "Aggregated:", nrow(regions), "\n")
