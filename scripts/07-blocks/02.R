dept <- project(vect("data/vectors/departments-35-56.gpkg"), crs(sentinel))
X0 <- 559660
Y0 <- 5318840
DX <- 8000
DY <- 6000
ext0 <- ext(X0 - DX, X0 + DX, Y0 - DY, Y0 + DY)
plot(sentinel$B01, col = gray.colors(100, 0, 1), main = "B01 context: crop window in red")
lines(dept, col = "#dd9b32", lwd = 1.5)
lines(ext0, col = "red", lwd = 2)
sentinel_roi <- crop(sentinel, ext0)
print(sentinel_roi)
plot(sentinel_roi$B01, col = gray.colors(100, 0, 1), main = "B01 after crop: reflectance")
lines(dept, col = "#dd9b32", lwd = 1.5)
