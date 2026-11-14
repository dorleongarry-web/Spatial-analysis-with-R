library(terra)
dept <- vect("data/vectors/brittany-adjacent-departments.geojson")
dept <- project(dept, "EPSG:2154")
dept <- makeValid(dept)
dept <- dept[order(dept$code), ]
stopifnot(nrow(dept) == 3, all(is.valid(dept)))
print(as.data.frame(dept)[, c("code", "nom")])
print(crs(dept, describe = TRUE))
plot(dept, "nom", col = c("#a7d38d", "#e4a07a", "#9ca9d4"),
     main = "Three adjoining Brittany departments", plg = list(cex = 0.8))
