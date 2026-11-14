# First: check project location and input files
source("scripts/00-check-project.R")

# Run once if needed
# install.packages(c("terra", "readODS", "RColorBrewer"))
library(terra)
library(readODS)
library(RColorBrewer)
dir.create("outputs", showWarnings = FALSE)