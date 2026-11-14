for (band in names(sentinel_str)) {
  plot(sentinel_str[[band]], col = gray.colors(100, 0, 1), range = c(0, 1000),
       main = paste(band, "- stretched display values (0–1000)"))
}
