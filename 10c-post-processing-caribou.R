###########################################
#                                         #
#    P O S T H O C     C A R I B O U      #
#                                         #
###########################################

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
  Require(c("data.table", "plyr", "pryr",
            "PredictiveEcology/LandR@development", ## TODO: workaround weird raster/sf method problem
            "PredictiveEcology/SpaDES.core@development (>= 1.0.10.9002)",
            "archive", "config", "googledrive", "httr", "slackr"), upgrade = FALSE)
}
source("02-init.R")
source("03-paths.R")
source("04-options.R")
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
source("R/rstCurrentBurnListGenerator_WBI.R")


Require("raster")
Require("plyr")
Require("usefulFuns")

stepCacheTag <- c(paste0("cache:10b"),
                  paste0("runName:", runName))

do.call(setPaths, posthocPaths)

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

# Info
Run <- strsplit(runName, split = "_")[[1]][4]
Province <- strsplit(runName, split = "_")[[1]][1]
ClimateModel <- strsplit(runName, split = "_")[[1]][2]
RCP <- strsplit(runName, split = "_")[[1]][3]

# Determine study area long name
studyAreaLongName <- switch(studyAreaName,
                            AB = "Alberta",
                            BC = "British Columbia",
                            SK = "Saskatchewan",
                            MB = "Manitoba",
                            NT = "Northwest Territories & Nunavut",
                            NU = "Northwest Territories & Nunavut",
                            YT = "Yukon",
                            RIA = "RIA")

# CREATE NEEDED OBJECTS
# Important ones:
waterValues <- 18

landcoverMap <- Cache(LandR::prepInputsLCC, destinationPath = Paths$inputPath,
                      studyArea = studyArea,
                      rasterToMatch = rasterToMatch,
                      filename2 = paste0("LCC_", Province, ".tif"),
                      userTags = c("objectName:landcoverMap",
                                   stepCacheTag,
                                   "outFun:Cache"),
                      omitArgs = c("destinationPath", "filename2"))

watersVals <- raster::getValues(landcoverMap)

watersValsToChange <- watersVals
watersValsToChange[!is.na(watersValsToChange) & !watersValsToChange %in% waterValues] <- NA
waterRaster <- raster::setValues(x = landcoverMap, watersValsToChange)
waterRaster[!is.na(waterRaster)] <- 1

parameters <- list(
  caribouPopGrowthModel = list(
    ".plotInitialTime" = NULL,
    "climateModel" = ClimateModel,
    "useFuture" = FALSE,
    "recoveryTime" = 40,
    # "whichPolysToIgnore" = c("Yates", "Bistcho", "Maxhamish"),
    ".useDummyData" = FALSE,
    ".growthInterval" = 10,
    "recruitmentModelVersion" = "Johnson", # Johnson or ECCC
    "recruitmentModelNumber" = "M4",
    "femaleSurvivalModelNumber" = c("M1", "M4") # M1:M5 --> best models: M1, M4
  )
  # ATTENTION: recruitmentModelNumber and recruitmentModelVersion need to be paired. ie.
  # if you want to run M3 from ECCC and M1 and M4 from Johnson you should put these as
  #     "recruitmentModelVersion" = c("ECCC", "Johnson", "Johnson"),
  #     "recruitmentModelNumber" = c("M3", "M1", "M4"),
  # otherwise it will repeat the recruitmentModelVersion for all recruitmentModelNumber
)
modules <- list("caribouPopGrowthModel")

# Reset input paths to the folder where simulation outputs are
# setPaths(inputPath = file.path(getwd(), "outputs", runName)) # THIS IS THE ORIGINAL FOR WHEN THE RUNS ARE DONE
setPaths(inputPath = file.path(getwd(), "outputs/_archive_2022-02-14", runName)) # THIS IS THE CURRENT TO TEST CODE. WHEN READY, Comment out

rstCurrentBurnList <-  rstCurrentBurnListGenerator_WBI(pathInputs = Paths$inputPath)

# Add objects
objects <- list(
  "studyArea" = studyArea,
  "rasterToMatch" = rasterToMatch,
  "usrEmail" = usrEmail,
  "waterRaster" = waterRaster,
  "rstCurrentBurnList" = rstCurrentBurnList,
  "runName" = runName,
  "shortProvinceName" = Province)

# Set simulation times
Times <- list(start = 2011, end = 2091)

message(crayon::yellow(paste0("Starting simulations for CARIBOU using ", paste(ClimateModel, RCP, collapse = " "),
                              " for ", Province, " (", Run, ")")))

simOut <- simInitAndSpades(times = Times,
                           params = parameters,
                           modules = modules,
                           objects = objects,
                           paths = Paths,
                           loadOrder = unlist(modules))
