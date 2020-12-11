.starttime <- Sys.time()

if (file.exists(".Renviron")) readRenviron(".Renviron")

library(config)

cacheDir <- config::get("paths")[["cachedir"]]
cloudCacheFolderID <- config::get("cloud")[["cachedir"]]

scratchDir <- config::get("paths")[["scratchdir"]]
studyAreaName <- config::get("studyarea")
useCloudCache <- config::get("cloud")[["usecloud"]]
usePlot <- config::get("plot")
.plotInitialTime <- if (isTRUE(usePlot)) 2011 else NA
