# Summarizing Caribou population growth per province

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

grepMulti <- function(x, patterns, unwanted = NULL) {
  rescued <- sapply(x, function(fun) all(sapply(X = patterns, FUN = grepl, fun)))
  recovered <- x[rescued]
  if (!is.null(unwanted)){
    discard <- sapply(recovered, function(fun) all(sapply(X = unwanted, FUN = grepl, fun)))
    afterFiltering <- recovered[!discard]
    return(afterFiltering)
  } else {
    return(recovered)
  }
}

moduleDir <- "modules"

.libPaths(pkgDir)
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
library("future")
library("future.apply")
library("logr")

source("02-init.R")
source("03-paths.R")
source("04-options.R")
maxLimit <- 20000 # in MB
on.exit(options(future.globals.maxSize = 500*1024^2))
options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
do.call(setPaths, posthocPaths)

folderID <- "1N-rszTpDTlsMm-VTyymuF2-02EKexD_k"
# 1. Upload the files to Google Drive
# 2. Make the plots for each Province (should have a function ready for
# uncertainty comming from different climate models)

source("R/plotCaribouPopGrowth_WBI.R")
fullTable <- rbindlist(lapply(c("AB", "BC", "SK", "MB", "NT"), function(PV){
  # NOTE WE DON'T HAVE CARIBOU HERD IN YUKON. THEY ARE CLASSIFIED AS FROM NT HERDS
  climateModel <- c("CanESM5_SSP370", "CanESM5_SSP585",
                    "CNRM-ESM2-1_SSP370", "CNRM-ESM2-1_SSP585")
  resultsMainFolder <- gsub(x = Paths$outputPath,
                            pattern = "AB",
                            replacement = PV)
  outputFolder <- file.path(dirname(dirname(Paths$outputPath)),
                            "summary")
  province <- PV
  currentTime <- 2091
  endTime <- 2091
  rowsLeg <- switch(EXPR = PV,
                    "AB" = 6,
                    "BC" = 3,
                    "SK" = 2,
                    "NT" = 1,
                    "MB" = 7)
  print(paste0("Making caribou plots for ", PV))
  tb <- plotCaribouPopGrowth_WBI(climateModel = climateModel,
                                 rowsLegend = rowsLeg,
                                 uploadPlots = folderID,
                                   resultsMainFolder = resultsMainFolder,
                                   outputFolder = outputFolder,
                                   province = province,
                                   currentTime = currentTime,
                                   endTime = endTime)
  return(tb)
  }))
fileName <- file.path(dirname(dirname(Paths$outputPath)), "summary",
          "averageLambdaPerHerd.csv")
write.csv(fullTable, file = fileName)
drive_upload(fileName, as_id(folderID))

