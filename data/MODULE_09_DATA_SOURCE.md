# Module 09 — Cropping suitability, Kervidy–Naizin

## Supplied teaching sources
- Estimation of soil cropping suitability — Guidelines 2026, supplied PDF.
- Bruckert (1989), original method, supplied scanned document.
- Glossary: Codification code 4 critères, supplied PDF.
- Legend_landuse2013_naizin.xlsx, supplied TYPE-code translations.
- data_case studies.zip, supplied vector and raster data.
The three PDF references are linked from the course under references/module-09/.

## Exact inputs
- data/vectors/module-09/naizin-case-study.gpkg is the supplied Naizin_vectors.gpkg, unchanged. The analysis uses catchment, soils and Landuse2013 layers only. Soil attributes: HYDROMORPH, DEPTH, GRAVEL; land use: TYPE. IEA2013 is not a land-use category.
- data/rasters/module-09/texture-classes-5m.tif is the supplied Texture_classes.tif, unchanged.
- data/rasters/module-09/elevation-5m.tif is the supplied RGE_Alti_5m.tif, unchanged. Retain IGN attribution for RGE ALTI; the supplied file name is not evidence of a particular elevation acquisition date.

EPSG:2154 / Lambert-93, metre units. Both source rasters have 5 m cells, but their origins differ. Slope is first derived from the larger DEM at native resolution, converted to percent, and bilinearly resampled to the texture grid. Categorical layers are rasterised by cell centre. The catchment mask also uses cell centres (touches=FALSE). Raster boundary area differs slightly from vector area.

Real location: Kervidy–Naizin, Morbihan (56), France. Do not relocate these soil data to department 35. Land-use layer: 2013. Soil and DEM acquisition dates are not established by these file names. No additional public redistribution licence is asserted for the supplied teaching materials.

## Rules and conventions
Climate is assumed uniform and optimal, as in the guide. Depth groups: >60 cm, 40–60 cm, ≤40 cm. Hydromorphy onset groups: >80 cm/none, 40–80 cm, ≤40 cm. The 3×3 base table (hydromorphy rows, depth columns) is:
1 2 4
3 4 5
4 5 6

DEPTH codes 1,2,3 -> depth group 1; 4 -> group 2; 5,6 -> group 3. The glossary assigns exact depth boundaries to the more penalising code.
HYDROMORPH .,0,1,2 -> group 1; 3,4 -> group 2; 5,6,7,9 -> group 3. Exception: code 3 on shallow soils means mottles at the parent-material contact. For DEPTH 5 or 6, onset therefore lies at ≤40 cm and group 3 is used. One supplied polygon has HYDROMORPH 3 and DEPTH 5.
Code 8 means reducing/histic conditions at depth but does not supply the onset depth needed by the guide. Five polygons remain unresolved in the primary map. A separate scenario table assigns these polygons to each possible group in turn, without treating the scenarios as observations.

Slope: <10% no penalty; 10–15% inclusive +1; >15% directly VI. This explicitly resolves exact boundary values.
Texture: balanced codes 7,10,11,12,16 (LAS, Sal, Lsa, L, Ls). All other known texture codes incur +1.
Surface stones: a nonblank GRAVEL material code indicates >15% surface stoniness under the glossary convention, +1 class. A blank means no above-threshold indicator was recorded, not measured zero stones. Where soil depth is itself missing, the stone indicator remains unassessed.
The three penalties add to the base class and the result is capped at VI. >15% slope alone can establish VI even when the base soil class is unresolved.

Unclassified cells remain NoData in the numerical TIFF. The page shows them grey with category 0 for area accounting. They include unresolved code 8, incomplete/non-soil descriptions, coverage gaps or missing texture. No silent imputation is performed.

## Area and land-use summaries
Cell areas are computed in hectares. Class areas partition the raster catchment only when unclassified area is included. Constraint areas overlap; assessed area is reported separately for every criterion.
Land-use codes: A oilseed crops; C cereals; E grassland; F orchard; J fallow; L vegetables; M maize; W woodland; X artificial surfaces; Z water; O unknown. Uncovered/unrecognised codes are a separate missing-coverage category. Proportions use the area within each suitability class as denominator and sum to 100%.

This is the generic cropping model supplied in the exercise. It does not estimate measured yields, create separate validated models for each crop, or classify ecological value. Contemporary land use does not independently validate the classification or establish causality.

Area convention: terra::cellSize computes ellipsoidal horizontal cell areas, not a slope-corrected terrain surface area. The raster total is about 1208.8 ha, whereas uncorrected Lambert-93 planar vector area is about 1207.4 ha. Projection scale and cell-boundary discretisation explain this difference; use a consistent area convention when comparing totals.
