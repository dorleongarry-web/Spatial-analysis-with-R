# Save a georeferenced map image and the request provenance.
writeRaster(tile, "outputs/04-shom-map-image.tif",
            gdal = "COMPRESS=DEFLATE", overwrite = TRUE)
write.csv(request_log, "outputs/04-wms-requests.csv", row.names = FALSE)
file.exists("outputs/04-shom-map-image.tif")
file.exists("outputs/04-wms-requests.csv")
