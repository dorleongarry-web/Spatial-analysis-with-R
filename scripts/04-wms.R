# Geospatial Analysis with R
# Web map services
# Adapted original teaching example

# Inspect WMS capabilities in your browser:
capabilities_url <- paste0(
  "https://services.data.shom.fr/INSPIRE/wms/r?",
  "service=WMS&request=GetCapabilities"
)
cat(capabilities_url, "\n")

# Build a request only after checking the current layer
# metadata and CRS advertised by the server.
