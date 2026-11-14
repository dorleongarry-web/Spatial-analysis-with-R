# Module 05: vector geometry, spatial predicates and attribute extraction
# Run from the repository root; install terra and RColorBrewer if needed.

# Select the three departments used in this course.
library(terra)
library(RColorBrewer)
dir.create("outputs", showWarnings = FALSE)
dept <- vect("data/vectors/dept.gpkg")
dept <- dept[dept$code %in% c("07", "43", "48"), ]
as.data.frame(dept)
crs(dept, describe = TRUE)

# Read polygons, lines and points; verify their spatial references.
litho <- vect("data/vectors/litho.gpkg")
struct <- vect("data/vectors/struct.gpkg")
mines <- vect("data/vectors/mines.gpkg")
mines$point_id <- seq_len(nrow(mines))
stopifnot(same.crs(dept, litho), same.crs(dept, struct), same.crs(dept, mines),
          all(is.valid(dept)), all(is.valid(litho)))
data.frame(layer = c("departments", "lithology", "structures", "mines"),
           features = c(nrow(dept), nrow(litho), nrow(struct), nrow(mines)))
head(as.data.frame(litho))
head(as.data.frame(struct))
head(as.data.frame(mines))

# Broad groups and detailed descriptions answer different questions.
type_levels <- sort(unique(litho$TYPE))
description_levels <- sort(unique(litho$DESCR))
type_palette <- brewer.pal(length(type_levels), "Set2")
description_palette <- brewer.pal(length(description_levels), "Set3")
plot(litho, "TYPE", col = type_palette, main = "Lithology: broad groups",
     mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
plot(litho, "DESCR", col = description_palette, main = "Lithology: rock descriptions",
     mar = c(3, 4, 3, 11), plg = list(cex = 0.7))
plot(dept, col = "#e2e6e2", ext = union(ext(struct), ext(dept)),
     main = "Geological structures")
lines(struct, col = "#365b8c", lwd = 1)
plot(dept, col = "#e2e6e2", ext = union(ext(mines), ext(dept)),
     main = "Mine locations in the teaching dataset")
points(mines, pch = 19, col = "#8b4d3f", cex = 0.6)

# Dissolve polygon boundaries by the broad rock-group attribute.
litho_groups <- aggregate(litho, by = "TYPE")
par(mfrow = c(1, 2))
plot(litho, "TYPE", col = type_palette, legend = FALSE,
     main = "Source polygons", mar = c(3, 3, 3, 1))
plot(litho_groups, "TYPE", col = type_palette, legend = FALSE,
     main = "Dissolved by TYPE", mar = c(3, 3, 3, 1))
par(mfrow = c(1, 1))
c(before = nrow(litho), after = nrow(litho_groups))
as.data.frame(litho_groups)

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

# Split multipart volcanic polygons into separate features.
volcanic_source <- litho[litho$DESCR == "Basalt and rhyolith", ]
volcanics <- disagg(volcanic_source)
par(mfrow = c(1, 2))
plot(volcanic_source, col = rainbow(nrow(volcanic_source)),
     main = "Multipart features", mar = c(3, 3, 3, 1))
text(volcanic_source, labels = seq_len(nrow(volcanic_source)), cex = 0.8)
plot(volcanics, col = rainbow(nrow(volcanics)),
     main = "Singlepart features", mar = c(3, 3, 3, 1))
text(volcanics, labels = seq_len(nrow(volcanics)), cex = 0.8)
par(mfrow = c(1, 1))
c(before = nrow(volcanic_source), after = nrow(volcanics))

# Every predicate is tested against ANY individual department feature.
relations <- c("intersects", "touches", "crosses", "overlaps", "within",
               "contains", "covers", "coveredby", "disjoint")
# Shared plotting helper: selected features are gold; other features are blue.
show_selection <- function(x, selected, label) {
  plot(dept, col = "#e2e6e2", ext = union(ext(x), ext(dept)),
       main = paste0(label, "\n", sum(selected), " / ", nrow(x), " selected"),
       cex.main = 0.95, mar = c(3, 4, 5, 2))
  if (geomtype(x) == "polygons") {
    polys(x, col = "#3576a5", border = "#274b61")
    if (any(selected)) polys(x[selected, ], col = "#f6c344", border = "#795c1d")
  } else if (geomtype(x) == "lines") {
    lines(x, col = "#3576a5", lwd = 1)
    if (any(selected)) lines(x[selected, ], col = "#f6c344", lwd = 2)
  } else {
    points(x, col = "#3576a5", pch = 19, cex = 0.6)
    if (any(selected)) points(x[selected, ], col = "#f6c344", pch = 19, cex = 0.8)
  }
  lines(dept, col = "#39473d", lwd = 0.7)
  add_legend("topright", legend = c("Selected", "Not selected", "Departments"),
         fill = c("#f6c344", "#3576a5", "#e2e6e2"),
         bg = "white", cex = 0.65, inset = 0.01)
}
polygon_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(volcanics, dept, relation = relation)
  polygon_counts[i] <- sum(selected)
  show_selection(volcanics, selected, paste("Polygons:", relation))
}
data.frame(relation = relations, selected = polygon_counts)

