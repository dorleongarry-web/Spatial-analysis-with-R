grid <- rast(vect(basin), resolution = 25)
inside <- mask(init(grid, 1), vect(basin))
centres <- as.points(inside, na.rm = TRUE)
new_sites <- st_as_sf(centres)
prediction <- krige(SOC ~ 1, soil, new_sites, model = model, nmax = 20)
idw_prediction <- idw(SOC ~ 1, soil, new_sites, idp = 2, nmax = 20)
stopifnot(all(is.finite(prediction$var1.pred)), min(prediction$var1.var) >= -1e-8)
ok <- inside
se <- inside
idw_map <- inside
valid <- which(!is.na(values(inside, mat = FALSE)))
ok[valid] <- prediction$var1.pred
se[valid] <- sqrt(pmax(prediction$var1.var, 0))
idw_map[valid] <- idw_prediction$var1.pred
names(ok) <- "SOC_g_C_kg"
names(se) <- "kriging_SE_g_C_kg"
names(idw_map) <- "IDW_SOC_g_C_kg"
limits <- range(c(soil$SOC, values(ok), values(idw_map)), na.rm = TRUE)
pal <- hcl.colors(100, "YlGnBu", rev = TRUE)
plot(ok, col = pal, range = limits, main = "Ordinary kriging: SOC (g C/kg)")
lines(vect(basin))
plot(se, col = hcl.colors(100, "OrRd", rev = TRUE), main = "Kriging standard error (g C/kg)")
points(vect(soil), pch = 16, cex = .3)
lines(vect(basin))
print(global(c(ok, se), c("min", "mean", "max"), na.rm = TRUE))
