# Summarizing birds per province

# Setup

if (file.exists(".Renviron")) readRenviron(".Renviron")

pkgDir <- Sys.getenv("PRJ_PKG_DIR")
if (!nzchar(pkgDir)) {
  pkgDir <- "packages" ## default: use subdir within project directory
}
pkgDir <- normalizePath(
  file.path(pkgDir, version$platform, paste0(version$major, ".", strsplit(version$minor, "[.]")[[1]][1])),
  winslash = "/",
  mustWork = FALSE
)

if (!dir.exists(pkgDir)) {
  dir.create(pkgDir, recursive = TRUE)
}

.libPaths(pkgDir)
message("Using libPaths:\n", paste(.libPaths(), collapse = "\n"))

source("02-init.R")
source("03-paths.R")
source("04-options.R")
maxLimit <- 20000 # in MB
on.exit(options(future.globals.maxSize = 500*1024^2))
options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
message("Using libPaths:\n", paste(.libPaths(), collapse = "\n"))
library("Require")
library("data.table")
library("plyr")
library("pryr")
library("SpaDES.core")
library("archive")
library("googledrive")
library("httr")
library("raster")
library("usefulFuns")
library("caribouMetrics")
library("sf")
library("tictoc")



# Once all species are ready, we can change the list and re-run
Species <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
             "BARS", "BAWW", "BBCU", "BBWA", "BBWO", "BEKI", "BHCO", "BHVI",
             "BLBW", "BLPW", "BOBO", "BOWA", "BRBL", "BRCR", "BTNW", "CAWA",
             "CEDW", "CHSP", "CMWA", "COGR", "CORA", "COYE", "DOWO", "EAKI",
             "EAPH", "EUST", "FOSP", "GCFL", "GCKI", "GCSP", "GRYE", "HAFL",
             "HAWO", "HOLA", "HOSP", "HOWR", "KILL")

# When the next 12 get completed
# Species <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
#              "BARS", "BAWW", "BBCU", "BBWA", "BBWO", "BEKI", "BHCO", "BHVI",
#              "BLBW", "BLPW", "BOBO", "BOWA", "BRBL", "BRCR", "BTNW", "CAWA",
#              "CEDW", "CHSP", "CMWA", "COGR", "CORA", "COYE", "DOWO", "EAKI",
#              "EAPH", "EUST", "FOSP", "GCFL", "GCKI", "GCSP", "GRYE", "HAFL",
#              "HAWO", "HOLA", "HOSP", "HOWR", "KILL", "BBMA", "BCCH", "BLJA",
#              "BOCH", "CCSP", "CONW", "CSWA", "DEJU", "EVGR", "GCTH", "GRAJ",
#              "GRCA")

# When all species are completed
# Species <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
#              "BARS", "BAWW", "BBCU", "BBMA", "BBWA", "BBWO", "BCCH", "BEKI",
#              "BHCO", "BHVI", "BLBW", "BLJA", "BLPW", "BOBO", "BOCH", "BOWA",
#              "BRBL", "BRCR", "BTNW", "CAWA", "CCSP", "CEDW", "CHSP", "CMWA",
#              "COGR", "CONW", "CORA", "COYE", "CSWA", "DEJU", "DOWO", "EAKI",
#              "EAPH", "EUST", "EVGR", "FOSP", "GCFL", "GCKI", "GCSP", "GCTH",
#              "GRAJ", "GRCA", "GRYE", "HAFL", "HAWO", "HOLA", "HOSP", "HOWR",
#              "KILL", "LALO", "LCSP", "LEFL", "LEYE", "LISP", "MAWA", "MODO",
#              "MOWA", "NAWA", "NOFL", "NOWA", "OCWA", "OSFL", "OVEN", "PAWA",
#              "PHVI", "PIGR", "PISI", "PIWO", "PUFI", "RBGR", "RBNU", "RCKI",
#              "RECR", "REVI", "RUBL", "RUGR", "RWBL", "SAVS", "SEWR", "SOSA",
#              "SOSP", "SPSA", "SWSP", "SWTH", "TEWA", "TOSO", "TOWA", "TRES",
#              "VATH", "VEER", "VESP", "WAVI", "WBNU", "WCSP", "WETA", "WEWP",
#              "WIPT", "WISN", "WIWA", "WIWR", "WTSP", "WWCR", "YBFL", "YBSA",
#              "YEWA", "YHBL", "YRWA")


