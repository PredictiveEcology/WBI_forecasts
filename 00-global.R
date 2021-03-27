if (!exists("pkgDir")) {
  pkgDir <- file.path("packages", version$platform, paste0(version$major, ".",
                                                           strsplit(version$minor, "[.]")[[1]][1]))

  if (!dir.exists(pkgDir)) {
    dir.create(pkgDir, recursive = TRUE)
  }
  .libPaths(pkgDir)
}

if (!suppressWarnings(require("Require"))) {
  install.packages("Require")
  library(Require)
}

if (FALSE) {
  Require::Require("PredictiveEcology/reproducible@CopyGenericChange (>= 1.2.6.9011)") ## 2021-03-17
  Require::Require("PredictiveEcology/SpaDES.core@rasterToMemoryUpdates (>= 1.0.6.9022)") ## 2021-03-17

  Require::Require("PredictiveEcology/fireSenseUtils@development (>= 0.0.4.9050)", require = FALSE) ## force pemisc and others to be installed correctly

  Require::Require("PredictiveEcology/SpaDES.install (>= 0.0.2)")
  out <- makeSureAllPackagesInstalled(modulePath = "modules")
}

switch(Sys.info()[["user"]],
       "achubaty" = Sys.setenv(R_CONFIG_ACTIVE = "alex"),
       "ieddy" = Sys.setenv(R_CONFIG_ACTIVE = "ian"),
       "emcintir" = Sys.setenv(R_CONFIG_ACTIVE = "eliot"),
       Sys.setenv(R_CONFIG_ACTIVE = "test")
)
#Sys.getenv("R_CONFIG_ACTIVE") ## verify

source("01-init.R")
source("02-paths.R")
source("03-packages.R")
source("04-options.R")
#source("05-google-ids.R") ## gets sourced at top of each script 06, 07x, 08x

if (delayStart > 0) {
  message(crayon::green("\nStaggered job start: delaying by", delayStart, "minutes."))
  Sys.sleep(delayStart*60)
}

source("06-studyArea.R")

source("07a-dataPrep_2001.R")
source("07b-dataPrep_2011.R")
source("07c-dataPrep_fS.R")

source("08a-ignitionFit.R")
source("08b-escapeFit.R")
source("08c-spreadFit.R")

source("09-main-sim.R")
