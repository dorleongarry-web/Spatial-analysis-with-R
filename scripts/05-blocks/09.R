# Repeat the same relationship tests with zero-dimensional points.
point_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(mines, dept, relation = relation)
  point_counts[i] <- sum(selected)
  show_selection(mines, selected, paste("Points:", relation))
}
data.frame(relation = relations, selected = point_counts)
