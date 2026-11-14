# Verify the exported CRS and record the R session
reopened <- vect("outputs/03-france-l93.gpkg")
crs(reopened, describe = TRUE)
stopifnot(same.crs(reopened, "EPSG:2154"),
          all.equal(bounds_before, as.vector(ext(crs_demo))) == TRUE,
          nrow(circles_ll) == nrow(centres))
summary(area_check$ratio)
capture.output(sessionInfo(), file = "outputs/03-session-info.txt")
