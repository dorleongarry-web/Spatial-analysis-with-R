# Compare the original study area with three adjoining Brittany departments.
# Run from the repository root. The main Module 05 datasets remain unchanged.
library(terra)
dir.create("assets/maps", recursive = TRUE, showWarnings = FALSE)
course <- vect("data/vectors/dept.gpkg")
course <- course[course$code %in% c("07", "43", "48"), ]
course_web <- project(course, "EPSG:4326")
writeVector(course_web, "assets/maps/module-05-departments.geojson", overwrite = TRUE)
brittany <- vect("data/vectors/brittany-adjacent-departments.geojson")
stopifnot(nrow(brittany) == 3,
          all(c("22", "35", "56") %in% brittany$code),
          same.crs(brittany, "EPSG:4326"))
writeVector(brittany, "assets/maps/module-05-brittany.geojson", overwrite = TRUE)
brittany_l93 <- project(brittany, "EPSG:2154")
writeVector(brittany_l93, "data/vectors/brittany-adjacent-departments.gpkg", overwrite = TRUE)
png("assets/results/module-05/study-area.png", width = 1300, height = 1100,
    res = 140, type = "cairo")
plot(brittany_l93, "nom", col = c("#a7d38d", "#e4a07a", "#9ca9d4"),
     main = "Brittany: Cotes-d'Armor, Ille-et-Vilaine and Morbihan",
     mar = c(3, 4, 4, 11), plg = list(cex = 0.8))
dev.off()
as.data.frame(brittany)
