library(terra)
out <- "assets/results/module-07"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
for (i in 1:9) {
  cat("Starting block", i, "\n")
  con <- file(sprintf("%s/block-%02d.txt", out, i), "wt")
  sink(con, split = TRUE)
  png(sprintf("%s/block-%02d-%%02d.png", out, i), width = 1400, height = 1100, res = 145, type = "cairo")
  tryCatch(source(sprintf("scripts/07-blocks/%02d.R", i), echo = FALSE),
           finally = {dev.off(); sink(); close(con)})
}
writeLines(capture.output(sessionInfo()), "outputs/module-07/session-info.txt")
