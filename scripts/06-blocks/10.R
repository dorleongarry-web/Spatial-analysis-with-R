terrain_maps <- list(
  Slope = crop(terrain(local_halo, "slope", unit = "degrees"), ext_subset),
  Aspect = crop(terrain(local_halo, "aspect", unit = "degrees"), ext_subset),
  Flow_direction = crop(terrain(local_halo, "flowdir"), ext_subset),
  TRI_Riley = crop(terrain(local_halo, "TRIriley"), ext_subset),
  Roughness = crop(terrain(local_halo, "roughness"), ext_subset)
)
print(sapply(terrain_maps[c("Slope", "TRI_Riley", "Roughness")],
             function(x) global(x, "mean", na.rm = TRUE)[1, 1]))
print(freq(terrain_maps$Flow_direction))
for (property in names(terrain_maps)) {
  x <- terrain_maps[[property]]
  if (property == "Aspect") {
    x <- ifel(terrain_maps$Slope == 0, NA, x)
    plot(x, col = hsv(seq(0, 1, length.out = 61)), range = c(0, 360),
         main = "Aspect: clockwise from north (degrees)")
  } else if (property == "Flow_direction") {
    flow <- classify(x, cbind(c(0, 1, 2, 4, 8, 16, 32, 64, 128), 1:9))
    levels(flow) <- data.frame(ID = 1:9,
       direction = c("No lower neighbour", "E", "SE", "S", "SW", "W", "NW", "N", "NE"))
    plot(flow, col = hcl.colors(9, "Dark 3"), main = "D8 flow direction: categorical")
  } else {
    units <- if (property == "Slope") "degrees" else "m"
    plot_raster(x, dem2, p = "Plasma", title = paste(property, "(", units, ")"))
  }
}
