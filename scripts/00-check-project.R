# Spatial Analysis with R | Course project preflight
# Run from the project root: source("scripts/00-check-project.R")

cat("\n=== RStudio course project check ===\n")
cat("Current directory:", getwd(), "\n")

# A correctly opened course project contains these folders.
expected_dirs <- c("data", "data/vectors", "scripts", "lessons")
for (path in expected_dirs) {
  cat(if (dir.exists(path)) "[OK]      " else "[MISSING] ", path, "\n", sep = "")
}

# Check a real input used in Module 2.
vector_path <- "data/vectors/ne_50m_admin_0_countries.gpkg"
if (!file.exists(vector_path)) {
  cat("\nERROR: Missing input: ", vector_path, "\n", sep = "")
  cat("Files visible here: ", paste(list.files(), collapse = ", "), "\n", sep = "")
  cat("Open Spatial-analysis-with-R.Rproj in the folder containing data/, scripts/, and lessons/.\n")
  cat("If the ZIP extracted into nested folders, open the inner folder.\n")
  stop("Course data path check failed. Fix your project root before continuing.", call. = FALSE)
}
cat("[OK]       ", vector_path, "\n", sep = "")

# The raster preview is used later; this warning does not block vector exercises.
raster_path <- "data/rasters/GRAY_50M_SR_OB_preview.tif"
if (file.exists(raster_path)) {
  cat("[OK]       ", raster_path, "\n", sep = "")
} else {
  cat("[OPTIONAL] Raster preview not found; some Module 2 raster exercises will need it.\n")
}

cat("\nAll required checks for the first vector exercise passed.\n")
cat('Next: library(terra); countries <- vect("', vector_path, '")\n', sep = "")
