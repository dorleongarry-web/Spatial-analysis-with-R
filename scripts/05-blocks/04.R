# Dissolve polygon boundaries by the broad rock-group attribute.
litho_groups <- aggregate(litho, by = "TYPE")
par(mfrow = c(1, 2))
plot(litho, "TYPE", col = type_palette, legend = FALSE,
     main = "Source polygons", mar = c(3, 3, 3, 1))
plot(litho_groups, "TYPE", col = type_palette, legend = FALSE,
     main = "Dissolved by TYPE", mar = c(3, 3, 3, 1))
par(mfrow = c(1, 1))
c(before = nrow(litho), after = nrow(litho_groups))
as.data.frame(litho_groups)
