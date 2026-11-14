# Module 02 — Basics: geospatial data analysis with R
# Data: original teaching vectors and a downsampled preview of the source raster.
# Run from the root of the Spatial-analysis-with-R project.

# Install once if needed:
# install.packages(c("terra", "readODS", "RColorBrewer"))
library(terra)
library(readODS)
library(RColorBrewer)
dir.create("outputs", showWarnings = FALSE)

# 2.1.1 — Import vectors
countries <- vect("data/vectors/ne_50m_admin_0_countries.gpkg")
plot(countries, col = "beige", main = "Natural Earth — countries")

# 2.1.2 — Metadata and attributes
print(countries)
crs(countries)
ext(countries)
country_attributes <- as.data.frame(countries)
head(country_attributes)

france <- countries[countries$adm0_a3 == "FRA", ]
plot(countries, col = "lightgray")
plot(france, col = "gold", add = TRUE)

# 2.1.3 — Attribute processing and visualization
# The original dataset uses -99 for some missing values.
countries2 <- countries[
  !is.na(countries$gdp_md_est) & countries$gdp_md_est > 0 &
    !is.na(countries$pop_est) & countries$pop_est > 0,
]
countries2$gdp_hab <- countries2$gdp_md_est * 1e6 / countries2$pop_est
par(mfrow = c(1, 2))
hist(log10(countries2$gdp_hab), main = "log10(GDP per capita)", xlab = "log10(USD per person)")
boxplot(gdp_hab ~ economy, data = as.data.frame(countries2), log = "y",
        las = 2, cex.axis = 0.6, ylab = "GDP per capita")
par(mfrow = c(1, 1))

# Qualitative palette for categories
econ_categories <- sort(unique(as.character(countries2$economy)))
econ_palette <- colorRampPalette(brewer.pal(8, "Set3"))(length(econ_categories))
plot(countries2, col = econ_palette[match(as.character(countries2$economy), econ_categories)],
     main = "Economic categories")
legend("bottomleft", legend = econ_categories, fill = econ_palette, cex = 0.55, bg = "white")

# Sequential palette for ordered GDP-per-capita classes
breaks <- c(0, 3e3, 10e3, 20e3, 40e3, Inf)
labels <- c("<3k", "3–10k", "10–20k", "20–40k", ">40k")
countries2$gdp_hab_cat <- cut(countries2$gdp_hab, breaks = breaks,
                              labels = labels, include.lowest = TRUE)
gdp_palette <- brewer.pal(5, "Greens")
plot(countries2, col = gdp_palette[as.integer(countries2$gdp_hab_cat)],
     main = "GDP per capita (USD)")
legend("bottomleft", legend = labels, fill = gdp_palette, cex = 0.8, bg = "white")

# 2.1.4 — Crop and project vector to Lambert-93
france_met_wgs84 <- crop(france, ext(-5, 8, 40, 55))
france_met_l93 <- project(france_met_wgs84, "EPSG:2154")
par(mfrow = c(1, 2))
plot(france_met_wgs84, col = "pink", main = "WGS84 (EPSG:4326)")
plot(france_met_l93, col = "lightblue", main = "Lambert-93 (EPSG:2154)")
par(mfrow = c(1, 1))

# 2.1.5 — Spreadsheet of French nuclear power plants
npp <- read_ods("data/vectors/French_NPP.ods")
print(head(npp))
npp2 <- vect(npp, geom = c("Lon", "Lat"), crs = "EPSG:4326")
plot(france_met_wgs84, col = "coral")
points(npp2, col = "gold", pch = 19)

# Extra cartographic encoding from the original course
npp2$start_cat <- cut(npp2$Operation_start,
                      breaks = c(1970, 1980, 1990, 2000, 2010),
                      labels = c("70s", "80s", "90s", "00s"))
start_palette <- brewer.pal(4, "Accent")
cat_index <- as.integer(npp2$start_cat)
plot(france_met_wgs84, col = "beige", main = "Nuclear power plants")
points(npp2, bg = start_palette[cat_index], pch = 22,
       cex = pmax(0.25, npp$Net_power_Mwe / 700))
legend("bottomleft", legend = levels(npp2$start_cat), fill = start_palette,
       cex = 0.8, bg = "white")

# 2.1.6 — Export vectors
writeVector(france_met_l93, "outputs/france_met_l93.gpkg", overwrite = TRUE)

# 2.2.1 — Raster: portable preview derived from the original Natural Earth TIFF
# In the original course PDF, the full-size raster is named GRAY_50M_SR_OB.tif.
# This preview has fewer pixels; its resolution differs from the source PDF.
earth <- rast("data/rasters/GRAY_50M_SR_OB_preview.tif")
plot(earth, main = "Earth topographic shading (preview)")
plot(earth, legend = FALSE, col = gray(seq(0, 1, length.out = 101)))
lines(countries, col = "darkblue")

# 2.2.2–2.2.3 — Raster metadata and values
print(earth)
res(earth)
ext(earth)
crs(earth)
summary(earth)
hist(earth, main = "Raster pixel values")

# 2.2.4 — Crop and mask to metropolitan France
topo_crop <- crop(earth, france_met_wgs84)
topo_mask <- mask(topo_crop, france_met_wgs84)
par(mfrow = c(1, 2))
plot(topo_crop, main = "Crop")
plot(topo_mask, main = "Crop + mask")
par(mfrow = c(1, 1))

# 2.2.5 — Export raster
writeRaster(topo_mask, "outputs/france_met_topo_mask.tif", overwrite = TRUE)

# Checks
stopifnot(file.exists("outputs/france_met_l93.gpkg"))
stopifnot(file.exists("outputs/france_met_topo_mask.tif"))
