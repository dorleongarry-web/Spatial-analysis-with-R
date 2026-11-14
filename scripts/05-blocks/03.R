# Broad groups and detailed descriptions answer different questions.
type_levels <- sort(unique(litho$TYPE))
description_levels <- sort(unique(litho$DESCR))
type_palette <- brewer.pal(length(type_levels), "Set2")
description_palette <- brewer.pal(length(description_levels), "Set3")
plot(litho, "TYPE", col = type_palette, main = "Lithology: broad groups",
     mar = c(3, 4, 3, 10), plg = list(cex = 0.8))
plot(litho, "DESCR", col = description_palette, main = "Lithology: rock descriptions",
     mar = c(3, 4, 3, 11), plg = list(cex = 0.7))
plot(dept, col = "#e2e6e2", ext = union(ext(struct), ext(dept)),
     main = "Geological structures")
lines(struct, col = "#365b8c", lwd = 1)
plot(dept, col = "#e2e6e2", ext = union(ext(mines), ext(dept)),
     main = "Mine locations in the teaching dataset")
points(mines, pch = 19, col = "#8b4d3f", cex = 0.6)
