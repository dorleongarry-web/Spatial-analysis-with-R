inside <- rowSums(relate(sites, dept, "intersects")) > 0
strict_inside <- rowSums(relate(sites, dept, "within")) > 0
outside <- rowSums(relate(sites, dept, "disjoint")) == nrow(dept)
print(data.frame(total = nrow(sites), intersects = sum(inside),
                 within = sum(strict_inside), outside_all = sum(outside)))
stopifnot(all(outside == !inside))
plot(dept, col = "#e8eddf", main = "Point selection: intersects the study area")
points(sites[!inside, ], pch = 1, col = "#778087", cex = 0.8)
points(sites[inside, ], pch = 21, bg = "#e5ad42", cex = 0.85)
add_legend("topright", cex = 0.7, legend = c("Selected", "Outside all departments"), pch = c(21, 1),
       pt.bg = c("#e5ad42", NA), col = c("black", "#778087"), bty = "n")
