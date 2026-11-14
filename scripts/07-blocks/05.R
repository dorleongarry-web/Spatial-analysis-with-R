sentinel_str <- stretch(sentinel_clean, minq = 0.05, maxq = 0.95, minv = 0, maxv = 1000,
                        maxcell = ncell(sentinel_clean), bylayer = TRUE)
print(global(sentinel_str, c("min", "max"), na.rm = TRUE))
plot(sentinel_clean$B01, col = gray.colors(100, 0, 1), main = "Before stretch: B01 reflectance")
plot(sentinel_str$B01, col = gray.colors(100, 0, 1), range = c(0, 1000),
     main = "After 5–95% stretch: B01 display values")
stretched_values <- values(sentinel_str$B01, mat = FALSE)
stretched_values <- stretched_values[is.finite(stretched_values)]
hist(stretched_values, breaks = 100, col = "#6b9482", xlab = "Display value (0–1000)",
     ylab = "Number of cells", main = "B01 after contrast stretch")
