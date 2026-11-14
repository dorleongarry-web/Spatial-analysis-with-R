interpolations <- list(
  IDW = interpIDW(r, elev, "z", radius = 400, power = 2, maxPoints = 12, minPoints = 3),
  Nearest = interpNear(r, elev, "z", radius = 400),
  Moving_window = rasterizeWin(elev, r, "z", win = "circle", pars = 400, fun = "mean", minPoints = 3),
  TIN = interpNear(r, elev, "z", radius = 0, interpolate = TRUE)
)
interpolation_limits <- range(elev$z)
for (method in names(interpolations)) {
  plot(interpolations[[method]], col = hcl.colors(60, "Terrain"), range = interpolation_limits,
       main = paste(method, "interpolation: elevation (m)"))
  lines(ext_zoom, lty = 2, col = "black")
}
print(sapply(interpolations, function(x) global(!is.na(x), "sum")[1, 1]))
