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

source("02-init.R")
source("03-paths.R")
source("04-options.R")
maxLimit <- 20000 # in MB
on.exit(options(future.globals.maxSize = 500*1024^2))
options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
do.call(setPaths, summaryPaths)

Species <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
             "BARS", "BAWW", "BBCU", "BBMA", "BBWA", "BBWO", "BCCH", "BEKI",
             "BHCO", "BHVI", "BLBW", "BLJA", "BLPW", "BOBO", "BOCH", "BOWA",
             "BRBL", "BRCR", "BTNW", "CAWA", "CCSP", "CEDW", "CHSP", "CMWA",
             "COGR", "CONW", "CORA", "COYE", "CSWA", "DEJU", "DOWO", "EAKI",
             "EAPH", "EUST", "EVGR", "FOSP", "GCFL", "GCKI", "GCSP", "GCTH",
             "GRAJ", "GRCA", "GRYE", "HAFL", "HAWO", "HOLA", "HOSP", "HOWR",
             "KILL", "LALO", "LCSP", "LEFL", "LEYE", "LISP", "MAWA", "MODO",
             "MOWA", "NAWA", "NOFL", "NOWA", "OCWA", "OSFL", "OVEN", "PAWA",
             "PHVI", "PIGR", "PISI", "PIWO", "PUFI", "RBGR", "RBNU", "RCKI",
             "RECR", "REVI", "RUBL", "RUGR", "RWBL", "SAVS", "SEWR", "SOSA",
             "SOSP", "SPSA", "SWSP", "SWTH", "TEWA", "TOSO", "TOWA", "TRES",
             "VATH", "VEER", "VESP", "WAVI", "WBNU", "WCSP", "WETA", "WEWP",
             "WIPT", "WISN", "WIWA", "WIWR", "WTSP", "WWCR", "YBFL", "YBSA",
             "YEWA", "YHBL", "YRWA")

# Anything to Cleanup?
# Data.table of the
# alternative: NULL
doCleanup <- data.table(climateModel = "CanESM5",
                        SSP = c("SSP370", "SSP585"),
                        Province = "NT",
                        Run = "run01")

