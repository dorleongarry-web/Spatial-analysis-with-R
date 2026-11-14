# Cropping suitability — Kervidy–Naizin, supplied 2026 exercise
# Run from repository root. install.packages("terra")
dir.create("outputs/module-09", recursive = TRUE, showWarnings = FALSE)

# 9.1 Locate the real case study and inspect its codes
library(terra)
p <- "data/vectors/module-09/naizin-case-study.gpkg"
basin <- vect(p, layer = "catchment")
soils <- vect(p, layer = "soils")
landuse <- vect(p, layer = "Landuse2013")
texture <- rast("data/rasters/module-09/texture-classes-5m.tif")
dem <- rast("data/rasters/module-09/elevation-5m.tif")
stopifnot(same.crs(basin, soils), same.crs(basin, texture), same.crs(texture, dem),
          all(res(texture) == 5), all(res(dem) == 5))
for (field in c("HYDROMORPH", "DEPTH", "GRAVEL")) print(table(as.data.frame(soils)[[field]], useNA = "always"))
plot(basin, col = "#edf0e9", main = "Kervidy–Naizin: soil mapping units", axes = TRUE)
lines(soils, col = "#6e8272", lwd = .6)
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))

# 9.2 Decode depth, hydromorphy and stoniness explicitly
d <- as.data.frame(soils)
depth_lookup <- c("1" = 1, "2" = 1, "3" = 1, "4" = 2, "5" = 3, "6" = 3)
hydro_lookup <- c("." = 1, "0" = 1, "1" = 1, "2" = 1,
                  "3" = 2, "4" = 2, "5" = 3, "6" = 3, "7" = 3, "9" = 3)
soils$depth_group <- unname(depth_lookup[d$DEPTH])
soils$hydro_group <- unname(hydro_lookup[d$HYDROMORPH])
shallow_contact <- which(d$HYDROMORPH == "3" & d$DEPTH %in% c("5", "6"))
soils$hydro_group[shallow_contact] <- 3
soils$stone_penalty <- ifelse(is.na(soils$depth_group), NA, as.integer(!is.na(d$GRAVEL) & nzchar(trimws(d$GRAVEL))))
class_matrix <- matrix(c(1, 2, 4, 3, 4, 5, 4, 5, 6), nrow = 3, byrow = TRUE)
soils$base_class <- class_matrix[cbind(soils$hydro_group, soils$depth_group)]
print(class_matrix)
print(d[d$HYDROMORPH %in% "8", c("LABEL", "HYDROMORPH", "DEPTH")])
print(data.frame(shallow_contact_units = length(shallow_contact), unresolved_code8_units = sum(d$HYDROMORPH %in% "8")))
base_display <- soils
base_display$base_label <- factor(base_display$base_class, levels = 1:6, labels = c("I", "II", "III", "IV", "V", "VI"))
plot(base_display, "base_label", main = "Depth × hydromorphy: base class", col = c("#287d4d", "#78aa59", "#ced479", "#eac169", "#d27a48", "#a83e42"))
lines(basin)

# 9.3 Prepare one common 5 m grid
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

# 9.4 Calculate slope in percent, then align it
slope_degrees <- terrain(dem, v = "slope", unit = "degrees", neighbors = 8)
slope_percent_native <- 100 * tan(slope_degrees * pi / 180)
slope_percent <- mask(resample(slope_percent_native, template, method = "bilinear"), domain)
names(slope_percent) <- "slope_percent"
stopifnot(compareGeom(slope_percent, texture))
slope_penalty <- ifel(slope_percent >= 10 & slope_percent <= 15, 1, 0)
steep <- slope_percent > 15
print(global(slope_percent, c("min", "mean", "max"), na.rm = TRUE))
plot(slope_percent, col = hcl.colors(100, "YlOrRd", rev = TRUE), main = "Slope (%) — not degrees")
lines(basin)
slope_band <- ifel(steep, 2, slope_penalty)
slope_band <- as.factor(slope_band)
levels(slope_band) <- data.frame(ID = 0:2, rule = c("<10%: no penalty", "10–15%: +1 class", ">15%: class VI"))
plot(slope_band, col = c("#dce6d5", "#dfb761", "#b34c42"), all_levels = TRUE, main = "Slope decision rule")
lines(basin)

