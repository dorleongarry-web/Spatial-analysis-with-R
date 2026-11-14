countries2 <- countries[countries$gdp_md_est > 0 & countries$pop_est > 0, ]
countries2$gdp_hab <- countries2$gdp_md_est * 1e6 / countries2$pop_est
hist(log10(countries2$gdp_hab))

classes <- cut(countries2$gdp_hab,
  breaks = c(0, 3000, 10000, 20000, 40000, Inf),
  labels = c("<3k", "3–10k", "10–20k", "20–40k", ">40k"))
cols <- brewer.pal(5, "Greens")
plot(countries2, col = cols[as.integer(classes)])
legend("bottomleft", legend = levels(classes), fill = cols,
       bg = "white", inset = c(0.02, 0.15), cex = 0.8)

# Boxplots: labelled economic categories and logarithmic GDP axis
economy <- factor(countries2$economy)
par(mar = c(5, 16, 4, 2))
boxplot(countries2$gdp_hab ~ economy, horizontal = TRUE, log = "x",
        las = 1, cex.axis = 0.75, col = "lightblue",
        xlab = "GDP per capita (USD; logarithmic scale)",
        ylab = "", main = "GDP per capita by economic category")
par(mar = c(5.1, 4.1, 4.1, 2.1))
