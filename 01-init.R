.starttime <- Sys.time()

if (file.exists(".Renviron")) readRenviron(".Renviron")

library(config)

cacheDir <- config::get("paths")[["cachedir"]]
cloudCacheFolderID <- config::get("cloud")[["cachedir"]]
cloudCacheFolderID <- NULL ## TODO: Spread expects a character arg for cloudFolderID, but Cache accepts a dribble.
                           ##        if using the character, we need to set the reproducible.cloudFolderID option. Not sure which is better

scratchDir <- config::get("paths")[["scratchdir"]]
studyAreaName <- config::get("studyarea")
useCloudCache <- config::get("cloud")[["usecloud"]]
usePlot <- config::get("plot")
.plotInitialTime <- if (isTRUE(usePlot)) 2011 else NA
