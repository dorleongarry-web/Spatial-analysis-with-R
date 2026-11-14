tile_west <- crop(dem, ext(5.74, 6.20, 49.44, 50.20))
tile_east <- crop(dem, ext(6.10, 6.54, 49.44, 50.20))
joined_dem <- mosaic(tile_west, tile_east, fun = "mean")
stopifnot(compareGeom(joined_dem, dem))
error <- global(abs(joined_dem - dem), "max", na.rm = TRUE)
print(error)
stopifnot(error[1, 1] == 0)
for (view in c("West tile", "East tile", "Mosaic")) {
  x <- switch(view, "West tile" = tile_west, "East tile" = tile_east, "Mosaic" = joined_dem)
  plot(x, ext = ext(dem), col = hcl.colors(60, "Terrain"),
       range = c(141, 547), main = paste(view, "- elevation (m)"))
}
