# Compare operations on the same ordered pair of polygon layers.
overlays <- list(
  Erase = erase(litho, dept),
  Intersect = intersect(litho, dept),
  Crop = crop(litho, dept),
  Union = union(litho, dept),
  Cover = cover(litho, dept),
  Symmetric_difference = symdif(litho, dept))
overlay_summary <- data.frame(
  operation = names(overlays),
  features = vapply(overlays, nrow, numeric(1)),
  fields = vapply(overlays, function(x) paste(names(x), collapse = ", "), character(1)))
for (label in names(overlays)) {
  result <- overlays[[label]]
  plot(result, "DESCR", col = description_palette,
       main = label, mar = c(3, 4, 3, 11), plg = list(cex = 0.65))
  lines(dept, col = "#333b37", lwd = 1.2)
  print(head(as.data.frame(result)))
}
overlay_summary
