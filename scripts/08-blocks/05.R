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
