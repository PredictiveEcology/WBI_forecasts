moduleDir <- "modules"
usePrerun <- TRUE

source("01-packages.R")

source("02-init.R")
source("03-paths.R")
source("04-options.R")
source("05-google-ids.R")

if (delayStart > 0 & run == 1) {
  message(crayon::green("\nStaggered job start: delaying", runName, "by", delayStart, "minutes."))
  Sys.sleep(delayStart*60)
}

source("06-studyArea.R")
source("07a-dataPrep_2001.R")
source("07b-dataPrep_2011.R")

#####


studyAreas <- c("AB", "BC", "MB", "NT", "SK", "YT")

lapply(studyAreas, function(sA) {

  runNames <- paste0(sA, "_CCSM4_RCP85_run", 1:5)

  ##  TODO: annual? decadal?
  ##  1. summarize mean ignition prob values
  ##    a. create raster of mean values
  ##    b. histogram
  ##    c. `summary(simOut$fireSense_IgnitionPredicted[])`
  ##
  ##  2. summarize mean escape prob values
  ##    a. create raster of mean values
  ##    b. histogram
  ##    c. `summary(simOut$fireSense_EscapePredicted[])`
  ##
  ##  3. summarize mean spread prob values
  ##    a. create raster of mean values
  ##    b. histogram
  ##    c. `summary(simOut$fireSense_SpreadPredicted[])`
})

## - classify landscapee (leading/dominant veg type/species)
## - decid ==> conifer  &  conifer ==> conifer maps

## add additional scripts *e.g., to source functions) to the project dir's R/ subfolder
## - need to explicitly source the files there

## TODO ensure these functions get into a package! LandR
