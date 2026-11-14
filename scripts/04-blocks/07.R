# Assign the geographic metadata that belongs to this requested image.
ext(tile) <- ext_map
crs(tile) <- "EPSG:2154"
res(tile)
# RGB/RGBA and grayscale WMS images require different display methods.
show_wms <- function(image, label) {
  if (nlyr(image) >= 3) {
    alpha_band <- if (nlyr(image) == 4) 4 else NULL
    plotRGB(image, a = alpha_band, axes = TRUE, mar = c(3, 4, 3, 1),
            main = label, smooth = FALSE)
  } else {
    gray_image <- image[[1]]
    if (nlyr(image) == 2) gray_image[image[[2]] == 0] <- NA
    plot(gray_image, col = gray(seq(0, 1, length.out = 256)),
         range = c(0, 255), legend = FALSE, main = label)
  }
}
show_wms(tile, "SHOM: Litto3D map image")
