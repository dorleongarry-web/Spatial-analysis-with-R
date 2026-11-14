# Retrieve, georeference and display each map on the common grid.
comparison_tiles <- list()
request_log <- data.frame()
for (label in names(ign_layers)) {
  p <- list(SERVICE = "WMS", VERSION = "1.3.0", REQUEST = "GetMap",
    LAYERS = ign_layers[[label]], STYLES = "", CRS = "EPSG:2154",
    BBOX = paste(comparison_extent[c(1, 3, 2, 4)], collapse = ","),
    WIDTH = comparison_width, HEIGHT = comparison_height, FORMAT = "image/png")
  request <- build_wms_url(ign_url, p)
  path <- paste0("data/wms/ign-", label, ".png")
  download.file(request, path, mode = "wb", quiet = TRUE)
  stopifnot(identical(readBin(path, "raw", n = 8), png_signature))
  image <- rast(path)
  ext(image) <- comparison_extent
  crs(image) <- "EPSG:2154"
  stopifnot(any(global(image, "sd", na.rm = TRUE)[, 1] > 0))
  comparison_tiles[[label]] <- image
  request_log <- rbind(request_log, data.frame(label = label,
    layer = ign_layers[[label]], url = request,
    retrieved_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)))
  show_wms(image, label)
}
