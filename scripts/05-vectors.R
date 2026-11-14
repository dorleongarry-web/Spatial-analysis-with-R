# Module 05: vector geoprocessing in Brittany
# Run from the repository root. Exercise points are constructed, not field observations.

# Load and inspect the three departments
library(terra)
dept <- vect("data/vectors/brittany-adjacent-departments.geojson")
dept <- project(dept, "EPSG:2154")
dept <- makeValid(dept)
dept <- dept[order(dept$code), ]
stopifnot(nrow(dept) == 3, all(is.valid(dept)))
print(as.data.frame(dept)[, c("code", "nom")])
print(crs(dept, describe = TRUE))
plot(dept, "nom", col = c("#a7d38d", "#e4a07a", "#9ca9d4"),
     main = "Three adjoining Brittany departments", plg = list(cex = 0.8))

# Measure and dissolve polygons
dept$area_km2 <- expanse(dept, unit = "km")
print(as.data.frame(dept)[, c("code", "nom", "area_km2")])
area <- aggregate(dept)
print(nrow(area))
plot(area, col = "#dcebcf", main = "Dissolved study area")
lines(dept, col = "#687563", lty = 2)
add_legend("topright", cex = 0.7, legend = c("Study area", "Original department borders"),
       fill = c("#dcebcf", NA), border = c("black", NA),
       lty = c(NA, 2), col = c(NA, "#687563"), bty = "n")

# Construct an exercise grid
grid <- rast(ext(dept), resolution = 20000, crs = crs(dept))
xy <- xyFromCell(grid, seq_len(ncell(grid)))
sites <- vect(data.frame(site_id = seq_len(nrow(xy)), x = xy[, 1], y = xy[, 2]),
              geom = c("x", "y"), crs = crs(dept))
print(nrow(sites))
plot(dept, col = "#e8eddf", main = "Regular exercise points: 20 km spacing")
points(sites, pch = 21, bg = "#477aa4", cex = 0.75)
add_legend("topright", cex = 0.7, legend = "Exercise point (not a measurement)", pch = 21,
       pt.bg = "#477aa4", bty = "n")

# Select points using spatial predicates
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

# Create a buffer around Ille-et-Vilaine
d35 <- dept[dept$code == "35", ]
buf <- buffer(d35, width = 15000)
ring <- erase(buf, d35)
print(data.frame(department_km2 = expanse(d35, unit = "km"),
                 buffer_km2 = expanse(buf, unit = "km"),
                 outer_ring_km2 = sum(expanse(ring, unit = "km"))))
plot(buf, col = "#f5dc9d", main = "Ille-et-Vilaine and its 15 km buffer")
polys(d35, col = "#e4a07a")
lines(dept, col = "#526358", lty = 2)
add_legend("topright", cex = 0.7, legend = c("Department 35", "Buffer extension"),
       fill = c("#e4a07a", "#f5dc9d"), bty = "n")

# Compare six polygon overlays
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

# Join department attributes to points
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

# Summarise and export the results
counts <- as.data.frame(table(joined$department_code))
names(counts) <- c("department_code", "exercise_points")
print(counts)
dir.create("outputs/module-05-brittany", recursive = TRUE, showWarnings = FALSE)
writeVector(joined, "outputs/module-05-brittany/exercise-points.gpkg", overwrite = TRUE)
writeVector(area, "outputs/module-05-brittany/study-area.gpkg", overwrite = TRUE)
write.csv(counts, "outputs/module-05-brittany/point-counts.csv", row.names = FALSE)
check <- vect("outputs/module-05-brittany/exercise-points.gpkg")
stopifnot(nrow(check) == nrow(joined), same.crs(check, joined))
barplot(counts$exercise_points, names.arg = counts$department_code,
        col = c("#74a454", "#db8a5c", "#7d8bbd"),
        xlab = "Department code", ylab = "Number of exercise points",
        main = "Regular grid points inside each department")
