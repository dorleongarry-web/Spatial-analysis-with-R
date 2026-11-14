# Transfer department attributes by point location, with an explicit ID check.
dept_hits <- extract(dept, mines)
stopifnot(nrow(dept_hits) == nrow(mines), !anyDuplicated(dept_hits$id.y))
dept_values <- dept_hits[match(mines$point_id, dept_hits$id.y), c("code", "nom")]
mines_joined <- cbind(mines, dept_values)
head(dept_hits)
plot(mines_joined, "nom", pch = 19, cex = 0.8,
     main = "Mine locations by department", mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
lines(dept, col = "#39473d")
unmatched <- is.na(mines_joined$nom)
if (any(unmatched)) points(mines_joined[unmatched, ],
                           col = "#68746c", pch = 1, cex = 0.8)
add_legend("bottomleft", legend = "No department match", pch = 1,
           col = "#68746c", bty = "n", cex = 0.7)
table(mines_joined$nom, useNA = "ifany")
