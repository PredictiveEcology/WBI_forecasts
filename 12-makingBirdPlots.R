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
library("logr")
library("ggplot2")

source("02-init.R")
source("03-paths.R")
source("04-options.R")
maxLimit <- 20000 # in MB
on.exit(options(future.globals.maxSize = 500*1024^2))
options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
source("05-google-ids.R")
source("R/makeStudyArea_WBI.R")
do.call(setPaths, summaryPaths)
folderID <- "1iOqbk1cr8vldm-doo5wUgcCsluG3Odmu"

############################
overwriteFinalTable <- TRUE  # <~~~~~~~~~ ATTENTION
############################


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

whichReadySummary <- rbindlist(lapply(Species, function(BIRD){
  DT <- rbindlist(lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(PV){
    fileName <- file.path(Paths$outputPath,
                          paste0(PV, "_", BIRD, "_summary.qs"))
    return(data.table(Species = BIRD,
                      Province = PV,
                      Ready = file.exists(fileName)))
  }))
  return(DT)
}))

whichReadyPlots <- rbindlist(lapply(Species, function(BIRD){
  DT <- rbindlist(lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(PV){
    fileName <- file.path(Paths$outputPath,
                          paste0(BIRD, "_", PV, "_plotTable.qs"))
    # fileName <- file.path(Paths$outputPath,
    #                       paste0(PV, "_", BIRD, "_", "_summary.qs"))
    return(data.table(Species = BIRD,
                      Province = PV,
                      Ready = file.exists(fileName)))
  }))
  return(DT)
}))


##########################
# PREPARE SUMMARY TABLES #
##########################


