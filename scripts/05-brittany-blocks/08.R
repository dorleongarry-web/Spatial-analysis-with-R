line_tests <- list(
  Intersects = rowSums(relate(rivers, dept, "intersects")) > 0,
  Crosses = rowSums(relate(rivers, dept, "crosses")) > 0,
  Within = rowSums(relate(rivers, dept, "within")) > 0,
  Disjoint_from_all = rowSums(relate(rivers, dept, "disjoint")) == nrow(dept)
)
print(data.frame(predicate = names(line_tests), selected = sapply(line_tests, sum)))
stopifnot(all(line_tests$Disjoint_from_all == !line_tests$Intersects))
for (predicate in names(line_tests)) {
  chosen <- line_tests[[predicate]]
  plot(dept, ext = line_view, col = "#edf0e6", main = gsub("_", " ", predicate))
  lines(rivers, col = "#aeb6bc", lwd = 0.8)
  if (any(chosen)) lines(rivers[chosen, ], col = "#d35831", lwd = 2)
  add_legend("topright", legend = c("Selected watercourse", "Other watercourses"),
             col = c("#d35831", "#aeb6bc"), lty = 1, lwd = c(2, 1), cex = 0.7, bty = "n")
}
