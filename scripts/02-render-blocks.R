# Execute every displayed R block in order, preserving the shared R workspace.
# From the repository root: source("scripts/02-render-blocks.R")
dest <- "assets/results/module-02"
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
unlink(list.files(dest, full.names = TRUE))
blocks <- sort(list.files("scripts/02-blocks", pattern = "[.]R$", full.names = TRUE))
lesson_env <- new.env(parent = globalenv())
for (i in seq_along(blocks)) {
  code <- readLines(blocks[i], warn = FALSE, encoding = "UTF-8")
  png(file.path(dest, sprintf("block-%02d-%%03d.png", i)),
      width = 1500, height = 1000, res = 135, type = "cairo")
  text <- tryCatch(capture.output({
    for (expr in parse(text = code)) {
      result <- withVisible(eval(expr, envir = lesson_env))
      if (result$visible) print(result$value)
    }
  }), finally = dev.off())
  if (!length(text)) text <- "[Completed successfully; no console output returned by this block.]"
  writeLines(text, file.path(dest, sprintf("block-%02d.txt", i)))
}
capture.output(sessionInfo(), file = file.path(dest, "session-info.txt"))
message("All displayed blocks executed successfully.")
