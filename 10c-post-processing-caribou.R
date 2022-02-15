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
#source("07a-dataPrep_2001.R")
source("07b-dataPrep_2011.R")
