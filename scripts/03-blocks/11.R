# Export the projected vector and the diagnostic table
france_l93 <- project(france, "EPSG:2154")
writeVector(france_l93, "outputs/03-france-l93.gpkg", overwrite = TRUE)
write.csv(area_check, "outputs/03-mercator-area-check.csv", row.names = FALSE)
file.exists("outputs/03-france-l93.gpkg")
file.exists("outputs/03-mercator-area-check.csv")
