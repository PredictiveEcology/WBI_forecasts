
do.call(setPaths, dynamicPaths)
dynamicModules <- list("fireSense_dataPrepPredict", "fireSense",
                       "fireSense_IgnitionPredict"
                       , "fireSense_EscapePredict"
                       ) #Biomass_core, etc will be added
dynamicObjects <- list(climateComponentsTouse = simDataPrep$climateComponentsToUse,
                       cohortData = simDataPrep$cohortData2011,
                       flammableRTM = simDataPrep$flammableRTM,
                       fireSense_IgnitionFitted = ignitionOut$fireSense_IgnitionFitted,
                       fireSense_EscapeFitted = escapeOut$fireSense_EscapeFitted,
                       landcoverDT = simDataPrep$landcoverDT,
                       nonForest_timeSinceDisturbance = simDataPrep$nonForest_timeSinceDisturbance,
                       #this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
                       PCAveg = simDataPrep$PCAveg,
                       pixelGroupMap = simDataPrep$pixelGroupMap2011,
                       projectedClimateLayers = simOutPreamble$projectedClimateRasters,
                       sppEquiv = simDataPrep$sppEquiv,
                       terrainDT = simDataPrep$terrainDT,
                       vegComponentsToUse = simDataPrep$vegComponentsToUse)

dynamicParams <- list(
  fireSense_dataPrepPredict = list(
    'fireTimeStep' = 1,
    'sppEquivCol' = simOutPreamble$sppEquivCol,
    'whichModulesToPrepare' = c('fireSense_IgnitionPredict', 'fireSense_EscapePredict'),
    'missingLCCgroup' = simDataPrep@params$fireSense_dataPrepFit$missingLCCgroup
  ),
  fireSense_ignitionPredict = list(
    'rescaleFactor' = 1/simDataPrep@params$fireSense_dataPrepFit$igAggFactor^2
  )
)
mainSim <- simInitAndSpades(times = list(start = 2011, end = 2013),
                            modules = dynamicModules,
                            objects = dynamicObjects,
                            params = dynamicParams,
                            paths = dynamicPaths)



