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
