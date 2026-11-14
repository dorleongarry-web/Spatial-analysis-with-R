dir.create("outputs/module-09",recursive=TRUE,showWarnings=FALSE)
dir.create("assets/results/module-09",recursive=TRUE,showWarnings=FALSE)
for(i in 1:9){
 png(sprintf("assets/results/module-09/block-%02d-%%02d.png",i),1200,850,res=130)
 sink(sprintf("assets/results/module-09/block-%02d.txt",i),split=TRUE)
 tryCatch(source(sprintf("scripts/09-blocks/%02d.R",i),local=.GlobalEnv),finally={sink();dev.off()})
}
