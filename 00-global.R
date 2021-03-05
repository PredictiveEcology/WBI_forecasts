if (!suppressWarnings(require("Require"))) {
  install.packages("Require")
  library(Require)
}

if (FALSE) {
  Require::Require("PredictiveEcology/SpaDES.install (>= 0.0.4)")
  out <- makeSureAllPackagesInstalled(modulePath = "modules")
}

saveOrLoad <- "load" # type "load" here to do a manual override of Cache
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
source("05-objects.R")

theData <- file.path("outputs", paste0("all_", studyAreaName, ".qs"))
if (!saveOrLoad %in% "load") {
  source("06-studyArea.R")
  source("07-dataPrep.R")

  if (exists("a", .GlobalEnv)) rm(a, envir = .GlobalEnv)
  if (identical(fSdataPrepParams$fireSense_dataPrepFit, "fireSense_SpreadFit")) {
    objsNeeded <- inputObjects(module = "fireSense_SpreadFit", path = spreadFitPaths$modulePath)[[1]]$objectName
    objsNeeded <- setdiff(objsNeeded, "parsKnown")
  } else if  (identical(fSdataPrepParams$fireSense_dataPrepFit$whichModulesToPrepare,
                        "fireSense_IgnitionFit")) {
    objsNeeded <- inputObjects(module = "fireSense_IgnitionFit", path = ignitionFitPaths$modulePath)[[1]]$objectName
    objsNeeded <- union(objsNeeded, "fireSense_ignitionFormula")
  }
  simDataPrep <- mget(objsNeeded, envir = envir(simDataPrep))
  a <- list("simDataPrep" = simDataPrep)
  system.time(qs::qsave(x = a, preset = "fast", file = theData, nthreads = 2))
} else if (saveOrLoad == "load") {
  message("Loading data from ", theData)
  system.time(qs::qload(file = theData, nthreads = 2))
}

source("08a-ignitionFit.R") ## TODO
#source("08b-escapeFit.R") ## TODO
#source("08c-spreadFit.R")
