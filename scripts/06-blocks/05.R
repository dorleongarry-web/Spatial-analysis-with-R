qt <- quantile(z56, probs = seq(0, 1, 0.05))
quantile_breaks <- unique(as.numeric(qt))
stopifnot(length(quantile_breaks) > 2)
print(qt)
for (method in c("Equal width", "Quantiles")) {
  bk <- if (method == "Equal width") linear_breaks else quantile_breaks
  hist(z56, breaks = bk, probability = TRUE,
       col = hcl.colors(length(bk) - 1, "Spectral"),
       main = paste(method, "- elevation density"), xlab = "Elevation (m)",
       ylab = "Density (1/m)")
  abline(v = quantile_breaks, lty = 2, col = "#374b42")
}
