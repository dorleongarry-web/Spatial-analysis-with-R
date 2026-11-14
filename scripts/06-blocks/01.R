library(terra)
terraOptions(memfrac = 0.25)
dept <- vect("data/vectors/departments-35-56.gpkg")
stopifnot(setequal(dept$code, c("35", "56")), same.crs(dept, "EPSG:2154"))
ascii_file <- "data/rasters/bdalti-35-56-ascii-example.asc"
print(readLines(ascii_file, n = 6))
sample_tile <- rast(ascii_file)
crs(sample_tile) <- "EPSG:2154"
print(sample_tile)
print(as.data.frame(dept)[, c("code", "nom")])
plot(sample_tile, col = hcl.colors(60, "Terrain"), main = "ASCII example: elevation (m)")
