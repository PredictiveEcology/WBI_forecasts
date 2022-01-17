
#the validation process is fairly simple - save each predicted ignition raster
#based on the historical data (we use the same cohortData objects, but not aggregated)
#this requires running dataPrepFit/ignitionPredict twice, with 2001 and 2011 data

#this isn't a polished script so I don't recommend including it in any workflow yet


#step one - run fireSense_dataPrepPredict but don't aggregate rasters, and save the outputs every year.
#### 2011 run ####
rep <- 'fixedUB'
validationPaths <- list(modulePath = "modules",
                        inputPath =  ignitionFitPaths$inputPath,
                        outputPath = file.path(ignitionFitPaths$outputPath,
                                               paste0("ignition_validation", rep)),
                        cachePath = ignitionFitPaths$cachePath)
do.call(setPaths, validationPaths)


validationModules <- list("fireSense_dataPrepPredict",
                       "fireSense_ignitionPredict")
validationObjects <- list(
  climateComponentsTouse = fSsimDataPrep$climateComponentsToUse,
  cohortData = fSsimDataPrep$cohortData2011, #for latter half
  covMinMax_ignition = ignitionOut$covMinMax_ignition, #new object
  flammableRTM = fSsimDataPrep$flammableRTM,
  fireSense_IgnitionFitted = ignitionOut$fireSense_IgnitionFitted,
  landcoverDT = fSsimDataPrep$landcoverDT,
  nonForest_timeSinceDisturbance = fSsimDataPrep$nonForest_timeSinceDisturbance2011, #must get 2001 object from fsSimDataPrep
  ## this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
  PCAveg = fSsimDataPrep$PCAveg,
  pixelGroupMap = fSsimDataPrep$pixelGroupMap2011,
  projectedClimateLayers = simOutPreamble$historicalClimateRasters,
  rasterToMatch = biomassMaps2011$rasterToMatch,
  sppColorVect = biomassMaps2011$sppColorVect,
  sppEquiv = fSsimDataPrep$sppEquiv,
  studyArea = biomassMaps2011$studyArea,
  rescaleFactor = 1 / fSsimDataPrep@params$fireSense_dataPrepFit$igAggFactor^2,
  terrainDT = fSsimDataPrep$terrainDT,
  vegComponentsToUse = fSsimDataPrep$vegComponentsToUse
)


#need to run ignition twice, 2001 and 2011
validationTimes <- list(start  = 2011, end = 2019)
rastersToSaveAnnually <- c(
  "fireSense_IgnitionPredicted")

annualRasters <- data.frame(
  expand.grid(
    objectName = rastersToSaveAnnually,
    saveTime = seq(validationTimes$start, validationTimes$end, 1),
    fun = "writeRaster",
    package = "raster"
  ),
  stringsAsFactors = FALSE
)
annualRasters$file <- paste0(annualRasters$objectName, "_validation_", annualRasters$saveTime, ".tif")
validationOutputs2011 <- rbind(annualRasters)

validationParams <- list(
  fireSense_dataPrepPredict = list(
    "fireTimeStep" = 1,
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "whichModulesToPrepare" = c("fireSense_IgnitionPredict"),
    "missingLCCgroup" = fSsimDataPrep@params$fireSense_dataPrepFit$missingLCCgroup
  )
)

validationOut2011 <- simInitAndSpades(
  times = validationTimes,
  params = validationParams,
  outputs = validationOutputs2011,
  modules = c("fireSense_dataPrepPredict", "fireSense_IgnitionPredict"),
  paths = validationPaths,
  objects = validationObjects
)


