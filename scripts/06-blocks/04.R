z56 <- values(dem56, mat = FALSE)
z56 <- z56[is.finite(z56)]
linear_breaks <- seq(min(z56), max(z56), length.out = 21)
palette <- hcl.colors(20, "Spectral")
plot(dem56, col = palette, main = "Morbihan: linear elevation palette (m)")
lines(dept56)
hist(z56, breaks = linear_breaks, col = palette, xlab = "Elevation (m)",
     ylab = "Number of cells", main = "Morbihan elevation: equal-width bins")
print(quantile(z56, probs = c(0, 0.25, 0.5, 0.75, 1)))
