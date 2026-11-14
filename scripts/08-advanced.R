# Naizin MOSAIC 2013: run from repository root
# install.packages(c("sf", "terra", "gstat"))
dir.create("outputs/module-08", recursive = TRUE, showWarnings = FALSE)

# 8.1 Read and check the real MOSAIC observations
library(sf)
library(terra)
library(gstat)
soil <- st_read("data/vectors/module-08/naizin.gpkg", layer = "soil", quiet = TRUE)
basin <- st_read("data/vectors/module-08/naizin.gpkg", layer = "catchment", quiet = TRUE)
fields <- st_read("data/vectors/module-08/naizin.gpkg", layer = "fields", quiet = TRUE)
elevation <- st_read("data/vectors/module-08/naizin.gpkg", layer = "elevation", quiet = TRUE)
soil$SOC <- soil$Carbon__g_
xy <- st_coordinates(soil)
stopifnot(st_crs(soil)$epsg == 2154, all(is.finite(soil$SOC)),
          !anyDuplicated(xy), nrow(soil) == 198)
print(summary(soil$SOC))
print(data.frame(points = nrow(soil), area_ha = as.numeric(st_area(basin))/10000))
plot(st_geometry(basin), col = "#eef2ed", main = "Naizin: soil sampling, 2013", axes = TRUE)
plot(st_geometry(soil), add = TRUE, pch = 21, bg = "#277d82", cex = .8)
legend("topright", "198 topsoil observations", pch = 21, pt.bg = "#277d82", bty = "n")

# 8.2 Inspect the distribution before modelling
par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
hist(soil$SOC, breaks = 25, col = "#55968d", main = "SOC: original units", xlab = "SOC (g C/kg)")
hist(log(soil$SOC), breaks = 20, col = "#d3a45a", main = "SOC: log distribution", xlab = "log(SOC)")
par(mfrow = c(1, 1))
boxplot(soil$SOC, horizontal = TRUE, col = "#55968d", xlab = "SOC (g C/kg)", main = "SOC: all observations retained")
legend("topright", c("Box: 25th–75th percentiles", "Line: median", "Circles: beyond 1.5 IQR whiskers"), bty = "n", cex = .85)
print(soil[order(soil$SOC, decreasing = TRUE)[1:5], c("ID_MOSAIC", "SOC")])

# 8.3 A first variogram with elevation
elev_v <- variogram(Elevation ~ 1, elevation, cutoff = 2500, width = 250)
elev_fit <- fit.variogram(elev_v, vgm(100, "Sph", 1500, 1))
print(elev_fit)
print(plot(elev_v, elev_fit, main = "Elevation: spherical variogram", xlab = "Distance (m)", ylab = "Semivariance (m²)"))
elev_dir <- variogram(Elevation ~ 1, elevation, alpha = c(0, 45, 90, 135), cutoff = 2500, width = 250)
print(plot(elev_dir, main = "Elevation: directional variograms", xlab = "Distance (m)", ylab = "Semivariance (m²)"))

# 8.4 Fit the SOC variogram
soc_v <- variogram(SOC ~ 1, soil, cutoff = 2500, width = 250)
start_var <- var(soil$SOC)
spherical <- fit.variogram(soc_v, vgm(.7 * start_var, "Sph", 800, .3 * start_var))
exponential <- fit.variogram(soc_v, vgm(.7 * start_var, "Exp", 800, .3 * start_var))
print(soc_v)
print(spherical)
print(exponential)
print(data.frame(model = c("Spherical", "Exponential"),
  weighted_SSE = c(attr(spherical, "SSErr"), attr(exponential, "SSErr")),
  singular = c(attr(spherical, "singular"), attr(exponential, "singular"))))
stopifnot(!attr(exponential, "singular"), all(exponential$psill >= 0))
model <- exponential
print(plot(soc_v, spherical, main = "SOC: spherical model", xlab = "Distance (m)", ylab = "Semivariance ((g C/kg)²)"))
print(plot(soc_v, exponential, main = "SOC: exponential model", xlab = "Distance (m)", ylab = "Semivariance ((g C/kg)²)"))

# 8.5 Diagnose prediction with leave-one-out validation
cv <- krige.cv(SOC ~ 1, soil, model = model, nfold = nrow(soil), nmax = 20)
cv$error <- cv$var1.pred - cv$observed
metrics <- data.frame(method = "OK: conditional LOOCV", n = nrow(cv),
  bias = mean(cv$error), MAE = mean(abs(cv$error)), RMSE = sqrt(mean(cv$error^2)),
  R2_predictive = 1 - sum(cv$error^2) / sum((cv$observed - mean(cv$observed))^2))