# 9.5 Apply texture and surface-stone penalties
balanced_codes <- c(7, 10, 11, 12, 16)
texture_penalty <- ifel(is.na(texture), NA, ifel(texture %in% balanced_codes, 0, 1))
texture_display <- as.factor(texture_penalty)
levels(texture_display) <- data.frame(ID = 0:1, rule = c("Balanced: no penalty", "Unbalanced: +1 class"))
plot(texture_display, col = c("#d7e5cc", "#ca9256"), all_levels = TRUE, main = "Texture constraint")
lines(basin)
stone_display <- as.factor(stone)
levels(stone_display) <- data.frame(ID = 0:1, rule = c("No >15% indicator recorded", "Surface stones >15%: +1 class"))
plot(stone_display, col = c("#e2e7dd", "#986f59"), all_levels = TRUE, main = "Surface-stone constraint")
lines(basin)
print(freq(texture_penalty))
print(freq(stone))

# 9.6 Combine the rules and preserve unresolved zones
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

# 9.7 Quantify areas and overlapping constraints
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

# 9.8 Cross suitability with actual land use
landuse_names <- c(A = "Oilseed crops", C = "Cereals", E = "Grassland", F = "Orchard", J = "Fallow",
                   L = "Vegetables", M = "Maize", W = "Woodland", X = "Artificial surfaces", Z = "Water", O = "Unknown")
landuse$use_id <- match(landuse$TYPE, names(landuse_names))
use_grid <- mask(rasterize(landuse, template, field = "use_id"), domain)
use_grid <- ifel(is.na(use_grid) & !is.na(domain), length(landuse_names) + 1, use_grid)
use_labels <- c(unname(landuse_names), "No land-use polygon/code")
combined <- class_numeric * 100 + use_grid
cross <- zonal(area_ha, combined, "sum", na.rm = TRUE)
names(cross) <- c("code", "area_ha")
cross$class <- cross$code %/% 100
cross$landuse <- use_labels[cross$code %% 100]
cross$percent_within_class <- 100 * cross$area_ha / ave(cross$area_ha, cross$class, FUN = sum)
print(cross[, c("class", "landuse", "area_ha", "percent_within_class")])
composition <- xtabs(percent_within_class ~ landuse + class, cross)
use_colours <- hcl.colors(nrow(composition), "Set 3")
par(mar = c(5, 4, 4, 12))
barplot(composition, col = use_colours, ylim = c(0, 100), xlab = "Suitability class (0 = unclassified)",
        ylab = "Land-use share within class (%)", main = "Land use within suitability classes")
legend("topright", inset = c(-.52, 0), legend = rownames(composition), fill = use_colours, bty = "n", xpd = TRUE, cex = .72)
par(mar = c(5.1, 4.1, 4.1, 2.1))
stopifnot(max(abs(colSums(composition) - 100)) < 1e-6)
write.csv(cross, "outputs/module-09/landuse-by-suitability.csv", row.names = FALSE)

# 9.9 Export the final map and document decisions
writeRaster(suitability, "outputs/module-09/cropping-suitability-5m.tif", datatype = "INT1U", overwrite = TRUE)
writeRaster(c(slope_percent, base, texture_penalty, stone), "outputs/module-09/classification-inputs-5m.tif", overwrite = TRUE)
writeVector(soils, "outputs/module-09/decoded-soil-units.gpkg", overwrite = TRUE)
reopened <- rast("outputs/module-09/cropping-suitability-5m.tif")
stopifnot(compareGeom(suitability, reopened), all(values(suitability) == values(reopened), na.rm = TRUE),
          all(is.na(values(suitability)) == is.na(values(reopened))))
writeLines(capture.output(sessionInfo()), "outputs/module-09/session-info.txt")
plot(map_classes, col = c("#c7cbd0", class_colours), all_levels = TRUE, main = "Kervidy–Naizin: cropping suitability")
lines(basin, lwd = 1.5)
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
