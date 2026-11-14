# Chapter 06 — Ille-et-Vilaine (35) and Morbihan (56)

## Elevation source
IGN Géoplateforme numeric WMS, layer ELEVATION.ELEVATIONGRIDCOVERAGE, advertised as “MNT BDAlti V1”, 25 m source. Retrieved 14 November 2026.
Service: https://data.geopf.fr/wms-r/wms
Metadata: https://cartes.gouv.fr/rechercher-une-donnee/dataset/IGNF_BD-ALTI
Dataset documentation: https://geobretagne.fr/geonetwork/srv/api/records/IGNF_BD-ALTI

The 20 WMS GetMap requests use image/geotiff, a single Float32 elevation band, requested CRS EPSG:2154 and 25 m cells. They are numeric values, not RGB map colours. Source tile bounding boxes, URLs and stored-file SHA256 values are recorded in rasters/BDALTI_35_56_REQUESTS.csv. The coverage rectangle is 198350–401625 E and 6703225–6857375 N in Lambert-93, with a margin around both departments. Stored input files are losslessly DEFLATE-compressed and each is smaller than 25 MB.

The server CRS label was normalised to the canonical EPSG:2154 definition, using the documented request CRS. Coordinates and values were not transformed or rescaled in that metadata correction. The 25 m grid is an extraction grid from the service and is not asserted to preserve the exact sample alignment of the original downloadable BD ALTI archive. A 25 m cell size is not a statement of 25 m vertical or horizontal accuracy. The service's source version and acquisition dates should be consulted before scientific use. EPSG:2154 describes the horizontal CRS; the ASCII header alone does not establish the vertical datum.

The separate ASCII example is a 400 × 400 cell numeric extraction on the same 25 m grid, covering 300000–310000 E, 6740000–6750000 N. It demonstrates the six-line Arc/Info ASCII header; the full coverage is stored in GeoTIFF for compactness. Metadata describes BD ALTI under the Licence Ouverte / Open Licence; retain IGN attribution and the source links.

## Department boundaries
Codes 35 and 56 selected from official IGN-derived Contours administratifs 2026, generalized 100 m, ODbL.
https://www.data.gouv.fr/datasets/contours-administratifs
Near-coast and border attribution is approximate at that generalization scale. No attempt is made to erase negative coastal elevations solely because they are below zero.

## Adaptation of the supplied Rasters 1 chapter
All seven sections are retained: Data; Merging; Masking and cropping; Visualization (colours, histograms, quantiles, shading, plotting helper); Resampling; Terrain analysis; Interpolation (IDW, nearest neighbour, moving window, linear TIN and common zoom).

Differences are explicit: departments 35/56 replace 04/84; numeric BD ALTI V1 WMS tiles replace the original BD ALTI V2 ASCII archives; one actual-elevation ASCII sample preserves the header exercise; the regional shaded display uses 250 m data for efficiency. Local terrain derivatives use 25 m data with a 100 m halo before final cropping.

The 1,600 irregular interpolation points are sampled reproducibly from the local DEM, not independent field observations. Their z values have no added artificial noise. Interpolation on a 10 m grid does not generate 10 m source detail. The supplied RMSE and MAE measure reconstruction against a bilinearly resampled version of the same source DEM, not independent survey accuracy. All method scores use a common valid-cell mask.

Quantile thresholds are never rounded for analysis: only legend labels are formatted. D8 flow directions are displayed as categories, not averaged. Local D8 results are not a validated hydrological network.
