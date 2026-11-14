# Module 08 — Naizin / MOSAIC

Input: the supplied 2024-TD-geostatistics teaching archive and the Agroecology geostatistics lab guides (C. Walter and N. Lemoine, 2024).

MOSAIC soil survey: 2013; Naizin catchment, Morbihan (56), Brittany, France. 198 observations in the 0–15 cm layer; triangular 300 m sampling supplemented with random sites. The dataset is retained at its actual location, not relocated to department 35.

The GeoPackage data/vectors/module-08/naizin.gpkg contains four layers copied from the supplied shapefiles, preserving geometry and attributes:
- soil: bases/Data_point/MOSAIC_point_soildata_TDCW.shp
- catchment: bases/Catchment/Catchment.shp
- fields: bases/Landuse/Landuse_2013.shp
- elevation: bases/Catchment/Mosaic_point_elevation.shp

CRS: RGF93 / Lambert-93, EPSG:2154, metres. The catchment geometry measures approximately 1207.4 ha. There are 298 elevation observations and 1272 original land-use polygons; land-use geometry is clipped for summaries.

Main variable: Carbon__g_ in the supplied soil shapefile, renamed SOC only in the analysis. According to the supplied MOSAIC variable dictionary, this is organic carbon concentration in g C/kg soil. It is neither carbon stock nor organic-matter concentration. All 198 observations are retained, including 204 g C/kg. No duplicate coordinates or non-finite SOC values were detected.

No extra public redistribution licence is asserted for the supplied teaching material. Original guides and research-data attribution remain with their authors/providers. The course adds an R implementation of their workflow.

## Analysis choices
Original-unit ordinary kriging with an exponential variogram fitted by gstat weighted least squares; bins 250 m, cutoff 2500 m; maximum 20 neighbours. IDW uses power 2 and maximum 20 neighbours. All methods use the same 25 m cell-centre prediction locations, masked to the catchment. This is an instructional analysis, not a claim that the model is optimal or scientifically validated for a final research product.

Full-sample variogram fitting and conditional LOOCV are labelled as such. A separate eastern-quarter holdout refits the variogram on training observations only. These validation designs address different prediction tasks. No test-response tuning is performed.

Kriging standard errors are conditional on covariance and mean assumptions; parameter uncertainty is omitted. Comparing IDW with kriging ±2 SE is an interpolator disagreement diagnostic, not validation or empirical 95% coverage. Field means are exact-overlap-weighted raster summaries, not measured values or block-kriging uncertainty.

The 25 m export resolution does not imply 25 m effective information. GeoTIFFs use floating-point storage, so reopening may introduce small rounding (maximum about 0.000008 g C/kg for the OK prediction).

Official resources:
https://r-spatial.github.io/gstat/reference/variogram.html
https://r-spatial.github.io/gstat/reference/fit.variogram.html
https://r-spatial.github.io/gstat/reference/krige.html
https://r-spatial.github.io/gstat/reference/krige.cv.html
https://rspatial.github.io/terra/reference/writeRaster.html
