dir.create("outputs/module-08", recursive=TRUE, showWarnings=FALSE)
dir.create("assets/results/module-08", recursive=TRUE, showWarnings=FALSE)
for (i in 1:10) {
  log <- sprintf("assets/results/module-08/block-%02d.txt", i)
  png(sprintf("assets/results/module-08/block-%02d-%%02d.png", i), width=1200, height=850, res=130)
  sink(log, split=TRUE)
  tryCatch(source(sprintf("scripts/08-blocks/%02d.R", i), local=.GlobalEnv),
           finally={sink(); dev.off()})
}
