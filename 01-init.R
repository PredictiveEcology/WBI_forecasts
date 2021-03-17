.starttime <- Sys.time()

if (file.exists(".Renviron")) readRenviron(".Renviron")

Require::Require("config")

cacheDir <- config::get("paths")[["cachedir"]]
cacheFormat <- config::get("cacheformat")
cloudCacheFolderID <- config::get("cloud")[["cachedir"]]
codeChecks <- config::get("codechecks")
firstRun <- FALSE ## TODO: restore FALSE
messagingNumCharsModule <- config::get("messagingNumCharsModule")
reproducibleAlgorithm <- config::get("reproduciblealgorithm")
scratchDir <- config::get("paths")[["scratchdir"]]
studyAreaName <- config::get("studyarea")
useCloudCache <- config::get("cloud")[["usecloud"]]
useMemoise <- config::get("usememoise")
usePlot <- config::get("plot")
userInputPaths <- config::get("inputpaths")
usePrerun <- config::get("useprerun")
useRequire <- config::get("userequire")
.plotInitialTime <- if (isTRUE(usePlot)) 2011 else NA
