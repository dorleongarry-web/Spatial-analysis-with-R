# Every predicate is tested against ANY individual department feature.
relations <- c("intersects", "touches", "crosses", "overlaps", "within",
               "contains", "covers", "coveredby", "disjoint")
# Shared plotting helper: selected features are gold; other features are blue.
show_selection <- function(x, selected, label) {
  plot(dept, col = "#e2e6e2", ext = union(ext(x), ext(dept)),
       main = paste0(label, "\n", sum(selected), " / ", nrow(x), " selected"),
       cex.main = 0.95, mar = c(3, 4, 5, 2))
  if (geomtype(x) == "polygons") {
    polys(x, col = "#3576a5", border = "#274b61")
    if (any(selected)) polys(x[selected, ], col = "#f6c344", border = "#795c1d")
  } else if (geomtype(x) == "lines") {
    lines(x, col = "#3576a5", lwd = 1)
    if (any(selected)) lines(x[selected, ], col = "#f6c344", lwd = 2)
  } else {
    points(x, col = "#3576a5", pch = 19, cex = 0.6)
    if (any(selected)) points(x[selected, ], col = "#f6c344", pch = 19, cex = 0.8)
  }
  lines(dept, col = "#39473d", lwd = 0.7)
  add_legend("topright", legend = c("Selected", "Not selected", "Departments"),
         fill = c("#f6c344", "#3576a5", "#e2e6e2"),
         bg = "white", cex = 0.65, inset = 0.01)
}
polygon_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(volcanics, dept, relation = relation)
  polygon_counts[i] <- sum(selected)
  show_selection(volcanics, selected, paste("Polygons:", relation))
}
data.frame(relation = relations, selected = polygon_counts)
