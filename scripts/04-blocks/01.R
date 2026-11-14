# WMS returns styled map images; XML describes the available service.
library(terra)
library(xml2)
options(timeout = 120)
dir.create("outputs", showWarnings = FALSE)
dir.create("data/wms", recursive = TRUE, showWarnings = FALSE)
shom_url <- "https://services.data.shom.fr/INSPIRE/wms/r?"
ign_url <- "https://data.geopf.fr/wms-r?"
