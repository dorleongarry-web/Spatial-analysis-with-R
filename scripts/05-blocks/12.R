# Transfer lithological attributes using the same checked point identifiers.
litho_hits <- extract(litho, mines)
stopifnot(nrow(litho_hits) == nrow(mines), !anyDuplicated(litho_hits$id.y))
litho_values <- litho_hits[match(mines$point_id, litho_hits$id.y), c("TYPE", "DESCR")]
mines_joined <- cbind(mines_joined, litho_values)
head(litho_hits)
plot(mines_joined, "TYPE", col = type_palette, pch = 19, cex = 0.8,
     main = "Mine locations by broad lithology", mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
lines(litho_groups, col = "#39473d")
table(mines_joined$TYPE, useNA = "ifany")
