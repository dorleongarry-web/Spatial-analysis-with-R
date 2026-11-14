library(terra)
p <- "data/vectors/module-09/naizin-case-study.gpkg"
basin <- vect(p, layer = "catchment")
soils <- vect(p, layer = "soils")
landuse <- vect(p, layer = "Landuse2013")
texture <- rast("data/rasters/module-09/texture-classes-5m.tif")
dem <- rast("data/rasters/module-09/elevation-5m.tif")
stopifnot(same.crs(basin, soils), same.crs(basin, texture), same.crs(texture, dem),
          all(res(texture) == 5), all(res(dem) == 5))
for (field in c("HYDROMORPH", "DEPTH", "GRAVEL")) print(table(as.data.frame(soils)[[field]], useNA = "always"))
plot(basin, col = "#edf0e9", main = "Kervidy–Naizin: soil mapping units", axes = TRUE)
lines(soils, col = "#6e8272", lwd = .6)
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
