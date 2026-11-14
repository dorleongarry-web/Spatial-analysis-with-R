# Module 1: Introduction — real course vector data
# Run from the root of your RStudio project.
# Data are taken from the course dataset provided separately.

if (!requireNamespace("terra", quietly = TRUE)) {
  stop("Install terra first: install.packages('terra')")
}
library(terra)

# Load country boundaries (Natural Earth, 1:50m)
countries <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")

# Examine dimensions, attributes, extent and CRS
print(countries)
print(crs(countries, proj = TRUE))
print(ext(countries))
print(head(as.data.frame(countries)))

# Draw a basic world map
plot(countries, col = "beige", main = "Countries — Natural Earth")

# Work with France department polygons (Lambert-93)
dept <- vect("data/vectors/dept.gpkg")
print(crs(dept, proj = TRUE))
plot(dept, main = "French departments")

# Store a figure as an output, leaving source files unchanged
dir.create("outputs", showWarnings = FALSE)
png("outputs/countries.png", width = 1200, height = 650)
plot(countries, col = "beige", main = "Countries — Natural Earth")
dev.off()
