# Check image geometry and record the software versions.
reopened <- rast("outputs/04-shom-map-image.tif")
stopifnot(same.crs(reopened, "EPSG:2154"),
          nrow(reopened) == height, ncol(reopened) == width,
          all.equal(res(reopened), c(2, 2)) == TRUE,
          length(comparison_tiles) == 6)
res(reopened)
capture.output(sessionInfo(), file = "outputs/04-session-info.txt")
