.starttime <- Sys.time()

if (file.exists(".Renviron")) readRenviron(".Renviron")

Require::Require("config")

cacheDir <- config::get("paths")[["cachedir"]]
cacheFormat <- config::get("cacheformat")
climateSSP <- config::get("climatessp")
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
  runName <- sprintf("%s_CanESM5_SSP%03d_run%02d", studyAreaName, climateSSP, run)
} else {
  climateSSP <- strsplit(runName, "_")[[1]][3] %>% substr(., 4, 6)
  studyAreaName <- strsplit(runName, "_")[[1]][1]
  run <- as.numeric(substr(runName, nchar(runName) - 1, nchar(runName)))
}

firstRunMDCplots <- if (run != 1) FALSE else TRUE
firstRunSpreadFit <- FALSE
