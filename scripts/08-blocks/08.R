plot(idw_map, col = pal, range = limits, main = "IDW (power 2): SOC (g C/kg)")
lines(vect(basin))
difference <- idw_map - ok
names(difference) <- "IDW_minus_OK_g_C_kg"
bound <- max(abs(values(difference)), na.rm = TRUE)
plot(difference, col = hcl.colors(100, "Blue-Red 3"), range = c(-bound, bound), main = "IDW − kriging (g C/kg)")
lines(vect(basin))
print(global(difference, c("mean", "sd", "min", "max"), na.rm = TRUE))
within_band <- abs(difference) <= 2 * se
print(data.frame(fraction_IDW_within_OK_plus_minus_2SE = global(within_band, "mean", na.rm = TRUE)[1, 1]))
print(global(c(ok, idw_map), c("mean", "sd"), na.rm = TRUE))
