# BRGM printed geological map, published scale 1:50,000
# Run after scripts/04-wms.R, in the same R session.
brgm_url <- "https://mapsref.brgm.fr/wxs/referentiel/geologie?"
brgm_cap_url <- paste0(brgm_url,
  "SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities")
download.file(brgm_cap_url, "data/wms/brgm-capabilities.xml", mode = "wb")
brgm_cap <- read_xml("data/wms/brgm-capabilities.xml")
xml_ns_strip(brgm_cap)
brgm_layer <- "SCAN_GEOL50"
node <- xml_find_first(brgm_cap, paste0(".//Layer[Name='", brgm_layer, "']"))
crs_available <- xml_text(xml_find_all(node, "./CRS | ancestor::Layer/CRS"))
stopifnot("EPSG:2154" %in% crs_available)
brgm_params <- list(SERVICE = "WMS", VERSION = "1.3.0", REQUEST = "GetMap",
  LAYERS = brgm_layer, STYLES = "", CRS = "EPSG:2154",
  BBOX = paste(comparison_extent[c(1, 3, 2, 4)], collapse = ","),
  WIDTH = comparison_width, HEIGHT = comparison_height, FORMAT = "image/png")
brgm_request <- build_wms_url(brgm_url, brgm_params)
download.file(brgm_request, "data/wms/brgm-geology.png", mode = "wb")
stopifnot(identical(readBin("data/wms/brgm-geology.png", "raw", n = 8), png_signature))
brgm_image <- rast("data/wms/brgm-geology.png")
ext(brgm_image) <- comparison_extent
crs(brgm_image) <- "EPSG:2154"
show_wms(brgm_image, "BRGM geological map: 1:50,000")
