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
