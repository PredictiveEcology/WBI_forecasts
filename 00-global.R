if (!require("Require", quietly = TRUE)) {
  install.packages("Require")
  library(Require)
}

Require("config")

saveOrLoad <- "" # type "load" here to do a manual override of Cache
switch(peutils::user(),
       "achubaty" = Sys.setenv(R_CONFIG_ACTIVE = "alex"),
       "ieddy" = Sys.setenv(R_CONFIG_ACTIVE = "ian"),
       "emcintir" = Sys.setenv(R_CONFIG_ACTIVE = "eliot"),
       Sys.setenv(R_CONFIG_ACTIVE = "test")
)
#Sys.getenv("R_CONFIG_ACTIVE") ## verify

theData <- "all.qs"
source("01-init.R")
source("02-packages.R")
source("03-paths.R")
source("04-options.R")
source("05-objects.R")
if (!saveOrLoad %in% "load") {
  source("06-studyArea.R")
  source("07-dataPrep.R")
  #source("08a-ignitionFit.R") ## TODO
  #source("08b-escapeFit.R") ## TODO
  a <- mget(ls())
  system.time(qs::qsave(x = a, preset = "fast", file = theData, nthreads = 2))
} else if (saveOrLoad == "load") {
  system.time(qs::qload(file = theData, nthreads = 2))
}

source("08c-spreadFit.R")
