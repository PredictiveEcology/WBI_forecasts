# Double checking layers

moduleDir <- "modules"

usrEmail <- ifelse(Sys.info()[["user"]] == "tmichele",
                   "tati.micheletti@gmail.com",
                   NULL)
googledrive::drive_auth(usrEmail)

skipUpdates <- ifelse(Sys.info()[["user"]] == "tmichele", TRUE, FALSE)

if(!skipUpdates){
  source("01-packages.R")
} else {
  if (file.exists(".Renviron")) readRenviron(".Renviron")
  .libPaths(normalizePath(
    file.path("packages", version$platform, paste0(version$major, ".", strsplit(version$minor, "[.]")[[1]][1])),
    winslash = "/",
    mustWork = FALSE
  ))
  message("Using libPaths:\n", paste(.libPaths(), collapse = "\n"))
  library("Require")
  library("data.table")
  library("plyr")
  library("pryr")
  library("SpaDES.core")
  library("archive")
  library("config")
  library("googledrive")
  library("httr")

  # On March 1st this is trying to install reproducible. I don't want it!!!
  # Require(c("data.table", "plyr", "pryr",
  #           "PredictiveEcology/LandR@development", ## TODO: workaround weird raster/sf method problem
  #           "PredictiveEcology/SpaDES.core@development (>= 1.0.10.9002)",
  #           "archive", "config", "googledrive", "httr", "slackr"), upgrade = FALSE)
}
source("02-init.R")
source("03-paths.R")
source("04-options.R")
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
source("R/birdPredictionCoresCalc_WBI.R")
source("R/checkBirdsAvailable_WBI.R")
source("modules/birdsNWT/R/loadStaticLayers.R")

Require("raster")

stepCacheTag <- c(paste0("cache:10b"),
                  paste0("runName:", runName))

do.call(setPaths, posthocPaths)

# Derive parameters from runName
scenario <- runName
Run <- strsplit(runName, split = "_")[[1]][4]
Province <- strsplit(runName, split = "_")[[1]][1]
ClimateModel <- strsplit(runName, split = "_")[[1]][2]
RCP <- strsplit(runName, split = "_")[[1]][3]

# RTM

pathRTM <- file.path(Paths$inputPath, paste0(studyAreaName, "_rtm.tif"))

if (file.exists(pathRTM)){
  rasterToMatch <- raster(pathRTM)
} else stop("RTM doesn't exist. Please run script 'source('06-studyArea.R')'")

# Make RTM have only 1's
rasterToMatch[!is.na(rasterToMatch)] <- 1

# STUDY AREA

pathSA <- file.path(Paths[["inputPath"]], paste0(studyAreaName, "_SA.qs"))

if (file.exists(pathSA)){
  studyArea <- qs::qread(pathSA)
} else {
  studyArea <- makeStudyArea(studyAreaName)
}

allVars <- c("AHM", "MAT", "EMT", "TD")
# AHM <- "https://drive.google.com/file/d/1aGiQ9jNv9g65BIPoaA9fbHai04ZNmKzL/view?usp=sharing"
# MAT <- "https://drive.google.com/file/d/1C1hjizFp1O9i0uCeTOkk5U3fGXaFvTZw/view?usp=sharing"
# EMT <- "https://drive.google.com/file/d/18BSAA7oSZp-pAU_uZg1X7fs-XUOy0jlS/view?usp=sharing"
# # Tave_sm <- "https://drive.google.com/file/d/1UIDkQviIg0Z1tQ7DAow_ingBEIjf9bR1/view?usp=sharing"
# TD <- "https://drive.google.com/file/d/1313ihmLn-yY3s3XvZ7gb-WXBBCK5md2E/view?usp=sharing"

AHM <- "https://drive.google.com/file/d/1BRJSOvSZgM9MtQxMEqFhXpAHgFdWLFkO/view?usp=sharing"
EMT <- "https://drive.google.com/file/d/1O_i3ndvQV17NbDpuaUmQHU-Ysx5ern1o/view?usp=sharing"
MAT <- "https://drive.google.com/file/d/1czVLClaysdmdR_3wW8nNE0q9fU_L6gHo/view?usp=sharing"
# Tave_sm <- "https://drive.google.com/file/d/1UIDkQviIg0Z1tQ7DAow_ingBEIjf9bR1/view?usp=sharing"
TD <- "https://drive.google.com/file/d/1Fgk-TxVIYnBI_uRVmokKA9L3j06jPcIj/view?usp=sharing"

stackUsed <- raster::stack(lapply(allVars, function(VAR){
  ras <- prepInputs(url = base::get(VAR),
                    targetFile = paste0(VAR, ".tif"),
                    destinationPath = tempdir(),
                    studyArea = studyArea,
                    rasterToMatch = rasterToMatch,
                    fun = "raster::raster",
                    format = "GTiff")
  return(ras)
}))

writeRaster(stackUsed,
            filename = file.path("inputs/climate/future/climate_MSY/stackBAM.tif"),
            format = "GTiff")


# Comparison to what I have

calculatedStk <- raster::stack("inputs/climate/future/climate_MSY/Alberta_CNRM-ESM2-1_ssp370_birds_2011.grd")
calculatedStk <- calculatedStk[[allVars]]
originalStk <- raster::stack(raster("inputs/climate/future/climate_MSY/Alberta/CNRM-ESM2-1_ssp370_AHM_Year2011.tif"),
                             raster("inputs/climate/future/climate_MSY/Alberta/CNRM-ESM2-1_ssp370_MAT_Year2011.tif"),
                             raster("inputs/climate/future/climate_MSY/Alberta/CNRM-ESM2-1_ssp370_EMT_Year2011.tif"),
                             raster("inputs/climate/future/climate_MSY/Alberta/CNRM-ESM2-1_ssp370_TD_Year2011.tif"))
names(originalStk) <- allVars
BAMsStk <- raster::stack("inputs/climate/future/climate_MSY/stackBAM.tif")
names(BAMsStk) <- allVars

# This shows that the variables BAM (Diana/Peter) used to fit the bird models are in the original scale,
# not multiplied by 10 to save space (i.e., how the layers come from ClimateNA V6 and above)
