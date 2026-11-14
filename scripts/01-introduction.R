# Geospatial Analysis with R
# Introduction
# Adapted original teaching example

# Install once, then load when you work
install.packages(c("terra", "sf"))
library(terra)
library(sf)

# Keep paths relative to your project directory
dir.create("data", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)