fileName <- file.path(Paths$outputPath, "allBirds_listPlotTable.qs")
quick <- TRUE
plan("multicore", workers = length(Species))
if (any(!file.exists(fileName),
        overwriteFinalTable)) {
DT <- future_lapply(Species, function(BIRD){
  index <- which(Species == BIRD)
  fileName <- file.path(Paths$outputPath,
                        paste0(BIRD, "_plotTable.qs")) # <~~~~~ SHOULD REMOVE THESE
  if (any(quick,
          !file.exists(fileName))){
    message(paste0(fileName, " doesn't exists. Creating."))
    tic(paste0("Time elapsed for ", BIRD, ": "))
  DT <- lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(PV){
  fileName <- file.path(Paths$outputPath,
                        paste0(PV, "_", BIRD, "_summary.qs"))
  if (!file.exists(fileName)){
    message("Province ", PV, " for ", BIRD, " was still not processed. Skipping the species")
  } else {
    message("Processing ", PV, " for ", BIRD, ". Loading the table...")
    Sys.sleep((index-1)*10)
    TB <- qs::qread(fileName)
    toc()
    # Load Raster to Match
    templateRas <- file.path(Paths$inputPath, paste0(PV, "_birdTemplate.tif"))
    if (file.exists(templateRas)){
      rasterToMatch <- raster(templateRas)
    } else {
      pathRTM <- file.path(Paths$inputPath, paste0(PV, "_rtm.tif"))
      if (file.exists(pathRTM)){
        rasterToMatch <- raster(pathRTM)
        rasterToMatch[!is.na(rasterToMatch)] <- 1
        names(rasterToMatch) <- paste0(PV, "_birdTemplate")
        raster::writeRaster(x = rasterToMatch, filename = templateRas)
      } else stop("RTM doesn't exist. Please run script 'source('06-studyArea.R')'")
    }
    # 1. Make the uncertainty across reps and across climate models and SSP (per year)
      lapply(unique(TB[, Year]), function(Y){
        meanRasName <- paste0(BIRD, "_", PV, "_", Y, "_averageDensity")
        sdRasName <- paste0(BIRD, "_", PV, "_", Y, "_sdDensity")
        if (any(!file.exists(meanRasName),
                !file.exists(sdRasName))){
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
        names(meanRas) <- meanRasName
        names(sdRas) <- sdRasName
        writeRaster(meanRas, file.path(Paths$outputPath, paste0(meanRasName, ".tif")),
                    format = "GTiff", overwrite = TRUE)
        writeRaster(sdRas, file.path(Paths$outputPath, paste0(sdRasName, ".tif")),
                    format = "GTiff", overwrite = TRUE)
        }
      })
    # 2. Make the differences in density from 2011 to 2091 per pixel to put in boxplot -> This will be returned
    fileName <- file.path(Paths$outputPath,
                          paste0(BIRD, "_", PV, "_plotTable.qs")) # <~~~~~ SHOULD REMOVE THESE
    if (any(quick,
            !file.exists(fileName))) {
      message(paste0(fileName, " doesn't exists. Creating."))
      tic(paste0("Elapsed Time for creating plot table for ", BIRD, " for ", PV, ": "))
      TB <- TB[Year %in% c(2011, 2091), ]
      TB[, Year := paste0("Year", Year)]
      TB <- dcast(TB, Species + climateModel + SSP + Province + Run + pixelID ~ Year, value.var = "val")
      TB[, diffDensity := Year2011 - Year2091, by = c("climateModel", "SSP", "Province", "Run", "pixelID")]
      # 3. Make a map of the differences in density from 2011 to 2091
        meanRasName <- paste0(BIRD, "_", PV, "_meanDiffDensity")
        sdRasName <- paste0(BIRD, "_", PV, "_sdDiffDensity")
        if (any(!file.exists(meanRasName),
                !file.exists(sdRasName))){
          TB2 <- copy(TB)
          TB2[, c("Mean", "SD") := list(mean(diffDensity),
                                        sd(diffDensity)), by = "pixelID"]
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
          names(meanRas) <- meanRasName
          names(sdRas) <- sdRasName
          writeRaster(meanRas, file.path(Paths$outputPath, paste0(meanRasName, ".tif")),
                      format = "GTiff", overwrite = TRUE)
          writeRaster(sdRas, file.path(Paths$outputPath, paste0(sdRasName, ".tif")),
                      format = "GTiff", overwrite = TRUE)
        }
      # As the full spectrum of data does not fit a normal data.table
      # we need to create the summary for the boxplot here
      # We will need:
      # 1. the first quartile (Q1, or 25th percentile)
      # 2. the third quartile (Q3, or 75th percentile)
      # 3. IQR (interquantile range, or Q3-Q1)
      # 4. the median (M)
      # 5. the minimum (minW, or Q1 – 1.5*IQR)
      # 6. the maximum (maxW, or Q3 + 1.5*IQR)
      # 6. lower outliers (lowOut, or any values < minW) ** These need to be in a separate table! I want to plot all the points themselves
      # 7. upper outliers (upOut, any values > maxW) ** These need to be in a separate table! I want to plot all the points themselves
      vals <- TB[, diffDensity]*6.25 # Here we convert density to abundance
      Q1 <- as.numeric(quantile(vals)["25%"])
      Q3 <- as.numeric(quantile(vals)["75%"])
      IQR <- Q3-Q1
      minW <- Q1 - 1.5*IQR
      maxW <- Q3 + 1.5*IQR
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
    message(paste0(fileName, " exists. Returning."))
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
  message(paste0(fileName, " exists. Returning."))
  DTorganized <- qs::qread(fileName)
}
plan("sequential")

DTtoSave <- DTorganized[["summaryDT"]]
DTtoSave <- DTtoSave[, c("Species", "Province", "changedN")]
DTtoSave[, sumAbund := sum(changedN), by = "Province"]
DTtoSave[, c("Species", "changedN") := NULL]
DTtoSave <- unique(DTtoSave)
fNam <- file.path(Paths$outputPath, "summedAbund.csv")
write.csv(DTtoSave, fNam)
drive_upload(fNam, as_id("1iOqbk1cr8vldm-doo5wUgcCsluG3Odmu"))

# Here you have the lists of all provinces for all species
# Need to collate all different lists together and save the tables
# as a lists file and then make the box plot (something like)

##########################
#  P R E P A R E  PLOT   #
##########################


lapply(unique(DTorganized[["summaryDT"]][, Province]), function(PV){

  DTplot <- DTorganized[["summaryDT"]][Province == PV, ]
  low <- DTorganized[["outLowDT"]][Province == PV, ]
  high <- DTorganized[["outUpDT"]][Province == PV, ]
  nToUse <- 10
  low <- rbindlist(lapply(unique(low[["Species"]]), function(BIRD){
    toSample <- low[Species == BIRD, lowOut]
    if (length(toSample) < nToUse){
      l <- toSample
    } else {
      l <- sample(x = toSample,
                  size = nToUse,
                  replace = FALSE)
    }
    return(data.table(Species = BIRD,
                      Province = PV,
                      lowOut = l))
  }))
  high <- rbindlist(lapply(unique(high[["Species"]]), function(BIRD){
    toSample <- high[Species == BIRD, upOut]
    if (length(toSample) < nToUse){
      u <- toSample
    } else {
      u <- sample(x = toSample,
                  size = nToUse,
                  replace = FALSE)
    }
    return(data.table(Species = BIRD,
                      Province = PV,
                      upOut = u))
  }))
  # setkey(DTplot, "Mean")
  # levs <- DTplot[["Species"]]
  levs <- c("GCKI", "CHSP", "BBWA", "CMWA", "HOWR", "CEDW", "AMRE", "BRCR",
            "CAWA", "BCCH", "BBWO", "ATTW", "CCSP", "CONW", "BHVI", "BTNW",
            "HAFL", "CSWA", "HAWO", "COYE", "EVGR", "BAWW", "GCSP", "BLJA",
            "BLBW", "BBCU", "GCFL", "GRCA", "BOBO", "HOSP", "AMGO", "EAKI",
            "EAPH", "COGR", "HOLA", "BEKI", "DOWO", "KILL", "BBMA", "EUST",
            "FOSP", "ALFL", "BRBL", "BAOR", "GCTH", "BARS", "AMCR", "BHCO",
            "CORA", "ATSP", "GRYE", "AMRO", "BOCH", "GRAJ", "BOWA", "BLPW",
            "DEJU") # Levels based in AB
  DTplot[, Species := factor(Species, levels = levs)]
  DTplot[, Direction := as.factor(fifelse(changedN > 0,
                                          "Positive", "Negative"))]
  plot1 <- ggplot(data = DTplot,
                  aes(x = Species)) +
    geom_boxplot(mapping = aes(lower = Q1,
                               upper = Q3,
                               middle = Mean,
                               ymin = minW,
                               ymax = maxW,
                               fill = Direction),
                 stat = "identity") +
    geom_point(data = low,
               aes(y = lowOut),
               color = "lightgrey", alpha = 0.7) +
    geom_point(data = high,
               aes(y = upOut),
               color = "lightgrey", alpha = 0.7) +
    # scale_fill_manual(values = c("darkred", "forestgreen")) +
    labs(x = "Landbird Species",
         y = "Change in bird abundance per ha from 2011 to 2091",
         fill = paste0("Change in Mean Abundance in ", PV)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    theme_classic() +
    theme(legend.position = "bottom",
          legend.text = element_text(size = 12),
          axis.text = element_text(size = 12)) +
    coord_flip(ylim = c(-0.2, 0.2))
  plot1
  fileName <- file.path(Paths$outputPath,
                        paste0(PV,
                               "_changeInMeanAbundance.png"))
  ggsave(device = "png", filename = fileName,
         width = 10, height = 32)
  drive_upload(fileName, as_id(folderID))
})


##########################
# P R E P A R E  M A P S #
##########################


library("rasterVis")
library("gridExtra")
library("viridis")

Provinces <- c("AB", "BC", "SK", "MB", "YT", "NT")
Years <- seq(2011, 2091, by = 20)
overwriteMaps <- TRUE
lapply(Species, function(BIRD){
  lapply(Provinces, function(PV){
    meanFigPath <- paste0("Fig_", paste0(BIRD, "_", PV, "_meanDiffDensity"), ".png")
    sdFigPath <- paste0("Fig_", paste0(BIRD, "_", PV, "_sdDiffDensity"), ".png")
    lapply(c("meanFigPath", "sdFigPath"), function(pth){
      FigPath <- file.path(Paths$outputPath, get(pth))
      if (any(!file.exists(FigPath),
              overwriteMaps)){
        if (pth == "meanFigPath"){
          rasName <- paste0(BIRD, "_", PV, "_meanDiffDensity")
          subTitle <- paste0("Average difference in abundance from \n2011 to 2091 for ", BIRD," for ", PV)
        } else {
          rasName <- paste0(BIRD, "_", PV, "_sdDiffDensity")
          subTitle <- paste0("Difference uncertainty in \n", BIRD, " abundance from 2011 to 2091 for ", PV)
        }
        message("Creating difference map for ", BIRD, " for ", PV)
        # Load the tif
        mapPath <- file.path(Paths$outputPath,
                             paste0(rasName, ".tif"))
        # Here bring in all provinces to establish the scale
        rasNameTemp <- file.path(Paths$outputPath, paste0(BIRD, "_", Provinces, "_meanDiffDensity.tif"))
        oMapTemplateM <- lapply(rasNameTemp, raster::raster)
        maxValM <- round(max(unlist(lapply(oMapTemplateM, maxValue))), 3)
        minValM <- round(min(unlist(lapply(oMapTemplateM, minValue))), 3)
        lim <- max(abs(maxValM), abs(minValM))

        maxValM <- lim
        minValM <- -lim

        if (!file.exists(mapPath)) stop(paste0(mapPath,
                                               " doesn't exist. Is the location correct?"))
        originalMap <- raster::raster(mapPath)
        pal <- if (pth == "meanFigPath") RColorBrewer::brewer.pal(9, name = "RdYlGn") else heat.colors(9)
        png(filename = FigPath,
            width = 21, height = 29,
            units = "cm", res = 120)
        raster::plot(originalMap,
                     col = pal,
                     main = subTitle,
                     axes=FALSE, box=FALSE,
                     zlim = c(minValM, maxValM))
        dev.off()
      }
      if (!is.null(folderID))
      drive_upload(FigPath, as_id(folderID))
    })
  })
})


# Once everything is ready, we upload the following to "1iOqbk1cr8vldm-doo5wUgcCsluG3Odmu":
# 1. Full tables and template maps for each bird and province: paste0(PV, "_", BIRD, "_summary.qs"); file.path(Paths$inputPath, paste0(PV, "_birdTemplate.tif"))
# 2. Summarized tables: file.path(Paths$outputPath, paste0(BIRD, "_plotTable.qs"))
# 3. Boxplot figures: OK
# 4. Prediction maps script (make a function): template + table
