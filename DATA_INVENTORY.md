# Original course data inventory

Source: user-provided `Spatial_data_analysis.zip` (14 November 2026).

## Vectors (in this update)
- `dept.gpkg`: French department polygons (EPSG:2154)
- `litho.gpkg`: lithological polygons (EPSG:2154)
- `struct.gpkg`: geological structures (EPSG:2154)
- `mines.gpkg`: mine locations (EPSG:2154)
- `elevation.gpkg`: elevation vector layer (custom CRS in GeoPackage; inspect before using)
- `ne_50m_admin_0_countries.gpkg`: Natural Earth country boundaries (EPSG:4326)
- `ne_50m_graticules_10.gpkg`: graticules (EPSG:4326)
- `French_NPP.ods`: spreadsheet

## Raster data (not packaged here)
- 14 IGN BD ALTI ASCII tiles in `rasters/BDALTIV2_MNT_25M_ASC_LAMB93_IGN69_D084/`
- 24 IGN BD ALTI ASCII tiles in `rasters/BDALTIV2_MNT_25M_ASC_LAMB93_IGN69_D004/`
- 10 Sentinel-2 JP2 bands in `rasters/sentinel2/`
- `rasters/GRAY_50M_SR_OB.tif`

Download the original archive separately, extract it locally into the project's `data/` folder. Do not place 393 MB ZIP in the GitHub repository code area.

Note: the original archive does not contain explicit licensing documents; verify licenses and attribution prior to public redistribution.
