# Reproject every layer to the same target CRS
world_merc <- project(world, "EPSG:3857")
graticule_merc <- project(graticule, "EPSG:3857")
circles_merc <- project(circles_ll, "EPSG:3857")
plot(world_merc, col = "beige", border = "#62756d",
     main = "Web Mercator / EPSG:3857")
lines(graticule_merc, col = "#a8b3b0", lwd = 0.5)
polys(circles_merc, col = adjustcolor("#c54e42", alpha.f = 0.55), border = NA)
