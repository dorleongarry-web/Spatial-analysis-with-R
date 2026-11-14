# Compare four projected systems using the same local objects
local_crs <- c(Lambert_93 = "EPSG:2154", Web_Mercator = "EPSG:3857",
               UTM_31N = "EPSG:32631", European_LAEA = "EPSG:3035")
for (label in names(local_crs)) {
  target <- local_crs[[label]]
  f <- project(france, target)
  b <- project(local_buffers, target)
  plot(f, col = "beige", main = label)
  polys(b, col = adjustcolor("#c54e42", alpha.f = 0.45), border = NA)
}
