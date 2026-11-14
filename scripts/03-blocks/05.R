# Check the ground areas before comparing map appearances
area_ground <- expanse(circles_ll, unit = "km")
summary(area_ground)
hist(area_ground, breaks = 15, col = "#8ab8a5", border = "white",
     main = "Ground areas of the 500 km buffers", xlab = "Area (km²)")
