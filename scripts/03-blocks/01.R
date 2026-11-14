# 3.1 Read the reference system of the source data
library(terra)
dir.create("outputs", showWarnings = FALSE)
countries_wgs84 <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")
crs_original <- crs(countries_wgs84)
crs(countries_wgs84, describe = TRUE)
ext(countries_wgs84)
