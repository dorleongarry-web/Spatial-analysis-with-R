# Geospatial Analysis with R
# Coordinate reference systems
# Adapted original teaching example

library(terra)
v <- vect(system.file("ex/lux.shp", package = "terra"))
crs(v)
# Transform the geometry to WGS 84 longitude/latitude
v_ll <- project(v, "EPSG:4326")
print(ext(v_ll))
par(mfrow = c(1, 2))
plot(v, main = "Original CRS")
plot(v_ll, main = "WGS84")
