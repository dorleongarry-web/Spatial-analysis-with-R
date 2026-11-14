for (method in names(interpolations)) {
  closeup <- crop(interpolations[[method]], ext_zoom)
  plot(closeup, col = hcl.colors(60, "Terrain"), range = interpolation_limits,
       main = paste(method, "close-up: elevation (m)"))
}
