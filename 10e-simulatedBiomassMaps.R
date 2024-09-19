library(terra)
library(reproducible)
library(SpaDES.tools)

years <- 2011:2100
Nreps <- 5 ## adjust as needed
studyAreaNames <- c("AB", "BC", "MB", "NT", "SK", "YT")
climateScenarios <- c("CanESM5_SSP370", "CanESM5_SSP585", "CNRM-ESM2-1_SSP370", "CNRM-ESM2-1_SSP585")

## re-create simulatedBiomass maps from cohortData -------------------------------------------------

ncores <- min(length(years), parallel::detectCores() / 2)

options(mc.cores = ncores)

parallel::mclapply(years, function(yr) {
  simOutputPath <- "~/GitHub/WBI_forecasts/outputs"
  resultsDir0 <- file.path(simOutputPath, sAN)

  lapply(studyAreaNames, function(sAN) {
    lapply(climateScenarios, function(cs) {
      lapply(seq_len(Nreps), function(run) {
          runName <- sprintf("%s_%s_run%02d", sAN, cs, run)
        resultsDir <- file.path(simOutputPath, runName)
        resultsDirOut <- checkPath(file.path(resultsDir, "postprocess"), create = TRUE)
        fBmap <- file.path(resultsDirOut, paste0("simulatedBiomassMap_redux_", yr, ".tif"))

        cd <- file.path(resultsDir, paste0("cohortData_", yr, "_year", yr, ".qs")) |>
          qs::qread()
        cdr <- cd[, .(uniqueSumB = as.integer(sum(B, na.rm = TRUE))), by = pixelGroup]

        pgm <- file.path(resultsDir, paste0("pixelGroupMap_", yr, "_year", yr, ".tif")) |>
          terra::rast()
        set.names(pgm, "pixelGroup")

        Bmap <- rasterizeReduced(cdr, pgm, "uniqueSumB")
        set.names(Bmap, "Biomass")

        writeRaster(Bmap, filename = fBmap, datatype = "FLT4S", overwrite = TRUE)

        invisible(runName)
      })
    })
  })

  invisible(yr)
})
