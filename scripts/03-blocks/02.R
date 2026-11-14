# Assignment changes metadata, not coordinate values
crs_demo <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")
bounds_before <- as.vector(ext(crs_demo))
crs(crs_demo) <- ""
print(crs_demo)
crs(crs_demo) <- crs_original
crs(crs_demo, describe = TRUE)
all.equal(bounds_before, as.vector(ext(crs_demo)))
