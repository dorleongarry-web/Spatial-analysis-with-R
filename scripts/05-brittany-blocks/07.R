dir.create("outputs/module-05-brittany", recursive = TRUE, showWarnings = FALSE)
rivers <- vect("data/vectors/brittany-watercourses.gpkg")
stopifnot(same.crs(rivers, dept), all(is.valid(rivers)))
print(nrow(rivers))
print(head(as.data.frame(rivers)))
line_view <- union(ext(dept), ext(rivers)) * 1.08
plot(dept, ext = line_view, col = "#edf0e6", main = "BD Topage watercourses: teaching selection")
lines(rivers, col = "#277da8", lwd = 1.2)
add_legend("topright", legend = c("Watercourse", "Department"),
           lty = c(1, NA), col = c("#277da8", "black"),
           fill = c(NA, "#edf0e6"), border = c(NA, "black"), cex = 0.7, bty = "n")
