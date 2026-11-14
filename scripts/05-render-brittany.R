library(terra)
out <- "assets/results/module-05-brittany"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
for (i in 1:11) {
  f <- sprintf("scripts/05-brittany-blocks/%02d.R", i)
  console <- file(sprintf("%s/block-%02d.txt", out, i), "wt")
  sink(console, split = TRUE)
  png(sprintf("%s/block-%02d-%%02d.png", out, i), width = 1400,
      height = 1100, res = 145, type = "cairo")
  tryCatch(source(f, echo = FALSE), finally = {dev.off(); sink(); close(console)})
}
writeLines(capture.output(sessionInfo()), "outputs/module-05-brittany/session-info.txt")
