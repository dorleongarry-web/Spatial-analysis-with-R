# Compare seven global projections with the same source objects
world_crs <- c(
  Sinusoidal = "ESRI:54008", Mollweide = "ESRI:54009",
  Behrmann = "ESRI:54017", Bonne = "ESRI:54024",
  Polar_LAEA = "EPSG:6931", Eckert_II = "ESRI:54014",
  Winkel_Tripel = "ESRI:54042"
)
for (label in names(world_crs)) {
  target <- world_crs[[label]]
  w <- project(world, target)
  g <- project(graticule, target)
  b <- project(circles_ll, target)
  plot(w, col = "beige", border = "#62756d", main = label)
  lines(g, col = "#a8b3b0", lwd = 0.5)
  polys(b, col = adjustcolor("#c54e42", alpha.f = 0.55), border = NA)
}
