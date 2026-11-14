# 3.2 Prepare the world and a ten-degree graticule
world_window <- ext(-180, 180, -80, 80)
world <- crop(countries_wgs84, world_window)
graticule <- vect("data/vectors/ne_50m_graticules_10.gpkg")
graticule <- crop(graticule, world_window)
plot(world, col = "beige", border = "#62756d",
     main = "Geographic coordinates: longitude / latitude")
lines(graticule, col = "#a8b3b0", lwd = 0.5)
