dept$area_km2 <- expanse(dept, unit = "km")
print(as.data.frame(dept)[, c("code", "nom", "area_km2")])
area <- aggregate(dept)
print(nrow(area))
plot(area, col = "#dcebcf", main = "Dissolved study area")
lines(dept, col = "#687563", lty = 2)
add_legend("topright", cex = 0.7, legend = c("Study area", "Original department borders"),
       fill = c("#dcebcf", NA), border = c("black", NA),
       lty = c(NA, 2), col = c(NA, "#687563"), bty = "n")
