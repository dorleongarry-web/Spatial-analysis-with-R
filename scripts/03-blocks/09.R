# 3.3 Prepare one local study area in metropolitan France
france <- countries_wgs84[countries_wgs84$adm0_a3 == "FRA", ]
france <- crop(france, ext(-6, 10, 41, 52))
local_grid <- expand.grid(lon = seq(-2, 7, by = 3),
                          lat = seq(44, 48, by = 2))
local_pts <- vect(local_grid, geom = c("lon", "lat"), crs = "EPSG:4326")
local_buffers <- buffer(local_pts, width = 70000)
plot(france, col = "beige", main = "France: 70 km ground buffers")
polys(local_buffers, col = adjustcolor("#c54e42", alpha.f = 0.45), border = NA)
points(local_pts, pch = 16, cex = 0.5, col = "#793d37")
