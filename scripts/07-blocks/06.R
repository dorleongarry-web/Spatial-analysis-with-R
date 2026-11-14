stretch_options <- list(c(0, 1), c(0.02, 0.98), c(0.05, 0.95))
for (limits in stretch_options) {
  display <- stretch(sentinel_clean, minq = limits[1], maxq = limits[2], maxv = 1000,
                     maxcell = ncell(sentinel_clean), bylayer = TRUE)
  channels <- match(c("B04", "B03", "B02"), names(display))
  plotRGB(display, r = channels[1], g = channels[2], b = channels[3], scale = 1000,
          smooth = FALSE, axes = TRUE, mar = c(3, 3, 4, 1),
          main = paste("True colour: quantiles", paste(limits, collapse = " to ")))
}
