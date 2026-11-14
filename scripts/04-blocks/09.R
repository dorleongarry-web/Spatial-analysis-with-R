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
