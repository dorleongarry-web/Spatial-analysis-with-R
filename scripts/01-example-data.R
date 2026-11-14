# Optional sample dataset for Module 1 (illustrative, synthetic data)
# Run this script from the root of your RStudio project.
# install.packages("terra") # only if not installed
library(terra)

# Load the bundled points in WGS84 (longitude / latitude)
sites <- vect("data/vectors/sample_sites.geojson")
print(sites)
print(crs(sites))
plot(sites, main = "Illustrative sample sites")

# Compare with the attribute table distributed as CSV
sites_csv <- read.csv("data/sample_sites.csv")
print(sites_csv)

# Write a copy without modifying original input data
dir.create("outputs", showWarnings = FALSE)
writeVector(sites, "outputs/sample_sites_copy.gpkg", overwrite = TRUE)
