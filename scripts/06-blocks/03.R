study <- boundaries[boundaries$NAME_2 == "Clervaux", ]
rectangle <- crop(dem, study)
masked <- mask(rectangle, study)
print(data.frame(cropped_cells = ncell(rectangle),
                 cropped_values = global(!is.na(rectangle), "sum")[1, 1],
                 masked_values = global(!is.na(masked), "sum")[1, 1]))
for (view in c("Crop", "Crop and mask")) {
  x <- if (view == "Crop") rectangle else masked
  plot(x, ext = ext(study) * 1.05, col = hcl.colors(60, "Terrain"), range = c(141, 547),
       main = paste(view, "- elevation (m)"))
  lines(study, col = "black", lwd = 1.5)
}
