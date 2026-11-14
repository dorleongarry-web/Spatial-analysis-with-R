composites <- list(
  True_colour = c("B04", "B03", "B02"),
  Vegetation_false_colour = c("B8A", "B04", "B03"),
  SWIR_NIR_red = c("B12", "B8A", "B04"),
  SWIR_comparison = c("B12", "B11", "B02")
)
for (view in names(composites)) {
  channels <- match(composites[[view]], names(sentinel_str))
  stopifnot(!anyNA(channels))
  plotRGB(sentinel_str, r = channels[1], g = channels[2], b = channels[3], scale = 1000,
          smooth = FALSE, axes = TRUE, mar = c(3, 3, 4, 1),
          main = paste(view, "- R/G/B:", paste(composites[[view]], collapse = "/")))
}
print(composites)
