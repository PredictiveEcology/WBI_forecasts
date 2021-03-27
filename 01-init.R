.starttime <- Sys.time()

if (file.exists(".Renviron")) readRenviron(".Renviron")

Require::Require("config")

cacheDir <- config::get("paths")[["cachedir"]]
cacheFormat <- config::get("cacheformat")
cloudCacheFolderID <- config::get("cloud")[["cachedir"]]
codeChecks <- config::get("codechecks")
delayStart <- config::get("delaystart")
messagingNumCharsModule <- config::get("messagingNumCharsModule")
newGoogleIDs <- FALSE ## gets rechecked/updated for each script (06, 07x, 08x) based on script 05
reproducibleAlgorithm <- config::get("reproduciblealgorithm")
reupload <- FALSE
run <- config::get("run")
scratchDir <- config::get("paths")[["scratchdir"]]
studyAreaName <- config::get("studyarea")
if (studyAreaName == "NU") studyAreaName <- "NT" ## NU and NT are joined
useCloudCache <- config::get("cloud")[["usecloud"]]
useMemoise <- config::get("usememoise")
usePlot <- config::get("plot")
userInputPaths <- config::get("inputpaths")
usePrerun <- config::get("useprerun")
useRequire <- config::get("userequire")
.plotInitialTime <- if (isTRUE(usePlot)) 2011 else NA

if (!exists("runName")) {
  runName <- sprintf("%s_CCSM4_RCP85_run%02d", studyAreaName, run) ## TODO: update for other climate scenarios
} else {
  studyAreaName <- strsplit(runName, "_")[[1]][1]
  run <- as.numeric(substr(runName, nchar(runName) - 1, nchar(runName)))
}

firstRunMDCplots <- if (studyAreaName == "AB" | run != 1) FALSE else TRUE ## TODO: restore FALSE
firstRunSpreadFit <- FALSE
