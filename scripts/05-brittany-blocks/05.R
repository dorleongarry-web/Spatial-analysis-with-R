d35 <- dept[dept$code == "35", ]
buf <- buffer(d35, width = 15000)
ring <- erase(buf, d35)
print(data.frame(department_km2 = expanse(d35, unit = "km"),
                 buffer_km2 = expanse(buf, unit = "km"),
                 outer_ring_km2 = sum(expanse(ring, unit = "km"))))
plot(buf, col = "#f5dc9d", main = "Ille-et-Vilaine and its 15 km buffer")
polys(d35, col = "#e4a07a")
lines(dept, col = "#526358", lty = 2)
add_legend("topright", cex = 0.7, legend = c("Department 35", "Buffer extension"),
       fill = c("#e4a07a", "#f5dc9d"), bty = "n")
