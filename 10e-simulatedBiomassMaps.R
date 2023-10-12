years <- 2011:2100
Nreps <- 5 ## adjust as needed
studyAreaNames <- c("AB", "BC", "MB", "NT", "SK", "YT")
climateScenarios <- c("CanESM5_SSP370", "CanESM5_SSP585", "CNRM-ESM2-1_SSP370", "CNRM-ESM2-1_SSP585")

library(raster)
library(reproducible)
library(SpaDES.core)

# create timeSinceFire maps -------------------------------------------------------------------

options(mc.cores = length(studyAreaNames))

parallel::mclapply(studyAreaNames, function(sAN) {
  simOutputPath <- "outputs"
  resultsDir0 <- file.path(simOutputPath, sAN)

  lapply(climateScenarios, function(cs) {
    lapply(seq_len(Nreps), function(run) {
      lapply(years, function(year) {
        runName <- sprintf("%s_%s_run%02d", sAN, cs, run)
        resultsDir <- file.path(simOutputPath, runName)
        resultsDirOut <- checkPath(file.path(resultsDir, "postprocess"), create = TRUE)
        fBmap <- file.path(resultsDirOut, paste0("simulatedBiomassMap_redux_", year, ".tif"))

        if (!file.exists(fBmap)) {
          sim <- loadSimList(file.path(resultsDir, paste0(runName, ".qs")))
          writeRaster(sim$simulatedBiomassMap, filename = fBmap, datatype = "FLT4S", overwrite = TRUE)
          rm(sim)
        }

        invisible(runName)
      })
    })
  })

  invisible(sAN)
})
