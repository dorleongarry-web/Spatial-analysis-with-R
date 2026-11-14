# Execute the displayed blocks and capture each actual R result.
dest <- "assets/results/module-05"
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
unlink(list.files(dest, full.names = TRUE))
blocks <- sort(list.files("scripts/05-blocks", pattern = "[.]R$", full.names = TRUE))
lesson_env <- new.env(parent = globalenv())
for (i in seq_along(blocks)) {
  png(file.path(dest, sprintf("block-%02d-%%03d.png", i)),
      width = 1500, height = 1000, res = 135, type = "cairo")
  output <- tryCatch(capture.output({
    for (expr in parse(blocks[i], keep.source = TRUE)) {
      result <- withVisible(eval(expr, lesson_env))
      if (result$visible) print(result$value)
    }
  }), finally = dev.off())
  if (!length(output)) output <- "[Completed successfully; no console output returned by this block.]"
  writeLines(output, file.path(dest, sprintf("block-%02d.txt", i)))
}
message("Module 05: all 14 blocks executed successfully.")
