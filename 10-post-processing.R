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

