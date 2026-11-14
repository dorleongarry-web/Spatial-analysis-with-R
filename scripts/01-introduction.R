# Module 01: Introduction to geospatial analysis with R
# Project organization and package setup
# Run this script from the root of an RStudio project (.Rproj).

# Optional: install packages once if they are not already installed.
# install.packages(c("terra", "sf"))

# Load the principal packages used throughout this course.
# Uncomment these lines once the packages are installed:
# library(terra)
# library(sf)

# Create standard directories without warning if they already exist.
folders <- c("data", "scripts", "outputs", "documents")
for (folder in folders) {
  dir.create(folder, showWarnings = FALSE)
}

# Keep reusable R functions in their own directory.
dir.create("scripts/functions", recursive = TRUE, showWarnings = FALSE)

# Check the project working directory and folder contents.
print(getwd())
print(list.files())

# Example of a project-relative path to an input dataset.
# Do not run the next line until you have the indicated file.
# countries <- terra::vect("data/countries.gpkg")

# All derived files should be written to outputs/, not data/.
# Example (only once the 'countries' object exists):
# terra::writeVector(countries, "outputs/countries_copy.gpkg", overwrite = TRUE)
