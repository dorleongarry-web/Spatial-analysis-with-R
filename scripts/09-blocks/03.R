domain <- mask(init(texture, 1), basin, touches = FALSE)
template <- domain
texture <- mask(texture, domain)
base <- mask(rasterize(soils, template, field = "base_class"), domain)
depth_group <- mask(rasterize(soils, template, field = "depth_group"), domain)
hydro_group <- mask(rasterize(soils, template, field = "hydro_group"), domain)
stone <- mask(rasterize(soils, template, field = "stone_penalty"), domain)
print(freq(texture))
depth_display <- as.factor(depth_group)
levels(depth_display) <- data.frame(ID = 1:3, depth = c(">60 cm", "40–60 cm", "≤40 cm"))
plot(depth_display, col = c("#659765", "#d2b166", "#ad6251"), all_levels = TRUE,
     main = "Soil depth groups")
lines(basin)
hydro_display <- as.factor(hydro_group)
levels(hydro_display) <- data.frame(ID = 1:3, onset = c(">80 cm / none", "40–80 cm", "≤40 cm"))
plot(hydro_display, col = c("#e0d79c", "#76aaa8", "#346f9d"), all_levels = TRUE,
     main = "Onset of hydromorphy")
lines(basin)
