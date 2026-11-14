# Chapter 07 — Sentinel-2 over departments 35 and 56

Contains modified Copernicus Sentinel data (2024), prepared for this teaching example.

Scene: S2B_T30UWU_20240719T111146_L2A, Sentinel-2B Level-2A, acquired 19 July 2024.
Catalogue: Earth Search, collection sentinel-2-c1-l2a.
https://earth-search.aws.element84.com/v1
Original STAC item, band metadata, source URLs and prepared-file hashes are supplied in MODULE_07_SCENE.json, MODULE_07_BANDS.csv and MODULE_07_INPUT_MANIFEST.csv.
Official product information: https://sentiwiki.copernicus.eu/web/s2-products
Processing and SCL definitions: https://sentiwiki.copernicus.eu/web/s2-processing
Data access: https://dataspace.copernicus.eu

## Area and preparation
The prepared image context covers 547660–571660 E, 5308840–5328840 N in EPSG:32630 (WGS 84 / UTM zone 30N), a 24 × 20 km rectangle around Paimpont. The central exercise crop is 551660–567660 E, 5312840–5324840 N: 16 × 12 km, 800 columns × 600 rows at 20 m. It intersects both department 35 and department 56, but does not cover their full territory.

The COG source assets were read by spatial window. Terra applied their declared scale 0.0001 and offset -0.1 on read, as checked with scoff() and actual numerical values. The prepared Float32 spectral GeoTIFFs contain physical surface reflectance with scale 1 and offset 0. Do not apply the original scale/offset a second time. No stretch or forced 0–1 clipping was applied to these input reflectance files. Minor floating-point rounding is possible on writing Float32 values.

Native 10 m B02/B03/B04 pixels were aggregated to the common 20 m grid with area averaging. B05/B06/B07/B8A/B11/B12 are aligned native-20 m inputs. Native 60 m B01 was bilinearly resampled to the common grid; its native information remains 60 m. The categorical SCL layer was prepared with nearest-neighbour. All prepared files have identical extent, dimensions, cell size and CRS.

The scene-wide cloud cover metadata is about 8.55%, but the retained local context and exercise crop contain only SCL classes 2, 4, 5, 6 and 7. The supplied mask therefore retains all 480000 crop pixels. This is a reported classification result, not proof of perfect atmospheric correction or absence of all thin haze. A September candidate was checked during source selection but is not used in the published inputs.

## Changes relative to the supplied chapter
The four original sections and their operations are retained: import and name the layers; define and crop an extent; histograms and contrast stretch; four RGB combinations. The original ten band codes are retained: B01 B02 B03 B04 B05 B06 B07 B11 B12 B8A. The local Brittany image and 19 July 2024 date replace the original Alpes-de-Haute-Provence image and date. Prepared GeoTIFFs replace JP2 for compact, directly reusable inputs. stringr::str_extract is retained for filename parsing.

Added teaching checks include explicit native-band resolution, source radiometric scaling, the SCL quality layer, full-value histogram/quantile calculations, band-name-based RGB selection, a complete gallery and separate physical-reflectance/display exports. The stretch maps each band’s 5–95% interval to display values 0–1000; all RGB displays explicitly use scale=1000. Such stretched values are not surface reflectance and must not be used as if they were physical measurements.

Department contours are IGN-derived Contours administratifs 2026, generalized 100 m, ODbL:
https://www.data.gouv.fr/datasets/contours-administratifs

## Spectral reference diagram
The NASA Landsat comparison diagram embedded in page 2 of the supplied Rasters 2 chapter is reproduced unchanged as assets/reference/sentinel2-landsat-spectral-bands.jpg (1800 × 727 pixels). It is a sourced reference illustration, separate from the 27 R-generated results. Attribution is retained on the page, with a link to the Copernicus documentation reproducing and explaining this diagram:
https://s2.pages.eopf.copernicus.eu/msi/s2msi/1.1.0/context.html#msi-spectral-bands
