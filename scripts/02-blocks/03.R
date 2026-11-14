print(countries)
crs(countries)
ext(countries)
country_attributes <- as.data.frame(countries)
head(country_attributes)
france <- countries[countries$adm0_a3 == "FRA", ]
plot(countries, col = "lightgray")
plot(france, col = "gold", add = TRUE)