# Module 04: WMS map images, georeferencing and LiDAR-derived views
# Install terra and xml2 if needed; run from the repository root.

# WMS returns styled map images; XML describes the available service.
library(terra)
library(xml2)
options(timeout = 120)
dir.create("outputs", showWarnings = FALSE)
dir.create("data/wms", recursive = TRUE, showWarnings = FALSE)
shom_url <- "https://services.data.shom.fr/INSPIRE/wms/r?"
ign_url <- "https://data.geopf.fr/wms-r?"

# Download the service description before constructing a map request.
capabilities_url <- paste0(shom_url,
  "SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities")
download.file(capabilities_url, "data/wms/shom-capabilities.xml",
              mode = "wb", quiet = TRUE)
cap <- read_xml("data/wms/shom-capabilities.xml")
xml_ns_strip(cap)
layer_names <- xml_text(xml_find_all(cap, ".//Layer/Name"))
head(layer_names)
length(layer_names)

# Verify the exact layer identifier and inherited coordinate systems.
shom_layer <- "LITTO3D_PACA_2015_PYR_3857_WMSR"
layer <- xml_find_first(cap, paste0(".//Layer[Name='", shom_layer, "']"))
xml_text(xml_find_first(layer, "Title"))
supported_crs <- xml_text(xml_find_all(layer, "./CRS | ancestor::Layer/CRS"))
formats <- xml_text(xml_find_all(cap, ".//Request/GetMap/Format"))
max_width <- as.integer(xml_text(xml_find_first(cap, ".//Service/MaxWidth")))
max_height <- as.integer(xml_text(xml_find_first(cap, ".//Service/MaxHeight")))
stopifnot(shom_layer %in% layer_names, "EPSG:2154" %in% supported_crs,
          "image/png" %in% formats)
c(max_width = max_width, max_height = max_height)

# Set a small Marseille coastal extent and align its grid to 2 m.
ext_ll <- ext(5.35, 5.37, 43.26, 43.28)
ext_initial <- project(ext_ll, from = "EPSG:4326", to = "EPSG:2154")
target_resolution <- 2
ext_map <- ext(
  floor(ext_initial[1] / target_resolution) * target_resolution,
  ceiling(ext_initial[2] / target_resolution) * target_resolution,
  floor(ext_initial[3] / target_resolution) * target_resolution,
  ceiling(ext_initial[4] / target_resolution) * target_resolution)
width <- as.integer(round((ext_map[2] - ext_map[1]) / target_resolution))
height <- as.integer(round((ext_map[4] - ext_map[3]) / target_resolution))
stopifnot(width <= max_width, height <= max_height)
data.frame(edge = c("xmin", "xmax", "ymin", "ymax"),
           initial = as.vector(ext_initial), aligned = as.vector(ext_map))
c(width = width, height = height)

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

# Verify that the response is a PNG, not an XML/HTML error page.
shom_png <- "data/wms/shom-litto3d.png"
download.file(map_url, shom_png, mode = "wb", quiet = TRUE)
png_signature <- as.raw(c(137, 80, 78, 71, 13, 10, 26, 10))
stopifnot(identical(readBin(shom_png, "raw", n = 8), png_signature))
tile <- rast(shom_png)
print(tile)

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

# Inspect IGN capabilities and select six advertised layers.
ign_cap_url <- paste0(ign_url,
  "SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities")
download.file(ign_cap_url, "data/wms/ign-capabilities.xml",
              mode = "wb", quiet = TRUE)
ign_cap <- read_xml("data/wms/ign-capabilities.xml")
xml_ns_strip(ign_cap)
ign_names <- xml_text(xml_find_all(ign_cap, ".//Layer/Name"))
ign_layers <- c(
  Orthophoto = "ORTHOIMAGERY.ORTHOPHOTOS",
  Hillshade = "ELEVATION.ELEVATIONGRIDCOVERAGE.SHADOW",
  IGN_map = "GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2",
  LiDAR_DTM = "IGNF_LIDAR-HD_MNT_ELEVATION.ELEVATIONGRIDCOVERAGE.SHADOW",
  LiDAR_DSM = "IGNF_LIDAR-HD_MNS_ELEVATION.ELEVATIONGRIDCOVERAGE.SHADOW",
  LiDAR_height = "IGNF_LIDAR-HD_MNH_ELEVATION.ELEVATIONGRIDCOVERAGE.SHADOW")
stopifnot(all(ign_layers %in% ign_names))
for (name in names(ign_layers)) {
  node <- xml_find_first(ign_cap, paste0(".//Layer[Name='", ign_layers[[name]], "']"))
  inherited <- xml_text(xml_find_all(node, "./CRS | ancestor::Layer/CRS"))
  stopifnot("EPSG:2154" %in% inherited)
}
data.frame(label = names(ign_layers), layer = unname(ign_layers))

# Use one identical grid for all six IGN renderings.
comparison_ll <- ext(6, 6.1, 43.8, 43.9)
comparison_initial <- project(comparison_ll, from = "EPSG:4326", to = "EPSG:2154")
comparison_resolution <- 10
comparison_extent <- ext(
  floor(comparison_initial[1] / comparison_resolution) * comparison_resolution,
  ceiling(comparison_initial[2] / comparison_resolution) * comparison_resolution,
  floor(comparison_initial[3] / comparison_resolution) * comparison_resolution,
  ceiling(comparison_initial[4] / comparison_resolution) * comparison_resolution)
comparison_width <- as.integer(round((comparison_extent[2] - comparison_extent[1]) / comparison_resolution))
comparison_height <- as.integer(round((comparison_extent[4] - comparison_extent[3]) / comparison_resolution))
ign_max_width <- as.integer(xml_text(xml_find_first(ign_cap, ".//Service/MaxWidth")))
ign_max_height <- as.integer(xml_text(xml_find_first(ign_cap, ".//Service/MaxHeight")))
stopifnot(comparison_width <= ign_max_width, comparison_height <= ign_max_height)
c(width = comparison_width, height = comparison_height,
  requested_metres_per_pixel = comparison_resolution)

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

# Save a georeferenced map image and the request provenance.
writeRaster(tile, "outputs/04-shom-map-image.tif",
            gdal = "COMPRESS=DEFLATE", overwrite = TRUE)
write.csv(request_log, "outputs/04-wms-requests.csv", row.names = FALSE)
file.exists("outputs/04-shom-map-image.tif")
file.exists("outputs/04-wms-requests.csv")

# Check image geometry and record the software versions.
reopened <- rast("outputs/04-shom-map-image.tif")
stopifnot(same.crs(reopened, "EPSG:2154"),
          nrow(reopened) == height, ncol(reopened) == width,
          all.equal(res(reopened), c(2, 2)) == TRUE,
          length(comparison_tiles) == 6)
res(reopened)
capture.output(sessionInfo(), file = "outputs/04-session-info.txt")
