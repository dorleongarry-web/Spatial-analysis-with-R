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
