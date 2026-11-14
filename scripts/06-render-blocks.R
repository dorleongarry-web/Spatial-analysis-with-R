library(terra)
out <- "assets/results/module-06-brittany"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(356)
for (i in 1:15) {
  cat("Starting block", i, "\n")
  console <- file(sprintf("%s/block-%02d.txt", out, i), "wt")
  sink(console, split = TRUE)
  png(sprintf("%s/block-%02d-%%02d.png", out, i), width = 1400, height = 1100,
      res = 145, type = "cairo")
  tryCatch(source(sprintf("scripts/06-blocks/%02d.R", i), echo = FALSE),
           finally = {dev.off(); sink(); close(console)})
}
writeLines(capture.output(sessionInfo()), "outputs/module-06/brittany/session-info.txt")
