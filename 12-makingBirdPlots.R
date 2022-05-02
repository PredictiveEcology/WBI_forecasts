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

# Once all species are ready, we can change the list and re-run
# Species <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
#              "BARS", "BAWW", "BBCU", "BBWA", "BBWO", "BEKI", "BHCO", "BHVI",
#              "BLBW", "BLPW", "BOBO", "BOWA", "BRBL", "BRCR", "BTNW", "CAWA",
#              "CEDW", "CHSP", "CMWA", "COGR", "CORA", "COYE", "DOWO", "EAKI",
#              "EAPH", "EUST", "FOSP", "GCFL", "GCKI", "GCSP", "GRYE", "HAFL",
#              "HAWO", "HOLA", "HOSP", "HOWR", "KILL", "BBMA", "BCCH", "BLJA",
#              "BOCH", "CCSP", "CONW", "CSWA", "DEJU", "EVGR", "GCTH", "GRAJ",
#              "GRCA")

# When the next 12 get completed
# Species <- c("BBMA", "BCCH", "BLJA",
#              "BOCH", "CCSP", "CONW", "CSWA", "DEJU", "EVGR", "GCTH", "GRAJ",
#              "GRCA")

# When all species are completed
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

fileName <- file.path(Paths$outputPath, "allBirds_listPlotTable.qs")

