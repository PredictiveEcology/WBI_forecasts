do.call(setPaths, dynamicPaths)

dynamicModules <- list("fireSense_dataPrepPredict"
                       , "fireSense"
                       , "fireSense_IgnitionPredict"
                       , "fireSense_EscapePredict"
                       , "fireSense_SpreadPredict"
                       ) #Biomass_core, etc will be added
dynamicObjects <- list(climateComponentsTouse = fSsimDataPrep$climateComponentsToUse,
                       cohortData = fSsimDataPrep$cohortData2011,
                       flammableRTM = fSsimDataPrep$flammableRTM,
                       fireSense_IgnitionFitted = ignitionOut$fireSense_IgnitionFitted,
                       fireSense_EscapeFitted = escapeOut$fireSense_EscapeFitted,
                       fireSense_SpreadFitted = spreadOut$fireSense_SpreadFitted,
                       covMinMax = spreadOut$covMinMax,
                       landcoverDT = fSsimDataPrep$landcoverDT,
                       nonForest_timeSinceDisturbance = fSsimDataPrep$nonForest_timeSinceDisturbance,
                       #this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
                       PCAveg = fSsimDataPrep$PCAveg,
                       pixelGroupMap = fSsimDataPrep$pixelGroupMap2011,
                       projectedClimateLayers = simOutPreamble$projectedClimateRasters,
                       sppEquiv = fSsimDataPrep$sppEquiv,
                       terrainDT = fSsimDataPrep$terrainDT,
                       vegComponentsToUse = fSsimDataPrep$vegComponentsToUse)

dynamicParams <- list(
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
    "whichModulesToPrepare" = c("fireSense_IgnitionPredict", "fireSense_EscapePredict", "fireSense_SpreadPredict")
  )
)

mainSim <- simInitAndSpades(times = list(start = 2011, end = 2013),
                            modules = dynamicModules,
                            objects = dynamicObjects,
                            params = dynamicParams,
                            paths = dynamicPaths)
