hillshades <- list(
  Northwest = shade(slope_rad, aspect_rad, angle = 45, direction = 315, normalize = TRUE),
  Northeast = shade(slope_rad, aspect_rad, angle = 45, direction = 45, normalize = TRUE),
  Southeast = shade(slope_rad, aspect_rad, angle = 45, direction = 135, normalize = TRUE)
)
for (view in names(hillshades)) {
  plot(hillshades[[view]], col = gray.colors(100, start = 0, end = 1),
       range = c(0, 255), main = paste(view, "illumination - brightness (0-255)"))
}
print(global(hillshades$Northwest, c("min", "max"), na.rm = TRUE))