print(metrics)
print(summary(cv$zscore))
plot(cv$observed, cv$var1.pred, pch = 21, bg = "#55968d", xlab = "Observed SOC (g C/kg)",
     ylab = "Predicted SOC (g C/kg)", main = "Conditional leave-one-out diagnostic", asp = 1,
     xlim = range(c(cv$observed, cv$var1.pred)), ylim = range(c(cv$observed, cv$var1.pred)))
abline(0, 1, col = "#b9573c", lwd = 2)
legend("topleft", "1:1 agreement", col = "#b9573c", lty = 1, bty = "n")
legend("bottomright", legend = c(sprintf("RMSE = %.2f g C/kg", metrics$RMSE),
  sprintf("R² (prediction) = %.3f", metrics$R2_predictive), sprintf("n = %d", nrow(cv))), bty = "n")
hist(cv$error, breaks = 25, col = "#55968d", xlab = "Predicted − observed SOC (g C/kg)", main = "LOOCV errors")
write.csv(metrics, "outputs/module-08/loocv-metrics.csv", row.names = FALSE)

# 8.6 Keep a spatial test area apart
east <- xy[, 1] > quantile(xy[, 1], .75)
training <- soil[!east, ]
testing <- soil[east, ]
train_v <- variogram(SOC ~ 1, training, cutoff = 2500, width = 250)
train_var <- var(training$SOC)
train_model <- fit.variogram(train_v, vgm(.7 * train_var, "Exp", 800, .3 * train_var))
stopifnot(!attr(train_model, "singular"), all(train_model$psill >= 0))
test_ok <- krige(SOC ~ 1, training, testing, model = train_model, nmax = 20)
test_idw <- idw(SOC ~ 1, training, testing, idp = 2, nmax = 20)
errors <- list(OK = test_ok$var1.pred - testing$SOC, IDW = test_idw$var1.pred - testing$SOC)
spatial_metrics <- data.frame(method = names(errors), n = nrow(testing),
  bias = sapply(errors, mean), MAE = sapply(errors, function(e) mean(abs(e))),
  RMSE = sapply(errors, function(e) sqrt(mean(e^2))),
  R2_predictive = sapply(errors, function(e) 1 - sum(e^2) / sum((testing$SOC - mean(testing$SOC))^2)))
print(train_model)
print(spatial_metrics)
plot(st_geometry(basin), col = "#f0f1ed", main = "Spatial holdout: eastern quarter", axes = TRUE)
plot(st_geometry(training), add = TRUE, pch = 16, col = "#368c87")
plot(st_geometry(testing), add = TRUE, pch = 17, col = "#c77835")
legend("topright", c("Training", "Held out"), pch = c(16, 17), col = c("#368c87", "#c77835"), bty = "n")
for (method in names(errors)) {
  predicted <- testing$SOC + errors[[method]]
  limits_test <- range(c(testing$SOC, test_ok$var1.pred, test_idw$var1.pred))
  plot(testing$SOC, predicted, pch = 21, bg = "#55968d", asp = 1,
       xlim = limits_test, ylim = limits_test, xlab = "Observed SOC (g C/kg)",
       ylab = "Predicted SOC (g C/kg)", main = paste(method, "— eastern spatial holdout"))
  abline(0, 1, col = "#b9573c", lwd = 2)
  row <- spatial_metrics[spatial_metrics$method == method, ]
  legend("topleft", "1:1 agreement", col = "#b9573c", lty = 1, bty = "n")
  legend("bottomright", legend = c(sprintf("RMSE = %.2f g C/kg", row$RMSE),
    sprintf("R² (prediction) = %.3f", row$R2_predictive), sprintf("n = %d", nrow(testing))), bty = "n")
}
write.csv(spatial_metrics, "outputs/module-08/spatial-holdout-metrics.csv", row.names = FALSE)

