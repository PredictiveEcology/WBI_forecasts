## ensure plyr loaded before dplyr or there will be problems
Require(c("plyr", "PredictiveEcology/SpaDES.core@development"),
        which = c("Suggests", "Imports", "Depends"), upgrade = FALSE) # need Suggests in SpaDES.core

# This pre-loading is not really necessary -- and it slows everything down simInitAndSpades are skipped with
#   theData loading step
#needed <- reqdPkgs(module = dir(preamblePaths$modulePath), modulePath = preamblePaths$modulePath)
#Require(unique(unlist(needed)), upgrade = FALSE)


# Require(c(
#   "achubaty/amc@development",
#   "data.table",
#   "DBI",
#   "googledrive",
#   "magrittr",
#   "parallel",
#   "qs",
#   "sf",
#   "raster",
#   "PredictiveEcology/fireSenseUtils@development",
#   "PredictiveEcology/LandR@development",
#   "PredictiveEcology/SpaDES.core@development",
#   "PredictiveEcology/pemisc@development"
# ))
