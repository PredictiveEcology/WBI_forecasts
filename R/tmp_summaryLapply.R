
if (file.exists(".Renviron")) readRenviron(".Renviron")

pkgDir <- Sys.getenv("PRJ_PKG_DIR")
if (!nzchar(pkgDir)) {
  pkgDir <- "packages" ## default: use subdir within project directory
}
pkgDir <- normalizePath(
  file.path(pkgDir, version$platform, paste0(version$major, ".", strsplit(version$minor, "[.]")[[1]][1])),
  winslash = "/",
  mustWork = FALSE
)

if (!dir.exists(pkgDir)) {
  dir.create(pkgDir, recursive = TRUE)
}

.libPaths(pkgDir)
message("Using libPaths:\n", paste(.libPaths(), collapse = "\n"))

library("Require")
library("data.table")
library("plyr")
library("pryr")
library("SpaDES.core")
library("archive")
library("googledrive")
library("httr")
library("raster")
library("usefulFuns")
library("caribouMetrics")
library("sf")
library("tictoc")

DT <- data.table(runName = NULL, outPath = NULL)

for (RP in c(paste0("run0", 1:5))) {
  for (CS in c("CanESM5", "CNRM-ESM2-1")) {
    for (SS in c("SSP370", "SSP585")) {
      for (P in c("AB", "BC", "SK", "MB", "YT", "NT")) { #"AB", "BC", "SK", "MB", "YT", "NT" # SKIPPING "YT"
        runName <- paste(P, CS, SS, RP, sep = "_")
        tic(paste0("Finished for ", runName, ". ELAPSED TIME: "))

        moduleDir <- "modules"
        source("02-init.R")
        source("03-paths.R")
        source("04-options.R")
        maxLimit <- 20000 # in MB
        on.exit(options(future.globals.maxSize = 500*1024^2))
        options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
        source("05-google-ids.R")

        do.call(setPaths, summaryPaths)

        # Derive parameters from runName
        scenario <- runName
        Run <- strsplit(runName, split = "_")[[1]][4]
        Province <- strsplit(runName, split = "_")[[1]][1]
        ClimateModel <- strsplit(runName, split = "_")[[1]][2]
        RCP <- strsplit(runName, split = "_")[[1]][3]
        # Reset input paths to the folder where simulation outputs are
        setPaths(inputPath = file.path(getwd(), "outputs", runName)) # THIS IS THE ORIGINAL FOR WHEN THE RUNS ARE DONE
        toc()
        DT <- rbind(DT, data.table(runName = runName, outPath = Paths$rasterPath))
      }
    }
  }
}

