# Split multipart volcanic polygons into separate features.
volcanic_source <- litho[litho$DESCR == "Basalt and rhyolith", ]
volcanics <- disagg(volcanic_source)
par(mfrow = c(1, 2))
plot(volcanic_source, col = rainbow(nrow(volcanic_source)),
     main = "Multipart features", mar = c(3, 3, 3, 1))
text(volcanic_source, labels = seq_len(nrow(volcanic_source)), cex = 0.8)
plot(volcanics, col = rainbow(nrow(volcanics)),
     main = "Singlepart features", mar = c(3, 3, 3, 1))
text(volcanics, labels = seq_len(nrow(volcanics)), cex = 0.8)
par(mfrow = c(1, 1))
c(before = nrow(volcanic_source), after = nrow(volcanics))
