# Select the three departments used in this course.
library(terra)
library(RColorBrewer)
dir.create("outputs", showWarnings = FALSE)
dept <- vect("data/vectors/dept.gpkg")
dept <- dept[dept$code %in% c("07", "43", "48"), ]
as.data.frame(dept)
crs(dept, describe = TRUE)
