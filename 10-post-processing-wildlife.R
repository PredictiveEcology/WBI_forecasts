############################################
#                                          #
#    P O S T H O C     W I L D L I F E     #
#                                          #
############################################
# source("01a-packages-libPath.R")

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


for (RP in c(paste0("run0", 1:5))) {
  for (CS in c("CanESM5", "CNRM-ESM2-1")) {
    for (SS in c("SSP370", "SSP585")) {
      for (P in c("AB", "BC", "SK", "MB", "YT", "NT")) {
        fls <- list.files(paste0("~/GitHub/WBI_forecasts/outputs/", P, "/posthoc/"))

        if (length(fls) != 0) {

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

          allFls <- grepMulti(fls,
                              patterns = c(RP, CS, SS, P),
                              unwanted = ".aux.xml")
          if (length(allFls) == 115*5){
            message(crayon::green(paste0("Simulations done for:", paste(P, SS, CS, RP, collapse = " "))))
            next
          }
        }
        message(crayon::yellow(paste0("Simulations starting for:", paste(P, SS, CS, RP, collapse = " "))))

        runName <- paste(P, CS, SS, RP, sep = "_")

        moduleDir <- "modules"

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
          # On March 1st this is trying to install reproducible. I don't want it!!!
          # Require(c("data.table", "plyr", "pryr",
          #           "PredictiveEcology/LandR@development", ## TODO: workaround weird raster/sf method problem
          #           "PredictiveEcology/SpaDES.core@development (>= 1.0.10.9002)",
          #           "archive", "config", "googledrive", "httr", "slackr"), upgrade = FALSE)
        tic(paste0("Finished for ", runName, ". ELAPSED TIME: "))
        source("02-init.R")
        source("03-paths.R")
        source("04-options.R")
        maxLimit <- 20000 # in MB
        on.exit(options(future.globals.maxSize = 500*1024^2))
        options(future.globals.maxSize = maxLimit*1024^2) # Extra option for this specific case, which uses approximately 6GB of layers
        source("05-google-ids.R")
        source("R/makeStudyArea_WBI.R")
        source("R/birdPredictionCoresCalc_WBI.R")
        source("R/checkBirdsAvailable_WBI.R")
        source("modules/birdsNWT/R/loadStaticLayers.R")
        source("R/rstCurrentBurnListGenerator_WBI.R")
        Require("raster")
        stepCacheTag <- c(paste0("cache:10b"),
                          paste0("runName:", runName))

        do.call(setPaths, posthocPaths)

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

        # RTM

        pathRTM <- file.path(Paths$inputPath, paste0(studyAreaName, "_rtm.tif"))

        if (file.exists(pathRTM)){
          rasterToMatch <- raster(pathRTM)
        } else stop("RTM doesn't exist. Please run script 'source('06-studyArea.R')'")

        # Make RTM have only 1's
        rasterToMatch[!is.na(rasterToMatch)] <- 1

        # STUDY AREA

        pathSA <- file.path(Paths[["inputPath"]], paste0(studyAreaName, "_SA.qs"))

        if (file.exists(pathSA)){
          studyArea <- qs::qread(pathSA)
        } else {
          studyArea <- makeStudyArea(studyAreaName)
        }
        ## Calculate number of cores and divide in groups if needed
        birdSpecies <- checkBirdsAvailable_WBI(whichRun = Run)

        cores <- if (NROW(birdSpecies) < 4)
          NROW(birdSpecies) else
            birdPredictionCoresCalc_WBI(birdSpecies = birdSpecies[["Species"]],
                                        sizeGbEachProcess = 8)
        # Defining model version
        if (!exists("birdModelVersion")) birdModelVersion <- c("reducedBAM") # Default if not provided
        predictionInterval <- 20

        urlStaticLayers <- "https://drive.google.com/drive/u/0/folders/1RPXqgq-M1mOKMYzUnVSpw_6sjJ4m07dj"

        pixelsWithDataAtInitialization <- Cache(loadStaticLayers,
                                                fileURL = urlStaticLayers, # Add Cache when fun is ready
                                                pathData = Paths[["inputPath"]],
                                                studyArea = studyArea,
                                                rasterToMatch = rasterToMatch,
                                                Province = Province,
                                                version = birdModelVersion,
                                                allVariables = "Structure_Biomass_TotalLiveAboveGround_v1",
                                                staticLayersNames = "Structure_Biomass_TotalLiveAboveGround_v1",
                                                userTags = c(stepCacheTag, "objectName:pixelsWithDataAtInitialization"))

        pixelsWithDataAtInitialization <- which(pixelsWithDataAtInitialization[] != 0)

        ############ WATER and WETLAND PREP WITH LCC LAYER #########

        # Latifovic, R., Pouliot, D., and Olthof, I., (2017) Circa 2010 Land Cover of Canada: Local Optimization Methodology and Product
        # Development. Remote Sensing, 2017, 9(11), 1098; http://www.mdpi.com/2072-4292/9/11/1098, describes the methodology Canada used to
        # produce the Landcover of Canada data included in this data set.
        #
        # The following list describes the display of land cover classification in the .tif file:
        # Value 1, Temperate or sub-polar needleleaf forest, RGB 0 61 0;
        # Value 2, Sub-polar taiga needleleaf forest, RGB 148 156 112;
        # Value 3, Tropical or sub-tropical broadleaf evergreen forest, RGB 0 99 0;
        # Value 4, Tropical or sub-tropical broadleaf deciduous forest, RGB 30 171 5;
        # Value 5, Temperate or sub-polar broadleaf deciduous forest, RGB 20 140 61;
        # Value 6, Mixed forest, RGB 92 117 43;
        # Value 7, Tropical or sub-tropical shrubland, RGB 179 158 43;
        # Value 8, Temperate or sub-polar shrubland, RGB 179 138 51;
        # Value 9, Tropical or sub-tropical grassland, RGB 232 220 94;
        # Value 10, Temperate or sub-polar grassland, RGB 225 207 138;
        # Value 11, Sub-polar or polar shrubland-lichen-moss, RGB 156 117 84;
        # Value 12, Sub-polar or polar grassland-lichen-moss, RGB 186 212 143;
        # Value 13, Sub-polar or polar barren-lichen-moss, RGB 64 138 112;
        # Value 14, Wetland, RGB 107 163 138;
        # Value 15, Cropland, RGB 230 174 102;
        # Value 16, Barren lands, RGB 168 171 174;
        # Value 17, Urban, RGB 220 33 38;
        # Value 18, Water, RGB 76 112 163;
        # Value 19, Snow and Ice, RGB 255 250 255.

        # Important ones:
        waterValues <- 18
        wetlandValues <- 14
        forestValues <- 1:6 # Forests
        uplandValues <- c(forestValues,
                          7:13, # Shrubland, grassland
                          15:17, # Cropland, barren and Urban
                          19) # Ice and snow

        landcoverMap <- Cache(LandR::prepInputsLCC, destinationPath = Paths$inputPath,
                              studyArea = studyArea,
                              rasterToMatch = rasterToMatch,
                              filename2 = paste0("LCC_", Province, ".tif"),
                              userTags = c("objectName:landcoverMap",
                                           stepCacheTag,
                                           "outFun:Cache"),
                              omitArgs = c("destinationPath", "filename2"))

        watersVals <- raster::getValues(landcoverMap)

        watersValsToChange <- watersVals
        watersValsToChange[!is.na(watersValsToChange) & !watersValsToChange %in% waterValues] <- NA
        waterRaster <- raster::setValues(x = landcoverMap, watersValsToChange)
        waterRaster[!is.na(waterRaster)] <- 1

        watersValsToChange <- watersVals
        watersValsToChange[!is.na(watersValsToChange) & !watersValsToChange %in% wetlandValues] <- NA
        wetlandsRaster <- raster::setValues(x = landcoverMap, watersValsToChange)
        wetlandsRaster[!is.na(wetlandsRaster)] <- 1

        watersValsToChange <- watersVals
        watersValsToChange[!is.na(watersValsToChange) & !watersValsToChange %in% uplandValues] <- NA
        uplandsRaster <- raster::setValues(x = landcoverMap, watersValsToChange)
        uplandsRaster[!is.na(uplandsRaster)] <- 1

        watersValsToChange <- watersVals
        watersValsToChange[!is.na(watersValsToChange) & !watersValsToChange %in% forestValues] <- NA
        forestOnly <- raster::setValues(x = landcoverMap, watersValsToChange)
        forestOnly[!is.na(forestOnly)] <- 1

        bSpG <- birdSpecies[Species %in% cores[["birdSpecies"]][["Group1"]], Species]
        # Add Parameters
        parameters <- list(
          birdsNWT = list(
            "predictLastYear" = FALSE,
            "lowMem" = TRUE,
            "scenario" = scenario, # composed by 2letterProvince_climateModel_SSP_runX
            "useStaticPredictionsForNonForest" = TRUE,
            "useOnlyUplandsForPrediction" = TRUE,
            "baseLayer" = 2010,
            "overwritePredictions" = FALSE,
            "useTestSpeciesLayers" = FALSE, # Set it to false when you actually have results from
            # LandR_Biomass simulations to run it with
            "predictionInterval" = predictionInterval,
            "nCores" = length(bSpG), #"auto", # If not to parallelize, use 1
            "version" = birdModelVersion,
            "RCP" = RCP,
            "climateModel" = ClimateModel,
            "climateResolution" = NULL,
            "climateFilePath" = NULL
          ),
          caribouPopGrowthModel = list(
            ".plotInitialTime" = NULL,
            "climateModel" = ClimateModel,
            "useFuture" = FALSE,
            "recoveryTime" = 40,
            ".useDummyData" = FALSE,
            ".growthInterval" = 10,
            "recruitmentModelVersion" = "Johnson", # Johnson or ECCC
            "recruitmentModelNumber" = "M4",
            "femaleSurvivalModelNumber" = c("M1", "M4") # M1:M5 --> best models: M1, M4
          )
          # ATTENTION: recruitmentModelNumber and recruitmentModelVersion need to be paired. ie.
          # if you want to run M3 from ECCC and M1 and M4 from Johnson you should put these as
          #     "recruitmentModelVersion" = c("ECCC", "Johnson", "Johnson"),
          #     "recruitmentModelNumber" = c("M3", "M1", "M4"),
          # otherwise it will repeat the recruitmentModelVersion for all recruitmentModelNumber
        )

        # Modules
        modules <- list("birdsNWT", "caribouPopGrowthModel")

        # Set simulation times
        Times <- list(start = 2011, end = 2091)

        # Setting some inputs before changing input path
        zipClimateDataFilesFolder <- file.path(Paths[["inputPath"]], "climate/future")
        climateDataFolder <- checkPath(file.path(Paths[["inputPath"]],
                                                 "climate/future", "climate_MSY"),
                                       create = TRUE)

        # Reset input paths to the folder where simulation outputs are
        setPaths(inputPath = file.path(getwd(), "outputs", runName)) # THIS IS THE ORIGINAL FOR WHEN THE RUNS ARE DONE

        rstCurrentBurnList <-  rstCurrentBurnListGenerator_WBI(pathInputs = Paths$inputPath)

        # Add objects
        objects <- list(
          "studyArea" = studyArea,
          "rasterToMatch" = rasterToMatch,
          # "usrEmail" = ifelse(Sys.info()[["user"]] == "tmichele",
          #                     "tati.micheletti@gmail.com",
          #                     NULL),
          "usrEmail" = config::get("cloud")[["googleuser"]],
          "waterRaster" = waterRaster,
          "wetlandsRaster" = wetlandsRaster,
          "uplandsRaster" = uplandsRaster,
          "zipClimateDataFilesFolder" = zipClimateDataFilesFolder,
          "climateDataFolder" = climateDataFolder, # Currently here, but should be moved to below
          "pixelsWithDataAtInitialization" = pixelsWithDataAtInitialization,
          "studyAreaLongName" = studyAreaLongName, # For annual climate variables
          "urlStaticLayers" = urlStaticLayers,
          "urlModels" = birdSpecies, # birdSpecies[Species %in% cores[["birdSpecies"]][["Group1"]], ],
          "birdsList" = bSpG,
          "rstLCC" = landcoverMap,
          "sppEquiv" = LandR::sppEquivalencies_CA, # Loading species equivalency table
          "sppEquivCol" = "KNN",
          "forestOnly" = forestOnly,
          "rstCurrentBurnList" = rstCurrentBurnList,
          "runName" = runName,
          "shortProvinceName" = Province
        )

        outputsBoo <- data.frame(objectName = c("predictedCaribou",
                                                "disturbances"),
                                 file = c(paste0("predictedCaribou_Year2091_", runName),
                                          paste0("disturbances_Year2091_", runName)),
                                 saveTime = Times$end)

        message(crayon::yellow(paste0("Starting simulations for BIRDS and BOO using ",
                                      paste(ClimateModel, RCP, collapse = " "),
                                      " for ", Province, " (", Run, ")")))

        simOut <- simInitAndSpades(times = Times,
                                   params = parameters,
                                   modules = modules,
                                   objects = objects,
                                   paths = Paths,
                                   outputs = outputsBoo,
                                   loadOrder = unlist(modules))

        toc()
      }
    }
  }
}

