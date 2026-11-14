# Equal-radius ground buffers at regularly spaced locations
centres <- expand.grid(lon = seq(-150, 150, by = 60),
                       lat = seq(-60, 60, by = 20))
centres_ll <- vect(centres, geom = c("lon", "lat"), crs = "EPSG:4326")
circles_ll <- buffer(centres_ll, width = 500000)
plot(world, col = "beige", border = "#62756d",
     main = "500 km ground buffers in geographic coordinates")
lines(graticule, col = "#a8b3b0", lwd = 0.5)
polys(circles_ll, col = adjustcolor("#c54e42", alpha.f = 0.55), border = NA)
