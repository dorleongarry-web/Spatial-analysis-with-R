hits <- extract(dept[, c("code", "nom")], sites)
stopifnot(!anyDuplicated(hits$id.y))
matched <- hits[match(seq_len(nrow(sites)), hits$id.y), ]
joined <- sites
joined$department_code <- matched$code
joined$department_name <- matched$nom
stopifnot(nrow(joined) == nrow(sites),
          identical(crds(joined), crds(sites)))
print(table(joined$department_code, useNA = "ifany"))
plot(dept, col = "#f2f3ef", main = "Department attributes joined to exercise points")
cols <- c("22" = "#74a454", "35" = "#db8a5c", "56" = "#7d8bbd")
for (code in names(cols)) {
  selected <- which(joined$department_code == code)
  points(joined[selected, ], pch = 21, bg = cols[[code]], cex = 0.85)
}
points(joined[is.na(joined$department_code), ], pch = 1, col = "#778087")
add_legend("topright", cex = 0.7, legend = c("22", "35", "56", "No match"), pch = c(21, 21, 21, 1),
       pt.bg = c(cols, NA), col = c("black", "black", "black", "#778087"), bty = "n")
