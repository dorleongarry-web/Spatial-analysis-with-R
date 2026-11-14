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
