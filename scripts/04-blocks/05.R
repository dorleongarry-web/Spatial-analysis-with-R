# In EPSG:2154, WMS BBOX order is xmin,ymin,xmax,ymax.
params <- list(SERVICE = "WMS", VERSION = "1.3.0", REQUEST = "GetMap",
  LAYERS = shom_layer, STYLES = "", CRS = "EPSG:2154",
  BBOX = paste(ext_map[c(1, 3, 2, 4)], collapse = ","),
  WIDTH = width, HEIGHT = height, FORMAT = "image/png")
# A small helper reuses the same URL-encoding procedure for every layer.
build_wms_url <- function(base, parameters) {
  values <- vapply(parameters, as.character, character(1))
  paste0(base, paste(names(parameters), URLencode(values, reserved = TRUE),
                    sep = "=", collapse = "&"))
}
map_url <- build_wms_url(shom_url, params)
cat(map_url, "\n")
