class_numeric <- ifel(!is.na(domain), ifel(is.na(suitability), 0, suitability), NA)
class_area <- zonal(area_ha, class_numeric, "sum", na.rm = TRUE)
names(class_area) <- c("class", "area_ha")
class_area$percent_domain <- 100 * class_area$area_ha / sum(class_area$area_ha)
print(class_area)
flags <- list(hydromorphy = hydro_group > 1, depth_le_60cm = depth_group > 1,
              texture = texture_penalty == 1, stones = stone == 1, slope_ge_10pct = slope_percent >= 10)
constraint_area <- data.frame()
for (n in names(flags)) {
  f <- flags[[n]]
  a <- global(ifel(f, area_ha, 0), "sum", na.rm = TRUE)[1, 1]
  assessed <- global(ifel(!is.na(f), area_ha, 0), "sum", na.rm = TRUE)[1, 1]
  constraint_area <- rbind(constraint_area, data.frame(constraint = n, affected_ha = a, assessed_ha = assessed))
}
print(constraint_area)
stopifnot(abs(sum(class_area$area_ha) - global(area_ha, "sum", na.rm = TRUE)[1, 1]) < 1e-6)
barplot(class_area$area_ha, names.arg = c("Unclassified", class_labels)[class_area$class + 1],
        col = c("#c7cbd0", class_colours)[class_area$class + 1], ylab = "Area (ha)", main = "Area by suitability class", las = 2)
barplot(constraint_area$affected_ha, names.arg = c("Hydromorphy", "Depth ≤60", "Texture", "Stones", "Slope ≥10%"),
        col = "#94764e", ylab = "Affected area (ha)", main = "Constraints can overlap", las = 2)
write.csv(class_area, "outputs/module-09/class-areas.csv", row.names = FALSE)
write.csv(constraint_area, "outputs/module-09/constraint-areas.csv", row.names = FALSE)