if (!file.exists(fileName)) {
DT <- future_lapply(Species, function(BIRD){
  fileName <- file.path(Paths$outputPath,
                        paste0(BIRD, "_plotTable.qs"))
  if (!file.exists(fileName)){
    tic(paste0("Time elapsed for ", BIRD, ": "))
  DT <- lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(PV){
  fileName <- file.path(Paths$outputPath,
                        paste0(PV, "_", BIRD, "_summary.qs"))
  if (!file.exists(fileName)){
    message("Province ", PV, " for ", BIRD, " was still not processed. Skipping the species")
  } else {
    message("Processing ", PV, " for ", BIRD, ". Loading the table...")
    tic(paste0("Elapsed Time for loading table: "))
    TB <- qs::qread(fileName)
    toc()
    # Load Raster to Match
    templateRas <- file.path(Paths$inputPath, paste0(PV, "_birdTemplate.tif"))
    if (file.exists(templateRas)){
      rasterToMatch <- raster(templateRas)
    } else {
      pathRTM <- file.path(Paths$inputPath, paste0(PV, "_rtm.tif"))
      # rasterToMatch <- raster(pathRTM)
      if (file.exists(pathRTM)){
        rasterToMatch <- raster(pathRTM)
        rasterToMatch[!is.na(rasterToMatch)] <- 1
        names(rasterToMatch) <- paste0(PV, "_birdTemplate")
        raster::writeRaster(x = rasterToMatch, filename = templateRas)
      } else stop("RTM doesn't exist. Please run script 'source('06-studyArea.R')'")
    }

    if (BIRD == "CAWA"){ # REMOVE ONCE WORKSHOP STUFF IS READY <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CONVERT TO CAWA WHEN PUTTING TO RUN ALONE
      # 1. Make the uncertainty across reps and across climate models and SSP (per year) -- at first, only for CAWA to illustrate
      lapply(unique(TB[, Year]), function(Y){
        TB2 <- TB[Year == Y, ]
        TB2[, c("Mean", "SD") := list(mean(val),
                         sd(val)), by = "pixelID"]
        TB2 <- unique(TB2[, c("pixelID", "Mean", "SD")])
        fillTB <- data.table(pixelID = 1:ncell(rasterToMatch))
        TB3 <- merge(fillTB,
                     TB2,
                     by = "pixelID",
                     all.x = TRUE)
        setkey(TB3, "pixelID")
        meanRas <- rasterToMatch
        sdRas <- rasterToMatch
        meanRas[] <- TB3[, Mean]
        sdRas[] <- TB3[, SD]
        names(meanRas) <- paste0(BIRD, "_", PV, "_averageDensity")
        names(sdRas) <- paste0(BIRD, "_", PV, "_sdDensity")
        writeRaster(meanRas, file.path(Paths$outputPath, paste0(names(meanRas), ".tif")), format = "GTiff")
        writeRaster(sdRas, file.path(Paths$outputPath, paste0(names(sdRas), ".tif")), format = "GTiff")
      })

    } # REMOVE ONCE WORKSHOP STUFF IS READY
    # 2. Make the differences in density from 2011 to 2091 per pixel to put in boxplot -> This will be returned
    fileName <- file.path(Paths$outputPath,
                          paste0(BIRD, "_", PV, "_plotTable.qs"))
    if (!file.exists(fileName)) {
      tic(paste0("Elapsed Time for creating plot table for ", BIRD, " for ", PV, ": "))
      TB <- TB[Year %in% c(2011, 2091), ]
      TB[, Year := paste0("Year", Year)]
      TB <- dcast(TB, Species + climateModel + SSP + Province + Run + pixelID ~ Year, value.var = "val")
      TB[, diffDensity := Year2011 - Year2091, by = c("climateModel", "SSP", "Province", "Run", "pixelID")]
      # if (BIRD == "ALFL"){ # REMOVE ONCE WORKSHOP STUFF IS READY <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CONVERT TO CAWA WHEN PUTTING TO RUN ALONE
      #   # 3. Make a map of the differences in density from 2011 to 2091
      #   browser()
      # } # REMOVE ONCE WORKSHOP STUFF IS READY

      # As the full spectrum of data does not fit a normal data.table
      # we need to create the summary for the boxplot here
      # We will need:
      # 1. the first quartile (Q1, or 25th percentile)
      # 2. the third quartile (Q3, or 75th percentile)
      # 3. IQR (interquantile range, or Q3-Q1)
      # 4. the median (M)
      # 5. the minimum (minW, or Q1 – 1.5*IQR)
      # 6. the maximum (maxW, or Q1 + 1.5*IQR)
      # 6. lower outliers (lowOut, or any values < minW) ** These need to be in a separate table! I want to plot all the points themselves
      # 7. upper outliers (upOut, any values > maxW) ** These need to be in a separate table! I want to plot all the points themselves
      vals <- TB[, diffDensity]*6.25 # Here we convert density to abundance
      Q1 <- as.numeric(quantile(vals)["25%"])
      Q3 <- as.numeric(quantile(vals)["75%"])
      IQR <- Q3-Q1
      minW <- Q1 - 1.5*IQR
      maxW <- Q1 + 1.5*IQR
      DTsummary <- data.table(Species = BIRD,
                              Province = PV,
                              Q1 = Q1,
                              Q3 = Q3,
                              IQR = IQR,
                              Median = median(vals),
                              minW = minW,
                              maxW = maxW,
                              changedN = sum(vals),
                              Mean = mean(vals))
      lowOut <- unique(vals[vals < minW])
      DTlowOut <- data.table(Species = BIRD,
                             Province = PV,
                             lowOut = lowOut)
      upOut <- unique(vals[vals > maxW])
      DTupOut <- data.table(Species = BIRD,
                            Province = PV,
                            upOut = upOut)
      DT <- list(DTs = DTsummary,
           DTl = DTlowOut,
           DTu = DTupOut)
      qs::qsave(x = DT, file = fileName)
      toc()
    } else {
      DT <- qs::qread(fileName)
    }
return(DT)
  }
  })
  # Here you have the lists of all provinces for BIRD species
  # Need to collate all different lists together and save the tables
  # as a lists file
  toc()
  summaryDT <- rbindlist(lapply(DT, `[[`, "DTs"))
  outLowDT <- rbindlist(lapply(DT, `[[`, "DTl"))
  outUpDT <- rbindlist(lapply(DT, `[[`, "DTu"))
  DTorganized <- list(summaryDT = summaryDT,
                      outLowDT = outLowDT,
                      outUpDT = outUpDT)
  qs::qsave(x = DTorganized, file = fileName)
  } else {
    DT <- qs::qread(fileName)
  }
  return(DT)
})
summaryDT <- rbindlist(lapply(DT, `[[`, "summaryDT"))
outLowDT <- rbindlist(lapply(DT, `[[`, "outLowDT"))
outUpDT <- rbindlist(lapply(DT, `[[`, "outUpDT"))
DTorganized <- list(summaryDT = summaryDT,
                    outLowDT = outLowDT,
                    outUpDT = outUpDT)
qs::qsave(x = DTorganized, file = fileName)
} else {
  DT <- qs::qread(fileName)
}
# Here you have the lists of all provinces for all species
# Need to collate all different lists together and save the tables
# as a lists file and then make the box plot (something like)
ggplot(mydata.mine, aes(x = as.factor(group))) +
geom_boxplot(aes(
  lower = mean - sd,
  upper = mean + sd,
  middle = mean,
  ymin = mean - 3*sd,
  ymax = mean + 3*sd),
  stat = "identity")

# Once everything is ready, we upload the following to "1iOqbk1cr8vldm-doo5wUgcCsluG3Odmu":
# 1. Full tables and template maps for each bird and province: paste0(PV, "_", BIRD, "_summary.qs"); file.path(Paths$inputPath, paste0(PV, "_birdTemplate.tif"))
# 2. Summarized tables: file.path(Paths$outputPath, paste0(BIRD, "_plotTable.qs"))
# 3. Boxplot figures: STILL TO CREATE NAMING SYSTEM
# 4. Prediction maps script (make a function): template + table
