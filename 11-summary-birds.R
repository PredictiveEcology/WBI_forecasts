moduleDir <- "modules"

source("01-packages.R")

Require(c("caribouMetrics", "future", "future.apply", "raster", "sf", "tictoc", "usefulFuns"))

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

tic("Total elapsed time: ")
allBirds <- lapply(Species, function(BIRD){
  message(paste0("Running provinces for ", BIRD))
  tic(paste0("Total elapsed time for ", BIRD))
  plan("multicore")
  allP <- future_lapply(c("AB", "BC", "SK", "MB", "YT", "NT"), function(P) {
    fileName <- file.path(summaryPaths$outputPath, paste0(P, "_", BIRD, "_summary.qs"))

    tic(paste0("Finished for ", P, " for ", BIRD, " (",
               which(Species == BIRD), " of ", length(Species),
               "). ELAPSED TIME: "))
    if (!file.exists(fileName)) {
      allRuns <- rbindlist(lapply(c(paste0("run0", 1:5)), function(RP) {
        allCS <- rbindlist(lapply(c("CanESM5", "CNRM-ESM2-1"), function(CS) {
          allSS <- rbindlist(lapply(c("SSP370", "SSP585"), function(SS) {
            runName <- paste(P, CS, SS, RP, sep = "_")
            print(paste0("Running ", runName))
            setPaths(inputPath = file.path("outputs", P, "posthoc"))
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
                               patterns = paste(P, CS, SS, RP, "predicted", BIRD, paste0("Year", Y, ".tif"), sep = "_"),
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
      allRuns <- NA
    }
    toc()
    gc()
    return(allRuns)
  }, future.seed = NULL)
  plan("sequential")
  toc()
})
toc()

# Once all birds have been ran we need to lapply over them, and over Provinces and
# make summaries? Or just use the boxplot approach?
# Or a boxplot of the difference between 2011 and 2091
# Then make maps of the change through time --> gif (all Provs together)
