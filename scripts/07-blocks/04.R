b01_values <- values(sentinel_clean$B01, mat = FALSE)
b01_values <- b01_values[is.finite(b01_values)]
print(summary(b01_values))
cutoffs <- quantile(b01_values, probs = c(0.05, 0.95))
print(cutoffs)
hist(b01_values, breaks = 100, col = "#9aa8a2", xlab = "B01 surface reflectance",
     ylab = "Number of cells", main = "B01 before contrast stretch")
abline(v = cutoffs, col = "#b14532", lty = 2, lwd = 2)
legend("topright", legend = "5% and 95% quantiles", col = "#b14532", lty = 2, bty = "n")
