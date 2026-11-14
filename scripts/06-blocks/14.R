reference <- resample(point_source, r, method = "bilinear")
all_maps <- c(rast(interpolations), reference)
common <- app(is.na(all_maps), sum) == 0
scores <- data.frame(method = names(interpolations), RMSE_m = NA_real_, MAE_m = NA_real_)
for (i in seq_along(interpolations)) {
  difference <- mask(interpolations[[i]] - reference, common, maskvalues = 0)
  scores$RMSE_m[i] <- sqrt(global(difference^2, "mean", na.rm = TRUE)[1, 1])
  scores$MAE_m[i] <- global(abs(difference), "mean", na.rm = TRUE)[1, 1]
}
print(scores)
comparison_values <- as.data.frame(rast(interpolations), na.rm = TRUE)
boxplot(comparison_values, col = c("#78a76a", "#e6a367", "#8d9ed0", "#c68ca9"),
        ylab = "Interpolated elevation (m)", main = "Interpolated elevation distributions", ylim = c(120, 280))
legend("topright", legend = names(interpolations),
       fill = c("#78a76a", "#e6a367", "#8d9ed0", "#c68ca9"), cex = 0.7, bty = "n")
