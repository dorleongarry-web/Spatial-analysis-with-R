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
