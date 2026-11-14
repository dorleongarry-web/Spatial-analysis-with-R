# Module 03: coordinate reference systems and map distortion
# Run from the course repository root.

# 3.1 Read the reference system of the source data
library(terra)
dir.create("outputs", showWarnings = FALSE)
countries_wgs84 <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")
crs_original <- crs(countries_wgs84)
crs(countries_wgs84, describe = TRUE)
ext(countries_wgs84)

# Assignment changes metadata, not coordinate values
crs_demo <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")
bounds_before <- as.vector(ext(crs_demo))
crs(crs_demo) <- ""
print(crs_demo)
crs(crs_demo) <- crs_original
crs(crs_demo, describe = TRUE)
all.equal(bounds_before, as.vector(ext(crs_demo)))

# 3.2 Prepare the world and a ten-degree graticule
world_window <- ext(-180, 180, -80, 80)
world <- crop(countries_wgs84, world_window)
graticule <- vect("data/vectors/ne_50m_graticules_10.gpkg")
graticule <- crop(graticule, world_window)
plot(world, col = "beige", border = "#62756d",
     main = "Geographic coordinates: longitude / latitude")
lines(graticule, col = "#a8b3b0", lwd = 0.5)

# Equal-radius ground buffers at regularly spaced locations
centres <- expand.grid(lon = seq(-150, 150, by = 60),
                       lat = seq(-60, 60, by = 20))
centres_ll <- vect(centres, geom = c("lon", "lat"), crs = "EPSG:4326")
circles_ll <- buffer(centres_ll, width = 500000)
plot(world, col = "beige", border = "#62756d",
     main = "500 km ground buffers in geographic coordinates")
lines(graticule, col = "#a8b3b0", lwd = 0.5)
polys(circles_ll, col = adjustcolor("#c54e42", alpha.f = 0.55), border = NA)

# Check the ground areas before comparing map appearances
area_ground <- expanse(circles_ll, unit = "km")
summary(area_ground)
hist(area_ground, breaks = 15, col = "#8ab8a5", border = "white",
     main = "Ground areas of the 500 km buffers", xlab = "Area (km²)")

# Reproject every layer to the same target CRS
world_merc <- project(world, "EPSG:3857")
graticule_merc <- project(graticule, "EPSG:3857")
circles_merc <- project(circles_ll, "EPSG:3857")
plot(world_merc, col = "beige", border = "#62756d",
     main = "Web Mercator / EPSG:3857")
lines(graticule_merc, col = "#a8b3b0", lwd = 0.5)
polys(circles_merc, col = adjustcolor("#c54e42", alpha.f = 0.55), border = NA)

# Distinguish map-plane area from ground area
# transform = FALSE deliberately measures projected plane geometry here.
area_map <- expanse(circles_merc, unit = "km", transform = FALSE)
area_ratio <- area_map / area_ground
area_check <- data.frame(latitude = centres$lat,
                         ground_km2 = area_ground,
                         map_km2 = area_map, ratio = area_ratio)
head(area_check)
plot(centres$lat, area_ratio, pch = 19, col = "#147a72",
     xlab = "Latitude (degrees)", ylab = "Map-plane area / ground area",
     main = "Web Mercator: area inflation with latitude")
abline(h = 1, lty = 2, col = "#8a4a39")

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

# Export the projected vector and the diagnostic table
france_l93 <- project(france, "EPSG:2154")
writeVector(france_l93, "outputs/03-france-l93.gpkg", overwrite = TRUE)
write.csv(area_check, "outputs/03-mercator-area-check.csv", row.names = FALSE)
file.exists("outputs/03-france-l93.gpkg")
file.exists("outputs/03-mercator-area-check.csv")

# Verify the exported CRS and record the R session
reopened <- vect("outputs/03-france-l93.gpkg")
crs(reopened, describe = TRUE)
stopifnot(same.crs(reopened, "EPSG:2154"),
          all.equal(bounds_before, as.vector(ext(crs_demo))) == TRUE,
          nrow(circles_ll) == nrow(centres))
summary(area_check$ratio)
capture.output(sessionInfo(), file = "outputs/03-session-info.txt")
