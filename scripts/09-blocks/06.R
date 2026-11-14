suitability <- ifel(steep, 6, clamp(base + slope_penalty + texture_penalty + stone, upper = 6, values = TRUE))
names(suitability) <- "cropping_suitability_class"
class_colours <- c("#287d4d", "#78aa59", "#ced479", "#eac169", "#d27a48", "#a83e42")
class_labels <- c("I", "II", "III", "IV", "V", "VI")
map_classes <- as.factor(ifel(!is.na(domain), ifel(is.na(suitability), 0, suitability), NA))
levels(map_classes) <- data.frame(ID = 0:6, suitability = c("Unclassified / non-soil / missing", class_labels))
plot(map_classes, col = c("#c7cbd0", class_colours), all_levels = TRUE,
     main = "Cropping suitability: primary interpretation")
lines(basin)
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
ambiguous <- mask(rasterize(soils, template, field = as.integer(d$HYDROMORPH %in% "8")), domain)
area_ha <- cellSize(domain, unit = "ha", mask = TRUE)
scenario_summary <- data.frame()
for (h in 1:3) {
  scenario_soils <- soils
  hg <- scenario_soils$hydro_group
  hg[d$HYDROMORPH %in% "8"] <- h
  scenario_soils$base_class <- class_matrix[cbind(hg, scenario_soils$depth_group)]
  scenario_base <- mask(rasterize(scenario_soils, template, field = "base_class"), domain)
  scenario_class <- ifel(steep, 6, clamp(scenario_base + slope_penalty + texture_penalty + stone, upper = 6, values = TRUE))
  z <- zonal(ifel(ambiguous == 1, area_ha, NA), scenario_class, "sum", na.rm = TRUE)
  names(z) <- c("class", "area_ha")
  z$area_ha[is.na(z$area_ha)] <- 0
  z$assumed_hydro_group_for_code8 <- h
  scenario_summary <- rbind(scenario_summary, z)
}
print(scenario_summary)
write.csv(scenario_summary, "outputs/module-09/code8-sensitivity.csv", row.names = FALSE)
