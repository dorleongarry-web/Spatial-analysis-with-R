indices <- terrain(dem, v = c("TPI", "TRI", "roughness"))
print(global(indices, c("min", "max", "mean"), na.rm = TRUE))
for (index in names(indices)) {
  x <- indices[[index]]
  if (index == "TPI") {
    limit <- global(abs(x), "max", na.rm = TRUE)[1, 1]
    plot(x, col = hcl.colors(61, "Blue-Red 3"), range = c(-limit, limit),
         main = "TPI - local relative elevation (m)")
  } else {
    plot(x, col = hcl.colors(60, "YlOrRd"), main = paste(index, "(m)"))
  }
}