tic("Total elapsed time: ")
allBirds <- lapply(Species, function(BIRD){
  message(paste0("Running provinces for ", BIRD))
  tic(paste0("Total elapsed time for ", BIRD))
  plan("multicore")
  allP <- future_lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(P) {
    fileName <- file.path(Paths$outputPath,
                          paste0(P, "_", BIRD, "_summary.qs"))
    tic(paste0("Finished for ", P, " for ", BIRD, " (",
               which(Species == BIRD), " of ", length(Species),
               "). ELAPSED TIME: "))
    if (!file.exists(fileName)){
      allRuns <- rbindlist(lapply(c(paste0("run0", 1:5)), function(RP) {
        allCS <- rbindlist(lapply(c("CanESM5", "CNRM-ESM2-1"), function(CS) {
          allSS <- rbindlist(lapply(c("SSP370", "SSP585"), function(SS) {
            runName <- paste(P, CS, SS, RP, sep = "_")
            print(paste0("Running ", runName))
            setPaths(inputPath = file.path(getwd(), "outputs", P, "posthoc"))
            # Derive parameters from runName
            scenario <- runName
            Run <- strsplit(runName, split = "_")[[1]][4]
            Province <- strsplit(runName, split = "_")[[1]][1]
            ClimateModel <- strsplit(runName, split = "_")[[1]][2]
            RCP <- strsplit(runName, split = "_")[[1]][3]
            # Determine study area long name
            studyAreaLongName <- switch(studyAreaName,
                                        AB = "Alberta",
                                        BC = "British Columbia",
                                        SK = "Saskatchewan",
                                        MB = "Manitoba",
                                        NT = "Northwest Territories & Nunavut",
                                        NU = "Northwest Territories & Nunavut",
                                        YT = "Yukon",
                                        RIA = "RIA")

            allY <- rbindlist(lapply(seq(2011, 2091, by = 20), function(Y) {

              # File Structure in Paths$inputPath "AB_CanESM5_SSP370_run02_predicted_RWBL_Year2071.tif"

              # 1. Get each map for the specific prov, CS, SSP, Year, run, species
              # 2. Extract the values per pixel
              # 3. Put in a table with the following columns:
              #     Species, ClimateModel, SSP, Province, Year, Run, PixelID, val
              ras <- grepMulti(x = list.files(path = Paths$inputPath, full.names = TRUE), patterns = paste(P, CS, SS, RP, "predicted",
                                                                                                           BIRD, paste0("Year", Y, ".tif"),
                                                                                                           sep = "_"),
                               unwanted = "aux.xml")

              if (length(ras) == 0) stop(paste0("Raster ", ras, " not found. Please check the file exists"))
              ras <- raster(ras)
              DT <- na.omit(data.table(Species = BIRD,
                                       climateModel = CS,
                                       SSP = SS,
                                       Province = P,
                                       Year = Y,
                                       Run = RP,
                                       pixelID = seq(1:ncell(ras)),
                                       val = getValues(ras)))
              return(DT)
            }))
            gc()
            return(allY)
          }))
        }))
      }))
      qs::qsave(allRuns, file = fileName)
      gc()
    } else {
     if (all(!is.null(doCleanup),
             P %in% unique(doCleanup[["Province"]]))){
       whatToCleanup <- doCleanup[Province == P, ]
       # 1. Cleanup any wrong runs
       # 1.2. Use the table whatToCleanup to remove specific rows
       oldRuns <- qs::qread(fileName)
       for (index in 1:NROW(whatToCleanup)){
         oldRuns <- oldRuns[!(climateModel == whatToCleanup[index, climateModel] &
                                       SSP == whatToCleanup[index, SSP] &
                                       Province == whatToCleanup[index, Province] &
                                       Run == whatToCleanup[index, Run]), ]
       }
       # 2. Incorporate the missing ones (based on what was specified!) in the
       # original table
      nReps <- unique(whatToCleanup[["Run"]])
      nClim <- unique(whatToCleanup[["climateModel"]])
      nSSP <- unique(whatToCleanup[["SSP"]])
       newRuns <- rbindlist(lapply(nReps, function(RP) {
         allCS <- rbindlist(lapply(nClim, function(CS) {
           allSS <- rbindlist(lapply(nSSP, function(SS) {
             runName <- paste(P, CS, SS, RP, sep = "_")
             print(paste0("Re-running ", runName))
             setPaths(inputPath = file.path(getwd(), "outputs", P, "posthoc"))
             # Derive parameters from runName
             scenario <- runName
             Run <- strsplit(runName, split = "_")[[1]][4]
             Province <- strsplit(runName, split = "_")[[1]][1]
             ClimateModel <- strsplit(runName, split = "_")[[1]][2]
             RCP <- strsplit(runName, split = "_")[[1]][3]
             # Determine study area long name
             studyAreaLongName <- switch(studyAreaName,
                                         AB = "Alberta",
                                         BC = "British Columbia",
                                         SK = "Saskatchewan",
                                         MB = "Manitoba",
                                         NT = "Northwest Territories & Nunavut",
                                         NU = "Northwest Territories & Nunavut",
                                         YT = "Yukon",
                                         RIA = "RIA")

             allY <- rbindlist(lapply(seq(2011, 2091, by = 20), function(Y) {

               # File Structure in Paths$inputPath "AB_CanESM5_SSP370_run02_predicted_RWBL_Year2071.tif"

               # 1. Get each map for the specific prov, CS, SSP, Year, run, species
               # 2. Extract the values per pixel
               # 3. Put in a table with the following columns:
               #     Species, ClimateModel, SSP, Province, Year, Run, PixelID, val
               ras <- grepMulti(x = list.files(path = Paths$inputPath, full.names = TRUE),
                                patterns = paste(P, CS, SS, RP, "predicted",
                                                 BIRD, paste0("Year", Y, ".tif"),
                                                 sep = "_"),
                                unwanted = "aux.xml")

               if (length(ras) == 0) stop(paste0("Raster ", ras,
                                                 " not found. Please check",
                                                 "the file exists"))
               ras <- raster(ras)
               DT <- na.omit(data.table(Species = BIRD,
                                        climateModel = CS,
                                        SSP = SS,
                                        Province = P,
                                        Year = Y,
                                        Run = RP,
                                        pixelID = seq(1:ncell(ras)),
                                        val = getValues(ras)))
               return(DT)
             }))
             gc()
             return(allY)
           }))
         }))
       }))
       # Put together both tables and save
       newRuns <- rbind(oldRuns, newRuns, use.names = TRUE)
       setkey(newRuns, "climateModel", "SSP", "Year", "Run", "pixelID")
       qs::qsave(newRuns, file = fileName)
       gc()
     } else allRuns <- NA
    }
    toc()
    gc()
    return(allRuns)
}),
future.seed = NULL)
  plan("sequential")
  toc()
})
toc()

