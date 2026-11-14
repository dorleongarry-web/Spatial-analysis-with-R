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
