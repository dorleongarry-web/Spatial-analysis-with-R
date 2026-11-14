# Export both a geometric overlay and a point layer enriched by location.
writeVector(overlays$Intersect, "outputs/05-lithology-departments.gpkg", overwrite = TRUE)
writeVector(mines_joined, "outputs/05-mines-with-context.gpkg", overwrite = TRUE)
write.csv(overlay_summary, "outputs/05-overlay-summary.csv", row.names = FALSE)
relation_summary <- data.frame(relation = relations, polygons = polygon_counts,
                               lines = line_counts, points = point_counts)
write.csv(relation_summary, "outputs/05-selection-counts.csv", row.names = FALSE)
write.csv(as.data.frame(mines_joined), "outputs/05-mines-with-context.csv", row.names = FALSE)
