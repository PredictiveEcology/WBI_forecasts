#######################################
#                                     #
#    P O S T H O C     B I R D S      #
#                                     #
#######################################

moduleDir <- "modules"

source("01-packages.R")
source("02-init.R")
source("03-paths.R")
source("04-options.R")
source("05-google-ids.R")
source("R/makeStudyArea.R")

Require("raster")
Require("sf")

do.call(setPaths, posthocPaths)

# RTM

pathRTM <- file.path(Paths$inputPath, paste0(studyAreaName, "_rtm.tif"))

if (file.exists(pathRTM)){
  rasterToMatch <- raster(pathRTM)
} else stop("RTM doesn't exist. Please run script 'source('06-studyArea.R')'")

# STUDY AREA

pathSA <- file.path(Paths[["inputPath"]], paste0(studyAreaName, "_SA.qs"))

if (file.exists(pathSA)){
  SA <- qs::qread(pathSA)
} else {
  SA <- makeStudyArea(studyAreaName)
}
