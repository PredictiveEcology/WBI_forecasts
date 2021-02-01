Require(c("plyr", "dplyr"), upgrade = FALSE) ## ensure plyr loaded before dplyr or there will be problems
Require("PredictiveEcology/SpaDES.core@development",
        which = c("Suggests", "Imports", "Depends"), upgrade = FALSE) # need Suggests in SpaDES.core
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
