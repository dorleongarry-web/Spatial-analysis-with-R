neighbours <- dept[dept$code != "35", ]
overlays <- list(
  Intersect = intersect(neighbours, buf),
  Erase = erase(neighbours, buf),
  Crop = crop(neighbours, buf),
  Union = union(neighbours, buf),
  Cover = cover(neighbours, buf),
  Symmetric_difference = symdif(neighbours, buf)
)
print(data.frame(operation = names(overlays),
                 features = sapply(overlays, nrow)))
view <- union(ext(dept), ext(buf)) * 1.08
for (operation in names(overlays)) {
  plot(dept, ext = view, col = "#f2f3ef", main = gsub("_", " ", operation))
  polys(overlays[[operation]], col = "#e5ad42", border = "#4f594b")
  lines(buf, col = "#2e729d", lwd = 2)
  add_legend("topright", cex = 0.7, legend = c("Output geometry", "Buffer boundary", "Context"),
         fill = c("#e5ad42", NA, "#f2f3ef"),
         border = c("#4f594b", NA, "black"),
         lty = c(NA, 1, NA), col = c(NA, "#2e729d", NA), bty = "n")
}
