# Verify that the response is a PNG, not an XML/HTML error page.
shom_png <- "data/wms/shom-litto3d.png"
download.file(map_url, shom_png, mode = "wb", quiet = TRUE)
png_signature <- as.raw(c(137, 80, 78, 71, 13, 10, 26, 10))
stopifnot(identical(readBin(shom_png, "raw", n = 8), png_signature))
tile <- rast(shom_png)
print(tile)
