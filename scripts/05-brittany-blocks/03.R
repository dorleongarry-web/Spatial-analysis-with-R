grid <- rast(ext(dept), resolution = 20000, crs = crs(dept))
xy <- xyFromCell(grid, seq_len(ncell(grid)))
sites <- vect(data.frame(site_id = seq_len(nrow(xy)), x = xy[, 1], y = xy[, 2]),
              geom = c("x", "y"), crs = crs(dept))
print(nrow(sites))
plot(dept, col = "#e8eddf", main = "Regular exercise points: 20 km spacing")
points(sites, pch = 21, bg = "#477aa4", cex = 0.75)
add_legend("topright", cex = 0.7, legend = "Exercise point (not a measurement)", pch = 21,
       pt.bg = "#477aa4", bty = "n")
