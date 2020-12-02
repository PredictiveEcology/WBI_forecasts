switch(peutils::user(),
       "achubaty" = Sys.setenv(R_CONFIG_ACTIVE = "alex"),
       "ieddy" = Sys.setenv(R_CONFIG_ACTIVE = "ian"),
       Sys.setenv(R_CONFIG_ACTIVE = "test")
)
#Sys.getenv("R_CONFIG_ACTIVE") ## verify

source("01-init.R")
source("02-packages.R")
source("03-paths.R")
source("04-options.R")
source("05-objects.R")
source("06-studyArea.R")
source("07-dataPrep.R")
#source("08a-ignitionFit.R") ## TODO
#source("08b-escapeFit.R") ## TODO
source("08c-spreadFit.R")
