do.call(setPaths, dynamicPaths)
times <- list(start = 2011, end = 2061)
dynamicModules <- list("fireSense_dataPrepPredict"
                       , "fireSense"
                       , "fireSense_IgnitionPredict"
                       , "fireSense_EscapePredict"
                       , "fireSense_SpreadPredict"
                       , "Biomass_core"
                       , "Biomass_regeneration"
                       ) #Biomass_core, etc will be added
dynamicObjects <- list(climateComponentsTouse = fSsimDataPrep$climateComponentsToUse,
                       cohortData = fSsimDataPrep$cohortData2011,
                       ecoregion = biomassMaps2011$ecoregion,
                       ecoregionMap = biomassMaps2011$ecoregionMap,
                       flammableRTM = fSsimDataPrep$flammableRTM,
                       fireSense_IgnitionFitted = ignitionOut$fireSense_IgnitionFitted,
                       fireSense_EscapeFitted = escapeOut$fireSense_EscapeFitted,
                       fireSense_SpreadFitted = spreadOut$fireSense_SpreadFitted,
                       covMinMax = spreadOut$covMinMax,
                       landcoverDT = fSsimDataPrep$landcoverDT,
                       nonForest_timeSinceDisturbance = fSsimDataPrep$nonForest_timeSinceDisturbance,
                       #this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
                       minRelativeB = biomassMaps2011$minRelativeB,
                       PCAveg = fSsimDataPrep$PCAveg,
                       pixelGroupMap = fSsimDataPrep$pixelGroupMap2011,
                       projectedClimateLayers = simOutPreamble$projectedClimateRasters,
                       speciesEcoregion = biomassMaps2011$speciesEcoregion,
                       speciesLayers = biomassMaps2011$speciesLayers, #does Biomass_core actually need this?
                       sppColorVect = biomassMaps2011$sppColorVect,
                       sppEquiv = fSsimDataPrep$sppEquiv, #biomassMaps2011 needs bugfix to qs
                       studyArea = biomassMaps2011$studyArea,
                       studyAreaReporting = biomassMaps2011$studyAreaReporting,
                       sufficientLight = biomassMaps2011$sufficientLight,
                       terrainDT = fSsimDataPrep$terrainDT,
                       vegComponentsToUse = fSsimDataPrep$vegComponentsToUse)

dynamicParams <- list(
  Biomass_core = list(
    'sppEquivCol' = fSsimDataPrep@params$fireSense_dataPrepFit$sppEquivCol
  ),
  Biomass_regeneration = list(
    "fireInitialTime" = times$start
  ),
  fireSense_dataPrepPredict = list(
    "fireTimeStep" = 1,
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "whichModulesToPrepare" = c("fireSense_IgnitionPredict",
                                "fireSense_EscapePredict",
                                "fireSense_SpreadPredict"),
    "missingLCCgroup" = fSsimDataPrep@params$fireSense_dataPrepFit$missingLCCgroup
  ),
  fireSense_ignitionPredict = list(
    "rescaleFactor" = 1/fSsimDataPrep@params$fireSense_dataPrepFit$igAggFactor^2
  ),
  fireSense = list(
    "whichModulesToPrepare" = c("fireSense_IgnitionPredict", "fireSense_EscapePredict", "fireSense_SpreadPredict"),
    ".plotInterval" = NA,
    ".plotInitialTime" = NA,
    "plotIgnitions" = FALSE
  )
)

mainSim <- simInitAndSpades(times = times,
                            modules = dynamicModules,
                            objects = dynamicObjects,
                            params = dynamicParams,
                            paths = dynamicPaths)
