groups <- aggregate(boundaries, by = "NAME_1")
values <- extract(dem, groups)
values$group <- groups$NAME_1[values$ID]
values <- values[!is.na(values$elevation), ]
group_names <- sort(unique(values$group))
colours <- c("#80aa68", "#e6aa74", "#8b9dce")
boxplot(elevation ~ group, data = values, col = colours,
        ylab = "Elevation (m)", xlab = "Source administrative group",
        main = "Elevation distribution by source group", ylim = c(100, 650))
legend("topright", legend = group_names, fill = colours, bty = "n", cex = 0.75)
print(aggregate(elevation ~ group, data = values, FUN = mean))
print(table(values$group))