#### 2001 run ####
validationObjects <- list(
  climateComponentsTouse = fSsimDataPrep$climateComponentsToUse,
  cohortData = fSsimDataPrep$cohortData2001, #for latter half
  covMinMax_ignition = ignitionOut$covMinMax_ignition, #new object
  flammableRTM = fSsimDataPrep$flammableRTM,
  fireSense_IgnitionFitted = ignitionOut$fireSense_IgnitionFitted,
  landcoverDT = fSsimDataPrep$landcoverDT,
  nonForest_timeSinceDisturbance = fSsimDataPrep$nonForest_timeSinceDisturbance2001, #must get 2001 object from fsSimDataPrep
  PCAveg = fSsimDataPrep$PCAveg, #technically don't need this - but module will stop. hm
  ## this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
  pixelGroupMap = fSsimDataPrep$pixelGroupMap2001,
  projectedClimateLayers = simOutPreamble$historicalClimateRasters,
  rasterToMatch = biomassMaps2001$rasterToMatch,
  sppColorVect = biomassMaps2001$sppColorVect,
  sppEquiv = fSsimDataPrep$sppEquiv,
  studyArea = biomassMaps2001$studyArea,
  rescaleFactor = 1 / fSsimDataPrep@params$fireSense_dataPrepFit$igAggFactor^2,
  terrainDT = fSsimDataPrep$terrainDT,
  vegComponentsToUse = fSsimDataPrep$vegComponentsToUse
)


#need to run ignition twice, 2001 and 2011
validationTimes <- list(start  = 2001, end = 2010)
rastersToSaveAnnually <- c(
  "fireSense_IgnitionPredicted")

annualRasters <- data.frame(
  expand.grid(
    objectName = rastersToSaveAnnually,
    saveTime = seq(validationTimes$start, validationTimes$end, 1),
    fun = "writeRaster",
    package = "raster"
  ),
  stringsAsFactors = FALSE
)
annualRasters$file <- paste0(annualRasters$objectName, "_validation_", annualRasters$saveTime, ".tif")
validationOutputs2001 <- rbind(annualRasters)


validationParams <- list(
  fireSense_dataPrepPredict = list(
    "fireTimeStep" = 1,
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "whichModulesToPrepare" = c("fireSense_IgnitionPredict"),
    "missingLCCgroup" = fSsimDataPrep@params$fireSense_dataPrepFit$missingLCCgroup
  )
)

validationOut2001 <- simInitAndSpades(
  times = validationTimes,
  params = validationParams,
  outputs = validationOutputs2001,
  modules = c("fireSense_dataPrepPredict", "fireSense_IgnitionPredict"),
  paths = validationPaths,
  objects = validationObjects
)


##### validation of outputs #####
#note the outputs are <year> _ <'year<year>'.tif .. bug?

igPred <- list.files(outputPath(validationOut2001), full.names = TRUE) %>%
  lapply(., raster)
names(igPred) <- 2001:2020

predDT <- lapply(names(igPred), FUN = function(year, rasList = igPred) {
  igProb <- na.omit(rasList[[year]][])
  outcomes <- lapply(1:100, FUN =  function(rep) {
    fires <- sum(rbinom(n = length(igProb), size = 1, prob = pmin(igProb, 1)))
  })
  dt <- data.table(year = year, ignitions = unlist(outcomes), rep = 1:100)
  return(dt)
})

validationSum <- rbindlist(predDT)
validationSum <- validationSum[, .(meanIgnitions = mean(ignitions),
                                  sd = sd(ignitions),
                                  min = min(ignitions),
                                  max = max(ignitions),
                                  seMean = sd(ignitions)/sqrt(.N)),
                              .(year),]
validationSum[, conf95Upper := meanIgnitions + 1.96 * seMean]
validationSum[, conf95Lower := meanIgnitions - 1.96 * seMean]

trueIgs <- as.data.table(fSsimDataPrep$fireSense_ignitionCovariates)
trueIgs <- trueIgs[, .("ignitions" = sum(ignitions)), .(year)]
validationSum[, stat := "simulated"]
trueIgs$stat <- "historical"

#this ggplot is really annoying - can't seem to control legend
ggplot(data = validationSum, aes(x = year, y = meanIgnitions, group = 1, color = stat)) +
  geom_line(col = 'green') +
  geom_ribbon(aes(ymin = min, ymax = max, col = 'simulated min/max'), alpha = 0.2) +
  geom_ribbon(aes(ymin = conf95Lower, ymax = conf95Upper, col = ' mean'), alpha = 0.2) +
  geom_line(data = trueIgs, aes(x = year, y = ignitions, group = 1, col = stat),
            cex = 1.2) +
  labs(x = "year", y = "ignitions") +
  theme_bw()


