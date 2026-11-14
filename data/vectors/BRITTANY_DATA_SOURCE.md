# Brittany department boundaries

Official dataset: https://www.data.gouv.fr/datasets/contours-administratifs
Download: https://contours-administratifs.s3.rbx.io.cloud.ovh.net/2026/geojson/departements-100m.geojson.gz
Edition: 2026. Generalization: 100 metres. Licence: ODbL.
Derived from IGN administrative boundaries. Selected department codes: 22, 35, 56.
The GeoJSON uses EPSG:4326; the GeoPackage uses EPSG:2154.
The full Module 05 workflow now uses these department contours. Polygon topology is repaired with terra::makeValid before analysis. The regular point grid is constructed for teaching and is not a field-observation dataset.
