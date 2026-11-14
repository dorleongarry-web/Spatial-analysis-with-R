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