# Select whole line features; do not clip their geometry.
line_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(struct, dept, relation = relation)
  line_counts[i] <- sum(selected)
  show_selection(struct, selected, paste("Lines:", relation))
}
data.frame(relation = relations, selected = line_counts)

# Repeat the same relationship tests with zero-dimensional points.
point_counts <- numeric(length(relations))
for (i in seq_along(relations)) {
  relation <- relations[i]
  selected <- is.related(mines, dept, relation = relation)
  point_counts[i] <- sum(selected)
  show_selection(mines, selected, paste("Points:", relation))
}
data.frame(relation = relations, selected = point_counts)

# "Disjoint from any department" is not "outside all departments".
any_disjoint <- is.related(mines, dept, relation = "disjoint")
outside_all <- !is.related(mines, dept, relation = "intersects")
show_selection(mines, any_disjoint, "Disjoint from at least one department")
show_selection(mines, outside_all, "Outside every department")
c(disjoint_from_any = sum(any_disjoint), outside_all = sum(outside_all))

# Transfer department attributes by point location, with an explicit ID check.
dept_hits <- extract(dept, mines)
stopifnot(nrow(dept_hits) == nrow(mines), !anyDuplicated(dept_hits$id.y))
dept_values <- dept_hits[match(mines$point_id, dept_hits$id.y), c("code", "nom")]
mines_joined <- cbind(mines, dept_values)
head(dept_hits)
plot(mines_joined, "nom", pch = 19, cex = 0.8,
     main = "Mine locations by department", mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
lines(dept, col = "#39473d")
unmatched <- is.na(mines_joined$nom)
if (any(unmatched)) points(mines_joined[unmatched, ],
                           col = "#68746c", pch = 1, cex = 0.8)
add_legend("bottomleft", legend = "No department match", pch = 1,
           col = "#68746c", bty = "n", cex = 0.7)
table(mines_joined$nom, useNA = "ifany")

# Transfer lithological attributes using the same checked point identifiers.
litho_hits <- extract(litho, mines)
stopifnot(nrow(litho_hits) == nrow(mines), !anyDuplicated(litho_hits$id.y))
litho_values <- litho_hits[match(mines$point_id, litho_hits$id.y), c("TYPE", "DESCR")]
mines_joined <- cbind(mines_joined, litho_values)
head(litho_hits)
plot(mines_joined, "TYPE", col = type_palette, pch = 19, cex = 0.8,
     main = "Mine locations by broad lithology", mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
lines(litho_groups, col = "#39473d")
table(mines_joined$TYPE, useNA = "ifany")

# Export both a geometric overlay and a point layer enriched by location.
writeVector(overlays$Intersect, "outputs/05-lithology-departments.gpkg", overwrite = TRUE)
writeVector(mines_joined, "outputs/05-mines-with-context.gpkg", overwrite = TRUE)
write.csv(overlay_summary, "outputs/05-overlay-summary.csv", row.names = FALSE)
relation_summary <- data.frame(relation = relations, polygons = polygon_counts,
                               lines = line_counts, points = point_counts)
write.csv(relation_summary, "outputs/05-selection-counts.csv", row.names = FALSE)
write.csv(as.data.frame(mines_joined), "outputs/05-mines-with-context.csv", row.names = FALSE)

# Confirm that the attribute joins did not change point count or geometry.
reopened <- vect("outputs/05-mines-with-context.gpkg")
stopifnot(nrow(mines_joined) == nrow(mines),
          identical(geom(mines_joined), geom(mines)),
          same.crs(reopened, mines), nrow(reopened) == nrow(mines),
          nrow(litho_groups) == length(type_levels))
c(original_points = nrow(mines), joined_points = nrow(mines_joined),
  missing_department = sum(is.na(mines_joined$nom)),
  missing_lithology = sum(is.na(mines_joined$TYPE)))
capture.output(sessionInfo(), file = "outputs/05-session-info.txt")