# 8.7 Predict SOC and its standard error on a 25 m grid
grid <- rast(vect(basin), resolution = 25)
inside <- mask(init(grid, 1), vect(basin))
centres <- as.points(inside, na.rm = TRUE)
new_sites <- st_as_sf(centres)
prediction <- krige(SOC ~ 1, soil, new_sites, model = model, nmax = 20)
idw_prediction <- idw(SOC ~ 1, soil, new_sites, idp = 2, nmax = 20)
stopifnot(all(is.finite(prediction$var1.pred)), min(prediction$var1.var) >= -1e-8)
ok <- inside
se <- inside
idw_map <- inside
valid <- which(!is.na(values(inside, mat = FALSE)))
ok[valid] <- prediction$var1.pred
se[valid] <- sqrt(pmax(prediction$var1.var, 0))
idw_map[valid] <- idw_prediction$var1.pred
names(ok) <- "SOC_g_C_kg"
names(se) <- "kriging_SE_g_C_kg"
names(idw_map) <- "IDW_SOC_g_C_kg"
limits <- range(c(soil$SOC, values(ok), values(idw_map)), na.rm = TRUE)
pal <- hcl.colors(100, "YlGnBu", rev = TRUE)
plot(ok, col = pal, range = limits, main = "Ordinary kriging: SOC (g C/kg)")
lines(vect(basin))
plot(se, col = hcl.colors(100, "OrRd", rev = TRUE), main = "Kriging standard error (g C/kg)")
points(vect(soil), pch = 16, cex = .3)
lines(vect(basin))
print(global(c(ok, se), c("min", "mean", "max"), na.rm = TRUE))

# 8.8 Compare IDW and kriging consistently
plot(idw_map, col = pal, range = limits, main = "IDW (power 2): SOC (g C/kg)")
lines(vect(basin))
difference <- idw_map - ok
names(difference) <- "IDW_minus_OK_g_C_kg"
bound <- max(abs(values(difference)), na.rm = TRUE)
plot(difference, col = hcl.colors(100, "Blue-Red 3"), range = c(-bound, bound), main = "IDW − kriging (g C/kg)")
lines(vect(basin))
print(global(difference, c("mean", "sd", "min", "max"), na.rm = TRUE))
within_band <- abs(difference) <= 2 * se
print(data.frame(fraction_IDW_within_OK_plus_minus_2SE = global(within_band, "mean", na.rm = TRUE)[1, 1]))
print(global(c(ok, idw_map), c("mean", "sd"), na.rm = TRUE))

# 8.9 Summarise by field and export reusable rasters
clipped_fields <- intersect(vect(fields), vect(basin))
field_values <- extract(ok, clipped_fields, fun = mean, exact = TRUE, na.rm = TRUE)
clipped_fields$SOC_mean <- field_values[[2]]
print(summary(clipped_fields$SOC_mean))
plot(clipped_fields, "SOC_mean", col = pal, range = limits, main = "Mean predicted SOC by land-use polygon (g C/kg)")
writeVector(clipped_fields, "outputs/module-08/field-SOC-means.gpkg", overwrite = TRUE)
write.csv(as.data.frame(clipped_fields), "outputs/module-08/field-SOC-means.csv", row.names = FALSE)
writeRaster(ok, "outputs/module-08/SOC-kriging-25m.tif", overwrite = TRUE)
writeRaster(se, "outputs/module-08/SOC-kriging-SE-25m.tif", overwrite = TRUE)
writeRaster(idw_map, "outputs/module-08/SOC-IDW-25m.tif", overwrite = TRUE)
writeRaster(difference, "outputs/module-08/SOC-IDW-minus-kriging-25m.tif", overwrite = TRUE)
reopened <- rast("outputs/module-08/SOC-kriging-25m.tif")
stopifnot(compareGeom(ok, reopened))
print(max(abs(values(ok) - values(reopened)), na.rm = TRUE))
writeLines(capture.output(sessionInfo()), "outputs/module-08/session-info.txt")

# 8.10 Assemble the final map layout
par(mfrow = c(1, 3), mar = c(3, 3, 3, 2))
plot(ok, col = "#eeeeee", legend = FALSE, main = "Observed SOC (g C/kg)")
lines(vect(basin))
point_colours <- pal[findInterval(soil$SOC, seq(limits[1], limits[2], length.out = 101), all.inside = TRUE)]
points(xy, pch = 21, bg = point_colours, col = "#555555", cex = .8)
legend("bottomright", legend = c("20", "100", "200"), pch = 21,
       pt.bg = pal[c(3, 47, 98)], title = "g C/kg", bty = "n", cex = .65)
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
plot(ok, col = pal, range = limits, main = "Predicted SOC (g C/kg)")
lines(vect(basin))
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
plot(se, col = hcl.colors(100, "OrRd", rev = TRUE), main = "Kriging SE (g C/kg)")
lines(vect(basin))
sbar(1000, type = "bar", below = "1 km", labels = c("", "", ""))
par(mfrow = c(1, 1))
