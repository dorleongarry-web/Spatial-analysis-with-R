# Select whole line features; do not clip their geometry.
line_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(struct, dept, relation = relation)
  line_counts[i] <- sum(selected)
  show_selection(struct, selected, paste("Lines:", relation))
}
data.frame(relation = relations, selected = line_counts)
