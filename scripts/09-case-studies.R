# Geospatial Analysis with R
# Case studies and practicals
# Adapted original teaching example

library(terra)
v <- vect(system.file("ex/lux.shp", package = "terra"))
# Simple illustration: geometry area depends on the coordinate system
areas_km2 <- expanse(v, unit = "km")
summary(areas_km2)
plot(v, main = "Polygon mapping exercise")
