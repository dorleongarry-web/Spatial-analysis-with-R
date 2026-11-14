pieces <- intersect(rivers, dept[, c("code", "nom")])
pieces$length_km <- perim(pieces) / 1000
lengths <- aggregate(pieces$length_km, by = list(department = pieces$code), FUN = sum)
names(lengths)[2] <- "selected_watercourse_km"
print(lengths)
print(data.frame(source_features = nrow(rivers), clipped_features = nrow(pieces)))
plot(dept, col = "#edf0e6", main = "Watercourses cut by department boundaries")
line_colours <- c("22" = "#48833b", "35" = "#cf692f", "56" = "#626eb3")
for (code in names(line_colours)) {
  lines(pieces[pieces$code == code, ], col = line_colours[[code]], lwd = 1.5)
}
add_legend("topright", legend = c("22", "35", "56"),
           col = line_colours, lty = 1, lwd = 2, cex = 0.7, bty = "n")
writeVector(pieces, "outputs/module-05-brittany/watercourse-pieces.gpkg", overwrite = TRUE)
write.csv(lengths, "outputs/module-05-brittany/watercourse-lengths.csv", row.names = FALSE)
reopened <- vect("outputs/module-05-brittany/watercourse-pieces.gpkg")
stopifnot(nrow(reopened) == nrow(pieces), same.crs(reopened, pieces))
stopifnot(all(pieces$length_km > 0),
          all(pieces$river_id %in% rivers$river_id),
          all(is.valid(pieces)))
