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
