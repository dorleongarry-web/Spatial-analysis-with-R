colour_table <- data.frame(from = quantile_breaks[-length(quantile_breaks)],
                           to = quantile_breaks[-1],
                           color = hcl.colors(length(quantile_breaks) - 1, "Spectral"))
print(colour_table)
plot(dem56, col = hcl.colors(20, "Spectral"), main = "Linear colour scale: elevation (m)")
lines(dept56)
class_matrix <- cbind(colour_table$from, colour_table$to, seq_len(nrow(colour_table)))
colour_classes <- classify(dem56, class_matrix, include.lowest = TRUE)
levels(colour_classes) <- data.frame(ID = seq_len(nrow(colour_table)),
    interval = sprintf("%.1f to %.1f m", colour_table$from, colour_table$to))
plot(colour_classes, col = colour_table$color, mar = c(3, 3, 3, 11),
     plg = list(cex = 0.7), main = "Quantile intervals: elevation (m)")
lines(dept56)
