soc_v <- variogram(SOC ~ 1, soil, cutoff = 2500, width = 250)
start_var <- var(soil$SOC)
spherical <- fit.variogram(soc_v, vgm(.7 * start_var, "Sph", 800, .3 * start_var))
exponential <- fit.variogram(soc_v, vgm(.7 * start_var, "Exp", 800, .3 * start_var))
print(soc_v)
print(spherical)
print(exponential)
print(data.frame(model = c("Spherical", "Exponential"),
  weighted_SSE = c(attr(spherical, "SSErr"), attr(exponential, "SSErr")),
  singular = c(attr(spherical, "singular"), attr(exponential, "singular"))))
stopifnot(!attr(exponential, "singular"), all(exponential$psill >= 0))
model <- exponential
print(plot(soc_v, spherical, main = "SOC: spherical model", xlab = "Distance (m)", ylab = "Semivariance ((g C/kg)²)"))
print(plot(soc_v, exponential, main = "SOC: exponential model", xlab = "Distance (m)", ylab = "Semivariance ((g C/kg)²)"))
