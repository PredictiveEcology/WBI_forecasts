years <- 2011:2100
Nreps <- 5 ## adjust as needed
studyAreaNames <- c("AB", "BC", "MB", "NT", "SK", "YT")
climateScenarios <- c("CanESM5_SSP370", "CanESM5_SSP585", "CNRM-ESM2-1_SSP370", "CNRM-ESM2-1_SSP585")

source("01a-packages-libPath.R")
library(raster)
library(reproducible)
library(SpaDES.core)

# create timeSinceFire maps -------------------------------------------------------------------

options(mc.cores = length(studyAreaNames))

parallel::mclapply(studyAreaNames, function(sAN) {
  simOutputPath <- "outputs"
  resultsDir0 <- file.path(simOutputPath, sAN)

  sim_SA <- loadSimList(file.path(resultsDir0, paste0("biomassMaps2011_", sAN, ".qs")))
  timeSinceFire <- sim_SA$standAgeMap
  rm(sim_SA)

  lapply(climateScenarios, function(cs, tsf) {
    lapply(seq_len(Nreps), function(run, tsf) {
      lapply(years, function(year, tsf) {
        resultsDir <- file.path(simOutputPath, sprintf("%s_%s_run%02d", sAN, cs, run))
        resultsDirOut <- checkPath(file.path(resultsDir, "postprocess"), create = TRUE)

        currentBurn <- raster(file.path(resultsDir, paste0("rstCurrentBurn_", year, "_year", year, ".tif")))
        burnedPixels <- which(tsf[] == 1)
        tsf <- tsf + 1L
        tsf[burnedPixels] <- 0L
        writeRaster(tsf, filename = file.path(resultsDirOut, paste0("timeSinceFire_", year, ".tif")), overwrite = TRUE)

        invisible(TRUE)
      }, tsf = tsf)
    }, tsf = tsf)
  }, tsf = timeSinceFire)

  invisible(TRUE)
})

# create standAgeMaps + vegTypeMaps -----------------------------------------------------------
library(SpaDES.tools)
library(LandR)

options(mc.cores = length(years))

lapply(studyAreaNames, function(sAN) {
  simOutputPath <- "outputs"

  sim_SA <- loadSimList(file.path(simOutputPath, sAN,
                                  paste0("simOutPreamble_", sAN, "_",
                                         gsub("SSP", "", climateScenarios[[1]]), ".qs")))
  sppColorVect <- sim_SA$sppColorVect
  sppEquiv <- sim_SA$sppEquiv
  sppEquivCol <- sim_SA$sppEquivCol
  rm(sim_SA)

  lapply(climateScenarios, function(cs) {
    lapply(seq_len(Nreps), function(run) {
      parallel::mclapply(years, function(year) {
        resultsDir <- file.path(simOutputPath, sprintf("%s_%s_run%02d", sAN, cs, run))
        resultsDirOut <- checkPath(file.path(resultsDir, "postprocess"), create = TRUE)

        cohortData <- qs::qread(file = file.path(resultsDir, paste0("cohortData_", year, "_year", year, ".qs")))
        cohortData[, bWeightedAge := floor(sum(age * B) / sum(B) / 10) * 10, .(pixelGroup)]
        cohortDataReduced <- cohortData[, c("pixelGroup", "bWeightedAge")]
        cohortDataReduced <- unique(cohortDataReduced)
        pixelGroupMap <- raster(file.path(resultsDir, paste0("pixelGroupMap_", year, "_year", year, ".tif")))
        names(pixelGroupMap) <- "pixelGroup"

        standAgeMap <- rasterizeReduced(cohortDataReduced, pixelGroupMap, "bWeightedAge", mapCode = "pixelGroup")
        writeRaster(standAgeMap, filename = file.path(resultsDirOut, paste0("standAgeMap_", year, ".tif")), overwrite = TRUE)

        vtm <- vegTypeMapGenerator(cohortData, pixelGroupMap,
                                   vegLeadingProportion = 0.8,  mixedType = 2,
                                   sppEquiv = sppEquiv, sppEquivCol = sppEquivCol,
                                   doAssertion = FALSE)
        writeRaster(vtm, filename = file.path(resultsDirOut, paste0("vegTypeMap_", year, ".tif")), overwrite = TRUE)

        invisible(TRUE)
      })
    })
  })

  invisible(TRUE)
})
