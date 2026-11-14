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
